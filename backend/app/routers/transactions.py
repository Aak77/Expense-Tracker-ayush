"""
Transactions router for FinTrack.

CRUD endpoints for income/expense transactions with filtering, pagination,
and automatic net-worth snapshot updates via background tasks.
"""

import csv
import io
import math
import uuid
from decimal import Decimal
from datetime import date, datetime
from typing import Optional, List

from fastapi import APIRouter, BackgroundTasks, Depends, Query, UploadFile, File, HTTPException
from sqlalchemy import select, func, and_
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models.user import User
from app.models.transaction import Transaction
from app.schemas.transaction import (
    TransactionCreate,
    TransactionUpdate,
    TransactionResponse,
    TransactionListResponse,
    TransactionParseResponse,
    TransactionBulkCreate,
    EXPENSE_CATEGORIES,
    INCOME_CATEGORIES,
)
from app.services.auth_service import update_net_worth_snapshot
from app.exceptions import (
    TransactionNotFoundError,
    InvalidTransactionTypeError,
)


router = APIRouter(prefix="/api/v1/transactions", tags=["Transactions"])


# ─── Helpers ──────────────────────────────────────────────────────────────────


async def _get_transaction_or_404(
    transaction_id: uuid.UUID,
    user_id: uuid.UUID,
    db: AsyncSession,
) -> Transaction:
    """Fetch a transaction by ID and verify ownership."""
    stmt = select(Transaction).where(
        Transaction.id == transaction_id,
        Transaction.user_id == user_id,
    )
    result = await db.execute(stmt)
    transaction = result.scalar_one_or_none()
    if not transaction:
        raise TransactionNotFoundError()
    return transaction


# ─── Create ───────────────────────────────────────────────────────────────────


@router.post("/", response_model=TransactionResponse)
async def create_transaction(
    data: TransactionCreate,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a new income or expense transaction."""

    if data.type not in ("income", "expense"):
        raise InvalidTransactionTypeError()

    transaction = Transaction(
        id=uuid.uuid4(),
        user_id=current_user.id,
        amount=data.amount,
        type=data.type,
        category=data.category,
        description=data.description,
        transaction_date=data.transaction_date,
    )
    db.add(transaction)
    await db.flush()

    background_tasks.add_task(update_net_worth_snapshot, db, current_user.id)

    return TransactionResponse.model_validate(transaction)


# ─── List (with filters + pagination) ────────────────────────────────────────


@router.get("/", response_model=TransactionListResponse)
async def list_transactions(
    type: Optional[str] = Query(None, description="Filter by 'income' or 'expense'"),
    category: Optional[str] = Query(None, description="Filter by category"),
    start_date: Optional[date] = Query(None, description="Start date (inclusive)"),
    end_date: Optional[date] = Query(None, description="End date (inclusive)"),
    search: Optional[str] = Query(None, description="Search in description"),
    page: int = Query(1, ge=1, description="Page number"),
    limit: int = Query(20, ge=1, le=100, description="Items per page"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List transactions with optional filters, search, and pagination."""

    # Base conditions
    conditions = [Transaction.user_id == current_user.id]

    if type is not None:
        conditions.append(Transaction.type == type)
    if category is not None:
        conditions.append(Transaction.category == category)
    if start_date is not None:
        conditions.append(Transaction.transaction_date >= start_date)
    if end_date is not None:
        conditions.append(Transaction.transaction_date <= end_date)
    if search is not None:
        conditions.append(Transaction.description.ilike(f"%{search}%"))

    where_clause = and_(*conditions)

    # Total count
    count_stmt = select(func.count()).select_from(Transaction).where(where_clause)
    total = (await db.execute(count_stmt)).scalar() or 0

    # Paginated results
    offset = (page - 1) * limit
    data_stmt = (
        select(Transaction)
        .where(where_clause)
        .order_by(Transaction.transaction_date.desc())
        .offset(offset)
        .limit(limit)
    )
    result = await db.execute(data_stmt)
    transactions = result.scalars().all()

    total_pages = math.ceil(total / limit) if total > 0 else 1

    return TransactionListResponse(
        transactions=[TransactionResponse.model_validate(t) for t in transactions],
        total=total,
        page=page,
        limit=limit,
        total_pages=total_pages,
    )


# ─── Get Single ───────────────────────────────────────────────────────────────


@router.get("/{transaction_id}", response_model=TransactionResponse)
async def get_transaction(
    transaction_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve a single transaction by ID."""
    transaction = await _get_transaction_or_404(transaction_id, current_user.id, db)
    return TransactionResponse.model_validate(transaction)


# ─── Update ───────────────────────────────────────────────────────────────────


@router.put("/{transaction_id}", response_model=TransactionResponse)
async def update_transaction(
    transaction_id: uuid.UUID,
    data: TransactionUpdate,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update an existing transaction."""
    transaction = await _get_transaction_or_404(transaction_id, current_user.id, db)

    update_data = data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(transaction, field, value)

    await db.flush()
    background_tasks.add_task(update_net_worth_snapshot, db, current_user.id)

    return TransactionResponse.model_validate(transaction)


# ─── Delete ───────────────────────────────────────────────────────────────────


@router.delete("/{transaction_id}")
async def delete_transaction(
    transaction_id: uuid.UUID,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Permanently delete a transaction."""
    transaction = await _get_transaction_or_404(transaction_id, current_user.id, db)

    await db.delete(transaction)
    await db.flush()
    background_tasks.add_task(update_net_worth_snapshot, db, current_user.id)

    return {"message": "Transaction deleted successfully"}


# ─── CSV Import Utilities ──────────────────────────────────────────────────────

EXPENSE_KEYWORDS = {
    "food": ["swiggy", "zomato", "blinkit", "bigbasket", "dmart", "chai", "snacks", "dominos", "haldiram", "restaurant", "cafe", "groceries", "grocery", "mcdonald", "starbucks", "kfc", "burger", "pizza", "dine", "eat", "food", "bakery", "canteen", "sweets", "namkeen"],
    "transport": ["uber", "ola", "metro", "petrol", "indian oil", "irctc", "rapido", "train", "flight", "cab", "taxi", "fuel", "gasoline", "shell", "hpcl", "bpcl", "toll", "fastag", "auto", "railway"],
    "shopping": ["amazon", "flipkart", "myntra", "reliance digital", "nykaa", "croma", "electronics", "clothes", "fashion", "mall", "shopping", "retail", "zara", "h&m", "apparel", "store", "supermarket", "ajio", "meesho"],
    "entertainment": ["netflix", "spotify", "disney", "hotstar", "bookmyshow", "prime video", "pvr", "inox", "movie", "cinema", "theatre", "concert", "show", "game", "steam", "playstation", "xbox", "pub", "bar", "club", "party"],
    "bills": ["jio", "airtel", "broadband", "electricity", "tata power", "water bill", "gas bill", "indane", "lpg", "rent", "maintenance", "wifi", "recharge", "phone bill", "utility", "mobile bill", "insurance premium", "bescom", "act fiber", "tataplay", "dth", "society"],
    "health": ["pharmacy", "apollo", "medicine", "doctor", "practo", "gym", "cult.fit", "health", "hospital", "clinic", "dental", "medical", "insurance", "chemist", "lab", "diagnostics", "fit"],
    "education": ["udemy", "unacademy", "course", "books", "tuition", "school", "college", "fees", "learning", "coursera", "edx", "stationery", "class", "training"],
    "travel": ["makemytrip", "goibibo", "oyo", "hotel", "flight", "tickets", "airbnb", "travel", "vacation", "trip", "booking", "resort", "homestay", "expedia", "agoda"],
    "investment": ["zerodha", "mutual fund", "groww", "stock", "shares", "sip", "etf", "indmoney", "coin", "crypto", "angelone", "upstox"]
}

INCOME_KEYWORDS = {
    "salary": ["salary", "payroll", "tcs", "infosys", "wipro", "stipend", "direct deposit", "wage", "employer", "hcl", "accenture", "cognizant"],
    "freelance": ["upwork", "fiverr", "freelance", "consulting", "gig", "contract", "invoice", "client", "toptal"],
    "investment": ["dividend", "interest", "fd interest", "mutual fund returns", "sbi fd", "capital gain", "payout", "redemption", "bonds", "coupon"],
    "gift": ["gift", "birthday", "reward", "cashback", "scratch card", "bonus", "prize", "shagun"]
}

def parse_date(date_str: str) -> date:
    date_str = date_str.strip()
    formats = [
        "%Y-%m-%d",
        "%d-%m-%Y",
        "%m/%d/%y",
        "%m/%d/%Y",
        "%d/%m/%Y",
        "%d/%m/%y",
        "%Y/%m/%d",
    ]
    for fmt in formats:
        try:
            return datetime.strptime(date_str, fmt).date()
        except ValueError:
            continue
    raise ValueError(f"Could not parse date: {date_str}")

def auto_categorize(description: str, explicit_type: Optional[str] = None) -> tuple[str, str]:
    """
    Returns (type, category) based on description and optional explicit type.
    """
    desc_lower = description.lower().strip() if description else ""
    
    # 1. Determine Type
    txn_type = None
    if explicit_type:
        explicit_type_lower = explicit_type.lower().strip()
        if explicit_type_lower in ("income", "credit", "cr", "inflow", "deposit"):
            txn_type = "income"
        elif explicit_type_lower in ("expense", "debit", "dr", "outflow", "withdrawal"):
            txn_type = "expense"
            
    if not txn_type:
        # Check if description strongly suggests income
        is_income_desc = any(any(kw in desc_lower for kw in keywords) for keywords in INCOME_KEYWORDS.values())
        is_expense_desc = any(any(kw in desc_lower for kw in keywords) for keywords in EXPENSE_KEYWORDS.values())
        
        if is_income_desc and not is_expense_desc:
            txn_type = "income"
        else:
            txn_type = "expense"

    # 2. Determine Category
    category = "other"
    if txn_type == "expense":
        for cat, keywords in EXPENSE_KEYWORDS.items():
            if any(kw in desc_lower for kw in keywords):
                category = cat
                break
    else:
        for cat, keywords in INCOME_KEYWORDS.items():
            if any(kw in desc_lower for kw in keywords):
                category = cat
                break
                
    return txn_type, category


# ─── Endpoints ───────────────────────────────────────────────────────────────

@router.post("/parse-csv", response_model=List[TransactionParseResponse])
async def parse_csv(
    file: UploadFile = File(...)
):
    """
    Parse uploaded CSV, identify column headers, auto-categorize transactions, 
    and return parsed transaction details.
    """
    if not file.filename.endswith('.csv'):
        raise HTTPException(status_code=400, detail="Only CSV files are allowed.")
    
    content = await file.read()
    try:
        decoded_content = content.decode('utf-8')
    except UnicodeDecodeError:
        try:
            decoded_content = content.decode('latin-1')
        except Exception:
            raise HTTPException(status_code=400, detail="Could not decode CSV file. Please verify encoding.")

    f = io.StringIO(decoded_content)
    reader = csv.reader(f)
    
    try:
        headers = next(reader)
    except StopIteration:
        raise HTTPException(status_code=400, detail="Empty CSV file.")

    cleaned_headers = [h.strip().lower().replace("_", "").replace("-", "").replace(" ", "") for h in headers]

    date_idx = -1
    desc_idx = -1
    amount_idx = -1
    type_idx = -1
    debit_idx = -1
    credit_idx = -1

    for idx, h in enumerate(cleaned_headers):
        if h in ("date", "transactiondate", "txdate", "timestamp", "time"):
            date_idx = idx
        elif h in ("description", "desc", "memo", "details", "narration", "payee", "remarks", "title"):
            desc_idx = idx
        elif h in ("amount", "value", "price", "sum", "cost", "rupees", "inr"):
            amount_idx = idx
        elif h in ("type", "transactiontype"):
            type_idx = idx
        elif h in ("debit", "withdrawal", "outflow", "dr"):
            debit_idx = idx
        elif h in ("credit", "deposit", "inflow", "cr"):
            credit_idx = idx

    if date_idx == -1:
        raise HTTPException(status_code=400, detail="Missing date column. We support 'date', 'transaction_date', etc.")
    if desc_idx == -1:
        raise HTTPException(status_code=400, detail="Missing description column. We support 'description', 'desc', 'narration', etc.")
    if amount_idx == -1 and (debit_idx == -1 or credit_idx == -1):
        raise HTTPException(status_code=400, detail="Missing amount column. We support 'amount', or separate 'debit' and 'credit' columns.")

    parsed_transactions = []
    line_number = 1
    
    for row in reader:
        line_number += 1
        if not row or all(cell.strip() == "" for cell in row):
            continue
            
        max_idx = max(date_idx, desc_idx, amount_idx, type_idx, debit_idx, credit_idx)
        if len(row) <= max_idx:
            row = row + [""] * (max_idx - len(row) + 1)

        date_str = row[date_idx]
        try:
            parsed_date = parse_date(date_str)
        except Exception:
            raise HTTPException(status_code=400, detail=f"Row {line_number}: Invalid date value '{date_str}'.")

        description = row[desc_idx].strip()
        amount = Decimal("0.0")
        explicit_type = None

        if amount_idx != -1:
            amount_str = row[amount_idx].strip().replace(",", "")
            if not amount_str:
                amount_str = "0"
            try:
                val = Decimal(amount_str)
                amount = abs(val)
                if val < 0:
                    explicit_type = "expense"
                elif val > 0:
                    explicit_type = "income"
            except Exception:
                raise HTTPException(status_code=400, detail=f"Row {line_number}: Invalid amount value '{amount_str}'.")
        
        if debit_idx != -1 and credit_idx != -1:
            debit_str = row[debit_idx].strip().replace(",", "")
            credit_str = row[credit_idx].strip().replace(",", "")
            
            debit_val = Decimal("0.0")
            credit_val = Decimal("0.0")
            
            if debit_str:
                try:
                    debit_val = Decimal(debit_str)
                except Exception:
                    pass
            if credit_str:
                try:
                    credit_val = Decimal(credit_str)
                except Exception:
                    pass

            if debit_val > 0:
                amount = debit_val
                explicit_type = "expense"
            elif credit_val > 0:
                amount = credit_val
                explicit_type = "income"

        if type_idx != -1 and not explicit_type:
            explicit_type = row[type_idx].strip()

        inferred_type, inferred_category = auto_categorize(description, explicit_type)

        parsed_transactions.append(
            TransactionParseResponse(
                transaction_date=parsed_date,
                description=description,
                amount=amount,
                type=inferred_type,
                category=inferred_category
            )
        )

    return parsed_transactions


@router.post("/bulk", response_model=List[TransactionResponse])
async def create_transactions_bulk(
    data: TransactionBulkCreate,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create multiple transactions in a single batch."""
    created_transactions = []
    
    for item in data.transactions:
        if item.type not in ("income", "expense"):
            raise InvalidTransactionTypeError()
            
        transaction = Transaction(
            id=uuid.uuid4(),
            user_id=current_user.id,
            amount=item.amount,
            type=item.type,
            category=item.category,
            description=item.description,
            transaction_date=item.transaction_date,
        )
        db.add(transaction)
        created_transactions.append(transaction)
        
    await db.flush()
    background_tasks.add_task(update_net_worth_snapshot, db, current_user.id)
    
    return [TransactionResponse.model_validate(t) for t in created_transactions]


"""
Transactions router for FinTrack.

CRUD endpoints for income/expense transactions with filtering, pagination,
and automatic net-worth snapshot updates via background tasks.
"""

import math
import uuid
from datetime import date
from typing import Optional

from fastapi import APIRouter, BackgroundTasks, Depends, Query
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

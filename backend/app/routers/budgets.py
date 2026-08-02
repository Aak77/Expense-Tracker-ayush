"""
Budgets router for FinTrack.

Manages per-category monthly spending limits with real-time utilisation
metrics computed from the current month's transactions.
"""

import uuid
from datetime import date, datetime
from decimal import Decimal

from fastapi import APIRouter, Depends
from sqlalchemy import select, func, and_, extract
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models.user import User
from app.models.budget import Budget
from app.models.transaction import Transaction
from app.schemas.budget import BudgetCreate, BudgetUpdate, BudgetResponse
from app.exceptions import BudgetNotFoundError

router = APIRouter(prefix="/api/v1/budgets", tags=["Budgets"])


# ─── Helpers ──────────────────────────────────────────────────────────────────


async def _get_current_spending(
    db: AsyncSession, user_id: uuid.UUID, category: str
) -> Decimal:
    """Sum of expenses for a given category in the current month."""
    today = date.today()
    if category.lower() == "global":
        stmt = select(func.coalesce(func.sum(Transaction.amount), 0)).where(
            and_(
                Transaction.user_id == user_id,
                Transaction.type == "expense",
                extract("year", Transaction.transaction_date) == today.year,
                extract("month", Transaction.transaction_date) == today.month,
            )
        )
    else:
        stmt = select(func.coalesce(func.sum(Transaction.amount), 0)).where(
            and_(
                Transaction.user_id == user_id,
                Transaction.type == "expense",
                Transaction.category == category,
                extract("year", Transaction.transaction_date) == today.year,
                extract("month", Transaction.transaction_date) == today.month,
            )
        )
    result = await db.execute(stmt)
    return Decimal(str(result.scalar()))


def _compute_status(utilization: float) -> str:
    """Determine budget health status from utilization percentage."""
    if utilization > 100:
        return "exceeded"
    if utilization >= 85:
        return "danger"
    if utilization >= 60:
        return "warning"
    return "safe"


async def _enrich_budget(
    db: AsyncSession, budget: Budget, user_id: uuid.UUID
) -> dict:
    """Attach real-time spending metrics to a budget record."""
    current_spending = await _get_current_spending(db, user_id, budget.category)
    remaining = budget.monthly_limit - current_spending
    utilization = (
        float(current_spending / budget.monthly_limit * 100)
        if budget.monthly_limit > 0
        else 0.0
    )
    status = _compute_status(utilization)

    return {
        "id": budget.id,
        "user_id": budget.user_id,
        "category": budget.category,
        "monthly_limit": budget.monthly_limit,
        "current_spending": current_spending,
        "remaining": remaining,
        "utilization_percentage": round(utilization, 2),
        "status": status,
        "created_at": budget.created_at,
    }


# ─── Upsert (Create or Update) ───────────────────────────────────────────────


@router.post("/", response_model=BudgetResponse)
async def create_budget(
    data: BudgetCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a new budget or update the limit if one already exists for this
    category."""

    # Check for existing budget on the same category
    stmt = select(Budget).where(
        and_(
            Budget.user_id == current_user.id,
            Budget.category == data.category,
        )
    )
    result = await db.execute(stmt)
    budget = result.scalar_one_or_none()

    if budget:
        # Upsert — update the monthly limit
        budget.monthly_limit = data.monthly_limit
    else:
        budget = Budget(
            id=uuid.uuid4(),
            user_id=current_user.id,
            category=data.category,
            monthly_limit=data.monthly_limit,
        )
        db.add(budget)

    await db.flush()

    enriched = await _enrich_budget(db, budget, current_user.id)
    return BudgetResponse(**enriched)


# ─── List All ─────────────────────────────────────────────────────────────────


@router.get("/", response_model=list[BudgetResponse])
async def list_budgets(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Return all budgets for the current user with live spending metrics."""

    stmt = select(Budget).where(Budget.user_id == current_user.id)
    result = await db.execute(stmt)
    budgets = result.scalars().all()

    enriched_list = []
    for budget in budgets:
        enriched = await _enrich_budget(db, budget, current_user.id)
        enriched_list.append(BudgetResponse(**enriched))

    return enriched_list


# ─── Update ───────────────────────────────────────────────────────────────────


@router.put("/{budget_id}", response_model=BudgetResponse)
async def update_budget(
    budget_id: uuid.UUID,
    data: BudgetUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update the monthly limit for a budget."""

    stmt = select(Budget).where(
        Budget.id == budget_id,
        Budget.user_id == current_user.id,
    )
    result = await db.execute(stmt)
    budget = result.scalar_one_or_none()

    if not budget:
        raise BudgetNotFoundError()

    budget.monthly_limit = data.monthly_limit
    await db.flush()

    enriched = await _enrich_budget(db, budget, current_user.id)
    return BudgetResponse(**enriched)


# ─── Delete ───────────────────────────────────────────────────────────────────


@router.delete("/{budget_id}")
async def delete_budget(
    budget_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Delete a budget."""

    stmt = select(Budget).where(
        Budget.id == budget_id,
        Budget.user_id == current_user.id,
    )
    result = await db.execute(stmt)
    budget = result.scalar_one_or_none()

    if not budget:
        raise BudgetNotFoundError()

    await db.delete(budget)
    await db.flush()

    return {"message": "Budget deleted successfully"}

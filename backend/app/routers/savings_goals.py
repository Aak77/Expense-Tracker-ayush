"""
Savings goals router for FinTrack.

CRUD for savings goals with enriched progress tracking: percentage, remaining
amount, days remaining, estimated monthly savings needed, and on-track flag.
"""

import uuid
from datetime import date
from decimal import Decimal, ROUND_HALF_UP
from typing import Optional

from fastapi import APIRouter, Depends
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models.user import User
from app.models.savings_goal import SavingsGoal
from app.schemas.savings_goal import GoalCreate, GoalUpdate, GoalResponse
from app.exceptions import GoalNotFoundError

router = APIRouter(prefix="/api/v1/savings-goals", tags=["Savings Goals"])


# ─── Enrichment Helper ────────────────────────────────────────────────────────


def enrich_goal(goal: SavingsGoal) -> dict:
    """Compute derived progress fields for a savings goal.

    Returns a dict suitable for constructing a GoalResponse.
    """
    target_amount = Decimal(str(goal.target_amount))
    current_amount = Decimal(str(goal.current_amount or 0))
    remaining_amount = target_amount - current_amount

    # Progress percentage (capped at 100)
    progress_percentage = (
        float((current_amount / target_amount * 100).quantize(
            Decimal("0.01"), rounding=ROUND_HALF_UP
        ))
        if target_amount > 0
        else 0.0
    )

    # Days remaining
    days_remaining: Optional[int] = None
    estimated_monthly_saving_needed: Optional[Decimal] = None
    on_track = True

    if goal.target_date:
        today = date.today()
        delta = goal.target_date - today
        days_remaining = max(delta.days, 0)

        # Months remaining (approximate, min 1 to avoid division by zero)
        months_remaining = max(days_remaining / 30.44, 0)

        if months_remaining > 0 and remaining_amount > 0:
            estimated_monthly_saving_needed = (
                remaining_amount / Decimal(str(months_remaining))
            ).quantize(Decimal("0.01"), rounding=ROUND_HALF_UP)
        elif remaining_amount <= 0:
            estimated_monthly_saving_needed = Decimal("0")
        else:
            # No time left but money remaining
            estimated_monthly_saving_needed = remaining_amount

        # On-track heuristic: monthly savings rate (based on goal age) >=
        # estimated_monthly_saving_needed.
        if goal.created_at and estimated_monthly_saving_needed:
            created_date = goal.created_at.date() if hasattr(goal.created_at, 'date') else goal.created_at
            goal_age_days = max((today - created_date).days, 1)
            goal_age_months = max(goal_age_days / 30.44, 1)
            actual_monthly_rate = current_amount / Decimal(str(goal_age_months))
            on_track = actual_monthly_rate >= estimated_monthly_saving_needed
        elif remaining_amount <= 0:
            on_track = True
    else:
        # No target date — can't determine on-track
        on_track = True

    return {
        "id": goal.id,
        "user_id": goal.user_id,
        "goal_name": goal.goal_name,
        "target_amount": goal.target_amount,
        "current_amount": goal.current_amount,
        "target_date": goal.target_date,
        "progress_percentage": progress_percentage,
        "remaining_amount": remaining_amount,
        "days_remaining": days_remaining,
        "estimated_monthly_saving_needed": estimated_monthly_saving_needed,
        "on_track": on_track,
        "created_at": goal.created_at,
        "updated_at": goal.updated_at,
    }


# ─── Create ───────────────────────────────────────────────────────────────────


@router.post("/", response_model=GoalResponse)
async def create_goal(
    data: GoalCreate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a new savings goal."""

    goal = SavingsGoal(
        id=uuid.uuid4(),
        user_id=current_user.id,
        goal_name=data.goal_name,
        target_amount=data.target_amount,
        current_amount=data.current_amount,
        target_date=data.target_date,
    )
    db.add(goal)
    await db.flush()

    return GoalResponse(**enrich_goal(goal))


# ─── List All ─────────────────────────────────────────────────────────────────


@router.get("/", response_model=list[GoalResponse])
async def list_goals(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List all savings goals with enriched progress metrics."""

    stmt = select(SavingsGoal).where(SavingsGoal.user_id == current_user.id)
    result = await db.execute(stmt)
    goals = result.scalars().all()

    return [GoalResponse(**enrich_goal(g)) for g in goals]


# ─── Get Single ───────────────────────────────────────────────────────────────


@router.get("/{goal_id}", response_model=GoalResponse)
async def get_goal(
    goal_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Retrieve a single savings goal with progress metrics."""

    stmt = select(SavingsGoal).where(
        SavingsGoal.id == goal_id,
        SavingsGoal.user_id == current_user.id,
    )
    result = await db.execute(stmt)
    goal = result.scalar_one_or_none()

    if not goal:
        raise GoalNotFoundError()

    return GoalResponse(**enrich_goal(goal))


# ─── Update ───────────────────────────────────────────────────────────────────


@router.put("/{goal_id}", response_model=GoalResponse)
async def update_goal(
    goal_id: uuid.UUID,
    data: GoalUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update a savings goal's fields."""

    stmt = select(SavingsGoal).where(
        SavingsGoal.id == goal_id,
        SavingsGoal.user_id == current_user.id,
    )
    result = await db.execute(stmt)
    goal = result.scalar_one_or_none()

    if not goal:
        raise GoalNotFoundError()

    update_data = data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(goal, field, value)

    await db.flush()

    return GoalResponse(**enrich_goal(goal))


# ─── Delete ───────────────────────────────────────────────────────────────────


@router.delete("/{goal_id}")
async def delete_goal(
    goal_id: uuid.UUID,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Delete a savings goal."""

    stmt = select(SavingsGoal).where(
        SavingsGoal.id == goal_id,
        SavingsGoal.user_id == current_user.id,
    )
    result = await db.execute(stmt)
    goal = result.scalar_one_or_none()

    if not goal:
        raise GoalNotFoundError()

    await db.delete(goal)
    await db.flush()

    return {"message": "Savings goal deleted successfully"}

"""
Analytics router for FinTrack.

Delegates all analytics computations to the analytics_service and returns
the results. Every endpoint requires authentication.
"""

from typing import Optional

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models.user import User
from app.services.analytics_service import (
    get_dashboard_data,
    get_spending_by_category,
    get_monthly_trend,
    get_category_comparison,
    get_daily_spending,
)

router = APIRouter(prefix="/api/v1/analytics", tags=["Analytics"])


@router.get("/dashboard")
async def dashboard(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Return aggregated dashboard metrics."""
    return await get_dashboard_data(db, current_user.id)


@router.get("/spending-by-category")
async def spending_by_category(
    month: Optional[str] = Query(
        None, description="Month in YYYY-MM format (defaults to current month)"
    ),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Return spending breakdown grouped by category."""
    return await get_spending_by_category(db, current_user.id, month)


@router.get("/monthly-trend")
async def monthly_trend(
    months: int = Query(6, ge=1, le=24, description="Number of months to include"),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Return income vs expense trend over the last N months."""
    return await get_monthly_trend(db, current_user.id, months)


@router.get("/category-comparison")
async def category_comparison(
    month: Optional[str] = Query(
        None, description="Month in YYYY-MM format (defaults to current month)"
    ),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Compare spending across categories for a given month."""
    return await get_category_comparison(db, current_user.id, month)


@router.get("/daily-spending")
async def daily_spending(
    month: Optional[str] = Query(
        None, description="Month in YYYY-MM format (defaults to current month)"
    ),
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Return day-by-day spending totals for a given month."""
    return await get_daily_spending(db, current_user.id, month)

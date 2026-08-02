"""
Admin Analytics Router for FinTrack Business Dashboard.
========================================================

Public (unauthenticated) API endpoints for the data analytics
dashboard. All responses are fully anonymous — no user PII is
ever returned.
"""

from fastapi import APIRouter, Depends, Query
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.services.admin_analytics_service import (
    get_platform_overview,
    get_user_growth,
    get_monthly_trend,
    get_spending_by_category,
    get_top_merchants,
    get_user_segments,
    get_cohort_retention,
    get_anomaly_transactions,
)

router = APIRouter(prefix="/api/v1/admin/analytics", tags=["Admin Analytics"])


@router.get("/overview")
async def overview(db: AsyncSession = Depends(get_db)):
    """Platform-wide KPIs: users, transactions, income, expenses, savings rate."""
    return await get_platform_overview(db)


@router.get("/user-growth")
async def user_growth(db: AsyncSession = Depends(get_db)):
    """Monthly new user signups and cumulative user count."""
    return await get_user_growth(db)


@router.get("/monthly-trend")
async def monthly_trend(db: AsyncSession = Depends(get_db)):
    """Platform-wide monthly income vs expenses over full history."""
    return await get_monthly_trend(db)


@router.get("/spending-categories")
async def spending_categories(db: AsyncSession = Depends(get_db)):
    """Total spending breakdown by category across all users."""
    return await get_spending_by_category(db)


@router.get("/top-merchants")
async def top_merchants(
    limit: int = Query(15, ge=5, le=50),
    db: AsyncSession = Depends(get_db),
):
    """Top merchants by transaction volume."""
    return await get_top_merchants(db, limit=limit)


@router.get("/user-segments")
async def user_segments(db: AsyncSession = Depends(get_db)):
    """Anonymous user segmentation: budget adoption, goal participation, asset/liability breakdown."""
    return await get_user_segments(db)


@router.get("/cohort-retention")
async def cohort_retention(db: AsyncSession = Depends(get_db)):
    """Monthly cohort retention analysis (anonymous aggregate counts)."""
    return await get_cohort_retention(db)


@router.get("/anomalies")
async def anomalies(
    limit: int = Query(20, ge=5, le=100),
    db: AsyncSession = Depends(get_db),
):
    """Top largest single expense transactions for anomaly review (no user PII)."""
    return await get_anomaly_transactions(db, limit=limit)

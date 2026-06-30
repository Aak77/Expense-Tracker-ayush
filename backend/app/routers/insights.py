"""
Insights router for FinTrack.

Returns AI/rules-based financial insights for the authenticated user by
delegating to the insights_service.
"""

from fastapi import APIRouter, Depends
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models.user import User
from app.services.insights_service import generate_insights

router = APIRouter(prefix="/api/v1/insights", tags=["Insights"])


@router.get("/")
async def get_insights(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Generate and return personalised financial insights."""
    return await generate_insights(db, current_user.id)

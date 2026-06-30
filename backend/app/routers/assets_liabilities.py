"""
Assets & Liabilities router for FinTrack.

Manages assets, liabilities, net-worth summary, and historical snapshots.
Background tasks recalculate the net-worth snapshot on every mutation.
"""

import uuid
from datetime import date, timedelta
from decimal import Decimal

from fastapi import APIRouter, BackgroundTasks, Depends
from sqlalchemy import select, func
from sqlalchemy.ext.asyncio import AsyncSession

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models.user import User
from app.models.asset import Asset
from app.models.liability import Liability, NetWorthSnapshot
from app.schemas.asset import AssetCreate, AssetUpdate, AssetResponse, AssetsListResponse
from app.schemas.liability import (
    LiabilityCreate,
    LiabilityUpdate,
    LiabilityResponse,
    LiabilitiesListResponse,
    NetWorthSummary,
    NetWorthSnapshot as NetWorthSnapshotSchema,
)
from app.services.auth_service import update_net_worth_snapshot
from app.exceptions import AssetNotFoundError, LiabilityNotFoundError

router = APIRouter(prefix="/api/v1/net-worth", tags=["Net Worth"])


# ═══════════════════════════════════════════════════════════════════════════════
#  ASSETS
# ═══════════════════════════════════════════════════════════════════════════════


@router.post("/assets", response_model=AssetResponse)
async def create_asset(
    data: AssetCreate,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a new asset and trigger a net-worth snapshot update."""

    asset = Asset(
        id=uuid.uuid4(),
        user_id=current_user.id,
        asset_type=data.asset_type,
        name=data.name,
        amount=data.amount,
    )
    db.add(asset)
    await db.flush()

    background_tasks.add_task(update_net_worth_snapshot, db, current_user.id)

    return AssetResponse.model_validate(asset)


@router.get("/assets", response_model=AssetsListResponse)
async def list_assets(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List all assets and their total value."""

    stmt = select(Asset).where(Asset.user_id == current_user.id)
    result = await db.execute(stmt)
    assets = result.scalars().all()

    total = sum(Decimal(str(a.amount)) for a in assets)

    return AssetsListResponse(
        assets=[AssetResponse.model_validate(a) for a in assets],
        total_assets=total,
    )


@router.put("/assets/{asset_id}", response_model=AssetResponse)
async def update_asset(
    asset_id: uuid.UUID,
    data: AssetUpdate,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update an asset's details."""

    stmt = select(Asset).where(
        Asset.id == asset_id,
        Asset.user_id == current_user.id,
    )
    result = await db.execute(stmt)
    asset = result.scalar_one_or_none()

    if not asset:
        raise AssetNotFoundError()

    update_data = data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(asset, field, value)

    await db.flush()
    background_tasks.add_task(update_net_worth_snapshot, db, current_user.id)

    return AssetResponse.model_validate(asset)


@router.delete("/assets/{asset_id}")
async def delete_asset(
    asset_id: uuid.UUID,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Delete an asset."""

    stmt = select(Asset).where(
        Asset.id == asset_id,
        Asset.user_id == current_user.id,
    )
    result = await db.execute(stmt)
    asset = result.scalar_one_or_none()

    if not asset:
        raise AssetNotFoundError()

    await db.delete(asset)
    await db.flush()
    background_tasks.add_task(update_net_worth_snapshot, db, current_user.id)

    return {"message": "Asset deleted successfully"}


# ═══════════════════════════════════════════════════════════════════════════════
#  LIABILITIES
# ═══════════════════════════════════════════════════════════════════════════════


@router.post("/liabilities", response_model=LiabilityResponse)
async def create_liability(
    data: LiabilityCreate,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Create a new liability and trigger a net-worth snapshot update."""

    liability = Liability(
        id=uuid.uuid4(),
        user_id=current_user.id,
        liability_type=data.liability_type,
        name=data.name,
        amount=data.amount,
    )
    db.add(liability)
    await db.flush()

    background_tasks.add_task(update_net_worth_snapshot, db, current_user.id)

    return LiabilityResponse.model_validate(liability)


@router.get("/liabilities", response_model=LiabilitiesListResponse)
async def list_liabilities(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """List all liabilities and their total value."""

    stmt = select(Liability).where(Liability.user_id == current_user.id)
    result = await db.execute(stmt)
    liabilities = result.scalars().all()

    total = sum(Decimal(str(l.amount)) for l in liabilities)

    return LiabilitiesListResponse(
        liabilities=[LiabilityResponse.model_validate(l) for l in liabilities],
        total_liabilities=total,
    )


@router.put("/liabilities/{liability_id}", response_model=LiabilityResponse)
async def update_liability(
    liability_id: uuid.UUID,
    data: LiabilityUpdate,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update a liability's details."""

    stmt = select(Liability).where(
        Liability.id == liability_id,
        Liability.user_id == current_user.id,
    )
    result = await db.execute(stmt)
    liability = result.scalar_one_or_none()

    if not liability:
        raise LiabilityNotFoundError()

    update_data = data.model_dump(exclude_unset=True)
    for field, value in update_data.items():
        setattr(liability, field, value)

    await db.flush()
    background_tasks.add_task(update_net_worth_snapshot, db, current_user.id)

    return LiabilityResponse.model_validate(liability)


@router.delete("/liabilities/{liability_id}")
async def delete_liability(
    liability_id: uuid.UUID,
    background_tasks: BackgroundTasks,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Delete a liability."""

    stmt = select(Liability).where(
        Liability.id == liability_id,
        Liability.user_id == current_user.id,
    )
    result = await db.execute(stmt)
    liability = result.scalar_one_or_none()

    if not liability:
        raise LiabilityNotFoundError()

    await db.delete(liability)
    await db.flush()
    background_tasks.add_task(update_net_worth_snapshot, db, current_user.id)

    return {"message": "Liability deleted successfully"}


# ═══════════════════════════════════════════════════════════════════════════════
#  SUMMARY & HISTORY
# ═══════════════════════════════════════════════════════════════════════════════


@router.get("/summary", response_model=NetWorthSummary)
async def get_net_worth_summary(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Calculate total assets, total liabilities, and net worth with breakdowns."""

    # Fetch all assets
    assets_result = await db.execute(
        select(Asset).where(Asset.user_id == current_user.id)
    )
    assets = assets_result.scalars().all()
    total_assets = sum(Decimal(str(a.amount)) for a in assets)

    # Fetch all liabilities
    liabilities_result = await db.execute(
        select(Liability).where(Liability.user_id == current_user.id)
    )
    liabilities = liabilities_result.scalars().all()
    total_liabilities = sum(Decimal(str(l.amount)) for l in liabilities)

    net_worth = total_assets - total_liabilities

    return NetWorthSummary(
        total_assets=total_assets,
        total_liabilities=total_liabilities,
        net_worth=net_worth,
        assets_breakdown=[AssetResponse.model_validate(a) for a in assets],
        liabilities_breakdown=[LiabilityResponse.model_validate(l) for l in liabilities],
    )


@router.get("/history", response_model=list[NetWorthSnapshotSchema])
async def get_net_worth_history(
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Return net-worth snapshots for the last 12 months."""

    twelve_months_ago = date.today().replace(day=1) - timedelta(days=365)

    stmt = (
        select(NetWorthSnapshot)
        .where(
            NetWorthSnapshot.user_id == current_user.id,
            NetWorthSnapshot.snapshot_date >= twelve_months_ago,
        )
        .order_by(NetWorthSnapshot.snapshot_date.asc())
    )
    result = await db.execute(stmt)
    snapshots = result.scalars().all()

    return [NetWorthSnapshotSchema.model_validate(s) for s in snapshots]

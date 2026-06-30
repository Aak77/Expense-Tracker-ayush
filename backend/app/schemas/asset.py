from pydantic import BaseModel, ConfigDict, Field, EmailStr, field_validator, model_validator
from decimal import Decimal
from datetime import date, datetime
from typing import Optional, List
import uuid


ASSET_TYPES = [
    "bank_account",
    "cash",
    "mutual_fund",
    "fixed_deposit",
    "investment",
]


class AssetCreate(BaseModel):
    """Schema for creating a new asset."""
    asset_type: str
    name: str = Field(..., max_length=100)
    amount: Decimal = Field(..., ge=0)

    @field_validator("asset_type")
    @classmethod
    def validate_asset_type(cls, v: str) -> str:
        if v not in ASSET_TYPES:
            raise ValueError(
                f"Invalid asset type '{v}'. Must be one of: {', '.join(ASSET_TYPES)}"
            )
        return v


class AssetUpdate(BaseModel):
    """Schema for updating an asset."""
    asset_type: Optional[str] = None
    name: Optional[str] = Field(None, max_length=100)
    amount: Optional[Decimal] = Field(None, ge=0)

    @field_validator("asset_type")
    @classmethod
    def validate_asset_type(cls, v: Optional[str]) -> Optional[str]:
        if v is not None and v not in ASSET_TYPES:
            raise ValueError(
                f"Invalid asset type '{v}'. Must be one of: {', '.join(ASSET_TYPES)}"
            )
        return v


class AssetResponse(BaseModel):
    """Schema for asset response."""
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    user_id: uuid.UUID
    asset_type: str
    name: str
    amount: Decimal
    created_at: datetime
    updated_at: datetime


class AssetsListResponse(BaseModel):
    """Schema for assets list response with total."""
    assets: List[AssetResponse]
    total_assets: Decimal

from pydantic import BaseModel, ConfigDict, Field, EmailStr, field_validator, model_validator
from decimal import Decimal
from datetime import date, datetime
from typing import Optional, List
import uuid

from app.schemas.asset import AssetResponse


LIABILITY_TYPES = [
    "credit_card",
    "loan",
    "borrowed_money",
]


class LiabilityCreate(BaseModel):
    """Schema for creating a new liability."""
    liability_type: str
    name: str = Field(..., max_length=100)
    amount: Decimal = Field(..., ge=0)

    @field_validator("liability_type")
    @classmethod
    def validate_liability_type(cls, v: str) -> str:
        if v not in LIABILITY_TYPES:
            raise ValueError(
                f"Invalid liability type '{v}'. Must be one of: {', '.join(LIABILITY_TYPES)}"
            )
        return v


class LiabilityUpdate(BaseModel):
    """Schema for updating a liability."""
    liability_type: Optional[str] = None
    name: Optional[str] = Field(None, max_length=100)
    amount: Optional[Decimal] = Field(None, ge=0)

    @field_validator("liability_type")
    @classmethod
    def validate_liability_type(cls, v: Optional[str]) -> Optional[str]:
        if v is not None and v not in LIABILITY_TYPES:
            raise ValueError(
                f"Invalid liability type '{v}'. Must be one of: {', '.join(LIABILITY_TYPES)}"
            )
        return v


class LiabilityResponse(BaseModel):
    """Schema for liability response."""
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    user_id: uuid.UUID
    liability_type: str
    name: str
    amount: Decimal
    created_at: datetime
    updated_at: datetime


class LiabilitiesListResponse(BaseModel):
    """Schema for liabilities list response with total."""
    liabilities: List[LiabilityResponse]
    total_liabilities: Decimal


class NetWorthSummary(BaseModel):
    """Schema for net worth summary combining assets and liabilities."""
    total_assets: Decimal
    total_liabilities: Decimal
    net_worth: Decimal
    assets_breakdown: List[AssetResponse]
    liabilities_breakdown: List[LiabilityResponse]


class NetWorthSnapshot(BaseModel):
    """Schema for a point-in-time net worth snapshot."""
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    total_assets: Decimal
    total_liabilities: Decimal
    net_worth: Decimal
    snapshot_date: date
    created_at: datetime

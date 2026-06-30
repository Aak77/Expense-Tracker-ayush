from pydantic import BaseModel, ConfigDict, Field, EmailStr, field_validator, model_validator
from decimal import Decimal
from datetime import date, datetime
from typing import Optional, List
import uuid


class GoalCreate(BaseModel):
    """Schema for creating a new savings goal."""
    goal_name: str = Field(..., max_length=100)
    target_amount: Decimal = Field(..., gt=0)
    current_amount: Decimal = Field(default=Decimal("0"), ge=0)
    target_date: Optional[date] = None


class GoalUpdate(BaseModel):
    """Schema for updating a savings goal."""
    goal_name: Optional[str] = Field(None, max_length=100)
    target_amount: Optional[Decimal] = Field(None, gt=0)
    current_amount: Optional[Decimal] = Field(None, ge=0)
    target_date: Optional[date] = None


class GoalResponse(BaseModel):
    """Schema for savings goal response with progress metrics."""
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    user_id: uuid.UUID
    goal_name: str
    target_amount: Decimal
    current_amount: Decimal
    target_date: Optional[date] = None
    progress_percentage: float
    remaining_amount: Decimal
    days_remaining: Optional[int] = None
    estimated_monthly_saving_needed: Optional[Decimal] = None
    on_track: bool
    created_at: datetime
    updated_at: datetime

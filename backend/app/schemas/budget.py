from pydantic import BaseModel, ConfigDict, Field, EmailStr, field_validator, model_validator
from decimal import Decimal
from datetime import date, datetime
from typing import Optional, List
import uuid


class BudgetCreate(BaseModel):
    """Schema for creating a new budget."""
    category: str
    monthly_limit: Decimal = Field(..., gt=0)


class BudgetUpdate(BaseModel):
    """Schema for updating a budget."""
    monthly_limit: Decimal = Field(..., gt=0)


class BudgetResponse(BaseModel):
    """Schema for budget response with computed spending metrics."""
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    user_id: uuid.UUID
    category: str
    monthly_limit: Decimal
    current_spending: Decimal
    remaining: Decimal
    utilization_percentage: float
    status: str  # 'safe' | 'warning' | 'danger' | 'exceeded'
    created_at: datetime

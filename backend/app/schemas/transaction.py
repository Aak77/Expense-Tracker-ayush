from pydantic import BaseModel, ConfigDict, Field, EmailStr, field_validator, model_validator
from decimal import Decimal
from datetime import date, datetime
from typing import Optional, List
import uuid


EXPENSE_CATEGORIES = [
    "food",
    "transport",
    "shopping",
    "entertainment",
    "bills",
    "health",
    "education",
    "travel",
    "other",
]

INCOME_CATEGORIES = [
    "salary",
    "freelance",
    "investment",
    "gift",
    "other",
]


class TransactionCreate(BaseModel):
    """Schema for creating a new transaction."""
    amount: Decimal = Field(..., gt=0)
    type: str
    category: str
    description: Optional[str] = None
    transaction_date: date

    @field_validator("type")
    @classmethod
    def validate_type(cls, v: str) -> str:
        if v not in ("income", "expense"):
            raise ValueError("Type must be 'income' or 'expense'")
        return v

    @model_validator(mode="after")
    def validate_category_for_type(self) -> "TransactionCreate":
        if self.type == "expense" and self.category not in EXPENSE_CATEGORIES:
            raise ValueError(
                f"Invalid expense category '{self.category}'. "
                f"Must be one of: {', '.join(EXPENSE_CATEGORIES)}"
            )
        if self.type == "income" and self.category not in INCOME_CATEGORIES:
            raise ValueError(
                f"Invalid income category '{self.category}'. "
                f"Must be one of: {', '.join(INCOME_CATEGORIES)}"
            )
        return self


class TransactionUpdate(BaseModel):
    """Schema for updating a transaction."""
    amount: Optional[Decimal] = Field(None, gt=0)
    type: Optional[str] = None
    category: Optional[str] = None
    description: Optional[str] = None
    transaction_date: Optional[date] = None

    @field_validator("type")
    @classmethod
    def validate_type(cls, v: Optional[str]) -> Optional[str]:
        if v is not None and v not in ("income", "expense"):
            raise ValueError("Type must be 'income' or 'expense'")
        return v

    @model_validator(mode="after")
    def validate_category_for_type(self) -> "TransactionUpdate":
        if self.type is not None and self.category is not None:
            if self.type == "expense" and self.category not in EXPENSE_CATEGORIES:
                raise ValueError(
                    f"Invalid expense category '{self.category}'. "
                    f"Must be one of: {', '.join(EXPENSE_CATEGORIES)}"
                )
            if self.type == "income" and self.category not in INCOME_CATEGORIES:
                raise ValueError(
                    f"Invalid income category '{self.category}'. "
                    f"Must be one of: {', '.join(INCOME_CATEGORIES)}"
                )
        return self


class TransactionResponse(BaseModel):
    """Schema for transaction response."""
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    user_id: uuid.UUID
    amount: Decimal
    type: str
    category: str
    description: Optional[str] = None
    transaction_date: date
    created_at: datetime
    updated_at: datetime


class TransactionListResponse(BaseModel):
    """Schema for paginated transaction list response."""
    transactions: List[TransactionResponse]
    total: int
    page: int
    limit: int
    total_pages: int

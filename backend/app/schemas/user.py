from pydantic import BaseModel, ConfigDict, Field, EmailStr, field_validator, model_validator
from decimal import Decimal
from datetime import date, datetime
from typing import Optional, List
import uuid


class UserCreate(BaseModel):
    """Schema for user registration."""
    name: str = Field(..., min_length=2, max_length=100)
    email: EmailStr
    password: str = Field(..., min_length=8)


class UserLogin(BaseModel):
    """Schema for user login."""
    email: EmailStr
    password: str


class UserResponse(BaseModel):
    """Schema for user response."""
    model_config = ConfigDict(from_attributes=True)

    id: uuid.UUID
    name: str
    email: EmailStr
    created_at: datetime
    updated_at: datetime


class UserUpdate(BaseModel):
    """Schema for updating user profile."""
    name: Optional[str] = None
    email: Optional[EmailStr] = None


class PasswordChange(BaseModel):
    """Schema for changing password."""
    current_password: str
    new_password: str = Field(..., min_length=8)


class PasswordReset(BaseModel):
    """Schema for resetting password with token."""
    token: str
    new_password: str = Field(..., min_length=8)


class ForgotPassword(BaseModel):
    """Schema for forgot password request."""
    email: EmailStr


class TokenResponse(BaseModel):
    """Schema for authentication token response."""
    access_token: str
    refresh_token: str
    token_type: str = "bearer"
    user: UserResponse


class RefreshRequest(BaseModel):
    """Schema for token refresh request."""
    refresh_token: str


class AccessTokenResponse(BaseModel):
    """Schema for access token response."""
    access_token: str
    token_type: str = "bearer"

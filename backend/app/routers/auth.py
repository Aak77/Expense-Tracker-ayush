"""
Authentication router for FinTrack.

Handles user registration, login, token refresh, logout, password reset,
and profile management. Rate limiting is applied to auth-sensitive endpoints
via slowapi.
"""

import uuid
from fastapi import APIRouter, Depends, Request
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession

from slowapi import Limiter
from slowapi.util import get_remote_address

from app.database import get_db
from app.middleware.auth_middleware import get_current_user
from app.models.user import User
from app.schemas.user import (
    UserCreate,
    UserLogin,
    UserResponse,
    UserUpdate,
    PasswordChange,
    PasswordReset,
    ForgotPassword,
    TokenResponse,
    RefreshRequest,
    AccessTokenResponse,
)
from app.services.auth_service import (
    hash_password,
    verify_password,
    create_access_token,
    create_refresh_token,
    decode_token,
    store_refresh_token,
    revoke_refresh_token,
    validate_refresh_token,
    generate_reset_token,
    send_reset_email,
)
from app.exceptions import (
    InvalidCredentialsError,
    UserAlreadyExistsError,
    UserNotFoundError,
    TokenInvalidError,
)

router = APIRouter(prefix="/api/v1/auth", tags=["Authentication"])
limiter = Limiter(key_func=get_remote_address)


# ─── Registration ─────────────────────────────────────────────────────────────


@router.post("/register", response_model=TokenResponse)
async def register(data: UserCreate, db: AsyncSession = Depends(get_db)):
    """Register a new user and return authentication tokens."""

    # Check email uniqueness
    stmt = select(User).where(User.email == data.email)
    result = await db.execute(stmt)
    if result.scalar_one_or_none():
        raise UserAlreadyExistsError()

    # Create user
    user = User(
        id=uuid.uuid4(),
        name=data.name,
        email=data.email,
        password_hash=hash_password(data.password),
    )
    db.add(user)
    await db.flush()

    # Generate tokens
    token_data = {"sub": str(user.id)}
    access_token = create_access_token(token_data)
    refresh_token = create_refresh_token(token_data)

    # Persist refresh token
    await store_refresh_token(db, user.id, refresh_token)

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user=UserResponse.model_validate(user),
    )


# ─── Login ────────────────────────────────────────────────────────────────────


@router.post("/login", response_model=TokenResponse)
@limiter.limit("5/minute")
async def login(
    request: Request,
    data: UserLogin,
    db: AsyncSession = Depends(get_db),
):
    """Authenticate a user and return tokens. Rate-limited to 5 req/min."""

    stmt = select(User).where(User.email == data.email)
    result = await db.execute(stmt)
    user = result.scalar_one_or_none()

    if not user or not verify_password(data.password, user.password_hash):
        raise InvalidCredentialsError()

    token_data = {"sub": str(user.id)}
    access_token = create_access_token(token_data)
    refresh_token = create_refresh_token(token_data)

    await store_refresh_token(db, user.id, refresh_token)

    return TokenResponse(
        access_token=access_token,
        refresh_token=refresh_token,
        user=UserResponse.model_validate(user),
    )


# ─── Token Refresh ────────────────────────────────────────────────────────────


@router.post("/refresh", response_model=AccessTokenResponse)
async def refresh(data: RefreshRequest, db: AsyncSession = Depends(get_db)):
    """Validate the refresh token and issue a new access token."""

    # Validate refresh token exists in DB and is not expired
    await validate_refresh_token(db, data.refresh_token)

    # Decode to get user info
    payload = decode_token(data.refresh_token)
    user_id = payload.get("sub")

    # Create new access token
    access_token = create_access_token({"sub": user_id})

    return AccessTokenResponse(access_token=access_token)


# ─── Logout ───────────────────────────────────────────────────────────────────


@router.post("/logout")
async def logout(
    data: RefreshRequest,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Revoke the refresh token (logout)."""

    await revoke_refresh_token(db, data.refresh_token)
    return {"message": "Successfully logged out"}


# ─── Forgot Password ─────────────────────────────────────────────────────────


@router.post("/forgot-password")
@limiter.limit("5/minute")
async def forgot_password(
    request: Request,
    data: ForgotPassword,
    db: AsyncSession = Depends(get_db),
):
    """Generate a password-reset token and send it via email."""

    # Always return success to prevent email enumeration
    stmt = select(User).where(User.email == data.email)
    result = await db.execute(stmt)
    user = result.scalar_one_or_none()

    if user:
        reset_token = generate_reset_token(data.email)
        send_reset_email(data.email, reset_token)

    return {"message": "If the email is registered, a reset link has been sent"}


# ─── Reset Password ──────────────────────────────────────────────────────────


@router.post("/reset-password")
async def reset_password(
    data: PasswordReset,
    db: AsyncSession = Depends(get_db),
):
    """Reset a user's password using a valid reset token."""

    # Decode the reset token
    payload = decode_token(data.token)
    if payload.get("type") != "reset":
        raise TokenInvalidError("Invalid reset token")

    email = payload.get("sub")
    if not email:
        raise TokenInvalidError("Invalid reset token")

    # Find user by email
    stmt = select(User).where(User.email == email)
    result = await db.execute(stmt)
    user = result.scalar_one_or_none()

    if not user:
        raise UserNotFoundError()

    # Update password
    user.password_hash = hash_password(data.new_password)
    await db.flush()

    return {"message": "Password has been reset successfully"}


# ─── Get Current User ─────────────────────────────────────────────────────────


@router.get("/me", response_model=UserResponse)
async def get_me(current_user: User = Depends(get_current_user)):
    """Return the profile of the currently authenticated user."""
    return UserResponse.model_validate(current_user)


# ─── Update Profile ──────────────────────────────────────────────────────────


@router.put("/me", response_model=UserResponse)
async def update_me(
    data: UserUpdate,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Update the current user's name and/or email."""

    if data.email and data.email != current_user.email:
        # Check uniqueness of new email
        stmt = select(User).where(User.email == data.email)
        result = await db.execute(stmt)
        if result.scalar_one_or_none():
            raise UserAlreadyExistsError("This email is already in use")

    if data.name is not None:
        current_user.name = data.name
    if data.email is not None:
        current_user.email = data.email

    await db.flush()
    return UserResponse.model_validate(current_user)


# ─── Change Password ─────────────────────────────────────────────────────────


@router.put("/me/password")
async def change_password(
    data: PasswordChange,
    current_user: User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    """Change the current user's password after verifying the old one."""

    if not verify_password(data.current_password, current_user.password_hash):
        raise InvalidCredentialsError("Current password is incorrect")

    current_user.password_hash = hash_password(data.new_password)
    await db.flush()

    return {"message": "Password changed successfully"}

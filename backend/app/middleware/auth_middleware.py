"""
Authentication middleware (FastAPI dependencies) for FinTrack.

Provides two dependency functions:
- ``get_current_user``   – requires a valid Bearer access token; raises on
  missing / invalid / expired tokens.
- ``get_optional_user``  – returns the user if a valid token is present,
  or ``None`` otherwise (useful for public routes that personalise content).
"""

from fastapi import Depends, Request
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from app.database import get_db
from app.services import auth_service
from app.models.user import User
from app.exceptions import TokenInvalidError
import uuid
import logging

logger = logging.getLogger(__name__)


def _extract_token(request: Request) -> str | None:
    """
    Pull the Bearer token from the Authorization header.

    Returns the raw JWT string, or None if the header is absent / malformed.
    """
    auth_header = request.headers.get("Authorization")
    if not auth_header:
        return None

    parts = auth_header.split()
    if len(parts) != 2 or parts[0].lower() != "bearer":
        return None

    return parts[1]


async def get_current_user(
    request: Request,
    db: AsyncSession = Depends(get_db),
) -> User:
    """
    FastAPI dependency that enforces authentication.

    Extracts and validates the Bearer access token, then returns the
    corresponding ``User`` model instance.

    Raises:
        TokenInvalidError – no token, wrong type, unknown user, or decode
                            failure.
        TokenExpiredError  – bubbled up from ``decode_token`` if the JWT
                            has expired.
    """
    token = _extract_token(request)
    if not token:
        raise TokenInvalidError("Authorization header missing or malformed")

    # decode_token raises TokenExpiredError / TokenInvalidError internally
    payload = auth_service.decode_token(token)

    # Ensure this is an access token, not a refresh or reset token
    if payload.get("type") != "access":
        raise TokenInvalidError("Invalid token type")

    # Retrieve the user referenced by the 'sub' claim
    user_id_str = payload.get("sub")
    if not user_id_str:
        raise TokenInvalidError("Token missing subject claim")

    try:
        user_id = uuid.UUID(user_id_str)
    except (ValueError, AttributeError):
        raise TokenInvalidError("Invalid user ID in token")

    result = await db.execute(
        select(User).where(User.id == user_id)
    )
    user = result.scalar_one_or_none()

    if not user:
        raise TokenInvalidError("User not found")

    logger.debug("Authenticated user %s (%s)", user.email, user.id)
    return user


async def get_optional_user(
    request: Request,
    db: AsyncSession = Depends(get_db),
) -> User | None:
    """
    FastAPI dependency that returns ``None`` when no token is present,
    instead of raising an exception.

    Useful for endpoints that behave differently for authenticated vs
    anonymous visitors.
    """
    token = _extract_token(request)
    if not token:
        return None

    try:
        payload = auth_service.decode_token(token)

        if payload.get("type") != "access":
            return None

        user_id_str = payload.get("sub")
        if not user_id_str:
            return None

        user_id = uuid.UUID(user_id_str)

        result = await db.execute(
            select(User).where(User.id == user_id)
        )
        return result.scalar_one_or_none()

    except Exception:
        # Swallow all token errors – the user is simply treated as anonymous
        return None

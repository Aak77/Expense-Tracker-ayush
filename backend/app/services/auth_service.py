"""
Authentication & token management service for FinTrack.

Handles password hashing (bcrypt), JWT creation/validation (access, refresh,
password-reset tokens), refresh-token persistence, and net-worth snapshot
upserts.
"""

from datetime import datetime, timedelta, timezone, date
from jose import jwt, JWTError, ExpiredSignatureError
import bcrypt
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, delete
from app.config import settings
from app.exceptions import TokenExpiredError, TokenInvalidError
from app.models.user import User, RefreshToken
from app.models.asset import Asset
from app.models.liability import Liability, NetWorthSnapshot
from app.models.transaction import Transaction
import uuid
import logging

logger = logging.getLogger(__name__)

# ─── Password Hashing ────────────────────────────────────────────────────────


def hash_password(password: str) -> str:
    """Hash a plaintext password with bcrypt."""
    pw_bytes = password.encode('utf-8')
    salt = bcrypt.gensalt()
    return bcrypt.hashpw(pw_bytes, salt).decode('utf-8')


def verify_password(plain: str, hashed: str) -> bool:
    """Verify a plaintext password against a bcrypt hash."""
    try:
        pw_bytes = plain.encode('utf-8')
        hashed_bytes = hashed.encode('utf-8')
        return bcrypt.checkpw(pw_bytes, hashed_bytes)
    except Exception:
        return False


# ─── JWT Token Creation ──────────────────────────────────────────────────────

def create_access_token(data: dict) -> str:
    """
    Create a short-lived access JWT.

    The token embeds the user id (as 'sub'), an expiry timestamp, and a
    type discriminator so that access and refresh tokens cannot be
    interchanged.
    """
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(
        minutes=settings.ACCESS_TOKEN_EXPIRE_MINUTES
    )
    to_encode.update({
        "sub": str(data.get("sub", data.get("user_id", ""))),
        "exp": expire,
        "type": "access",
    })
    return jwt.encode(
        to_encode,
        settings.JWT_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )


def create_refresh_token(data: dict) -> str:
    """
    Create a long-lived refresh JWT.

    Stored server-side in the refresh_tokens table so it can be revoked.
    """
    to_encode = data.copy()
    expire = datetime.now(timezone.utc) + timedelta(
        days=settings.REFRESH_TOKEN_EXPIRE_DAYS
    )
    to_encode.update({
        "sub": str(data.get("sub", data.get("user_id", ""))),
        "exp": expire,
        "type": "refresh",
    })
    return jwt.encode(
        to_encode,
        settings.JWT_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )


def decode_token(token: str) -> dict:
    """
    Decode and validate a JWT.

    Raises:
        TokenExpiredError  – if the token's exp claim is in the past.
        TokenInvalidError  – if the token is malformed or tampered with.
    """
    try:
        payload = jwt.decode(
            token,
            settings.JWT_SECRET_KEY,
            algorithms=[settings.JWT_ALGORITHM],
        )
        return payload
    except ExpiredSignatureError:
        raise TokenExpiredError()
    except JWTError:
        raise TokenInvalidError()


# ─── Refresh Token Persistence ────────────────────────────────────────────────

async def store_refresh_token(
    db: AsyncSession, user_id: uuid.UUID, token: str
) -> None:
    """Persist a refresh token so it can be validated / revoked later."""
    payload = decode_token(token)
    expires_at = datetime.fromtimestamp(payload["exp"], tz=timezone.utc)

    refresh_token = RefreshToken(
        id=uuid.uuid4(),
        user_id=user_id,
        token=token,
        expires_at=expires_at,
    )
    db.add(refresh_token)
    await db.flush()
    logger.info("Stored refresh token for user %s", user_id)


async def revoke_refresh_token(db: AsyncSession, token: str) -> None:
    """Delete a refresh token (logout / rotation)."""
    stmt = delete(RefreshToken).where(RefreshToken.token == token)
    await db.execute(stmt)
    await db.flush()
    logger.info("Revoked refresh token")


async def validate_refresh_token(
    db: AsyncSession, token: str
) -> RefreshToken:
    """
    Return the RefreshToken row if it exists and has not expired.

    Raises:
        TokenInvalidError  – token not found in the database.
        TokenExpiredError   – token exists but has passed its expiry.
    """
    stmt = select(RefreshToken).where(RefreshToken.token == token)
    result = await db.execute(stmt)
    refresh_token = result.scalar_one_or_none()

    if not refresh_token:
        raise TokenInvalidError("Refresh token not found")

    if refresh_token.expires_at.replace(tzinfo=timezone.utc) < datetime.now(
        timezone.utc
    ):
        # Clean up the expired row
        await revoke_refresh_token(db, token)
        raise TokenExpiredError("Refresh token has expired")

    return refresh_token


# ─── Password Reset ──────────────────────────────────────────────────────────

def generate_reset_token(email: str) -> str:
    """Create a short-lived JWT (1 hour) for password-reset flows."""
    expire = datetime.now(timezone.utc) + timedelta(hours=1)
    return jwt.encode(
        {"sub": email, "exp": expire, "type": "reset"},
        settings.JWT_SECRET_KEY,
        algorithm=settings.JWT_ALGORITHM,
    )


def send_reset_email(email: str, token: str) -> None:
    """
    Placeholder: log/print the password-reset link.

    In production this would dispatch an email via an SMTP provider or
    transactional email API.
    """
    reset_link = f"http://localhost:3000/reset-password?token={token}"
    logger.info("Password reset link for %s: %s", email, reset_link)
    print(f"[FinTrack] Password reset link for {email}: {reset_link}")


# ─── Net Worth Snapshot ───────────────────────────────────────────────────────

async def update_net_worth_snapshot(
    db: AsyncSession, user_id: uuid.UUID
) -> None:
    """
    Recalculate the user's net worth and upsert a snapshot for the current
    month (snapshot_date = first day of the current month).
    """
    # Total assets
    asset_result = await db.execute(
        select(func.coalesce(func.sum(Asset.amount), 0)).where(
            Asset.user_id == user_id
        )
    )
    total_assets = float(asset_result.scalar())

    # Total liabilities
    liability_result = await db.execute(
        select(func.coalesce(func.sum(Liability.amount), 0)).where(
            Liability.user_id == user_id
        )
    )
    total_liabilities = float(liability_result.scalar())

    if total_assets == 0.0 and total_liabilities == 0.0:
        # Fallback: compute net worth as all-time income minus all-time expenses
        all_income_result = await db.execute(
            select(func.coalesce(func.sum(Transaction.amount), 0)).where(
                Transaction.user_id == user_id,
                Transaction.type == "income",
            )
        )
        all_expense_result = await db.execute(
            select(func.coalesce(func.sum(Transaction.amount), 0)).where(
                Transaction.user_id == user_id,
                Transaction.type == "expense",
            )
        )
        net_worth = float(all_income_result.scalar()) - float(all_expense_result.scalar())
    else:
        net_worth = total_assets - total_liabilities

    snapshot_date = date.today().replace(day=1)

    # Check for existing snapshot this month
    stmt = select(NetWorthSnapshot).where(
        NetWorthSnapshot.user_id == user_id,
        NetWorthSnapshot.snapshot_date == snapshot_date,
    )
    result = await db.execute(stmt)
    snapshot = result.scalar_one_or_none()

    if snapshot:
        # Update existing
        snapshot.total_assets = total_assets
        snapshot.total_liabilities = total_liabilities
        snapshot.net_worth = net_worth
    else:
        # Create new
        snapshot = NetWorthSnapshot(
            id=uuid.uuid4(),
            user_id=user_id,
            total_assets=total_assets,
            total_liabilities=total_liabilities,
            net_worth=net_worth,
            snapshot_date=snapshot_date,
        )
        db.add(snapshot)

    await db.flush()
    logger.info(
        "Net worth snapshot for user %s: assets=%.2f, liabilities=%.2f, "
        "net_worth=%.2f",
        user_id,
        total_assets,
        total_liabilities,
        net_worth,
    )

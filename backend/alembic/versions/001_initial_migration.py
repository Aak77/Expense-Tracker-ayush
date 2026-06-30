"""Initial migration — create all tables

Revision ID: 001_initial
Revises:
Create Date: 2026-06-14

"""
from typing import Sequence, Union

from alembic import op
import sqlalchemy as sa
from sqlalchemy.dialects.postgresql import UUID

# revision identifiers, used by Alembic.
revision: str = "001_initial"
down_revision: Union[str, None] = None
branch_labels: Union[str, Sequence[str], None] = None
depends_on: Union[str, Sequence[str], None] = None


def upgrade() -> None:
    # ─── Users ────────────────────────────────────────────────────────────
    op.create_table(
        "users",
        sa.Column("id", UUID(as_uuid=True), server_default=sa.text("gen_random_uuid()"), primary_key=True),
        sa.Column("name", sa.String(100), nullable=False),
        sa.Column("email", sa.String(255), nullable=False, unique=True),
        sa.Column("password_hash", sa.String(255), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )
    op.create_index("ix_users_email", "users", ["email"], unique=True)

    # ─── Refresh Tokens ───────────────────────────────────────────────────
    op.create_table(
        "refresh_tokens",
        sa.Column("id", UUID(as_uuid=True), server_default=sa.text("gen_random_uuid()"), primary_key=True),
        sa.Column("user_id", UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("token", sa.String(500), nullable=False, unique=True),
        sa.Column("expires_at", sa.DateTime(timezone=True), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )
    op.create_index("ix_refresh_tokens_token", "refresh_tokens", ["token"], unique=True)
    op.create_index("ix_refresh_tokens_user_id", "refresh_tokens", ["user_id"])

    # ─── Transactions ─────────────────────────────────────────────────────
    op.create_table(
        "transactions",
        sa.Column("id", UUID(as_uuid=True), server_default=sa.text("gen_random_uuid()"), primary_key=True),
        sa.Column("user_id", UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("type", sa.String(10), nullable=False),
        sa.Column("category", sa.String(50), nullable=False),
        sa.Column("description", sa.String(255), nullable=True),
        sa.Column("transaction_date", sa.Date, nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )
    op.create_index("ix_transactions_user_id", "transactions", ["user_id"])
    op.create_index("ix_transactions_type", "transactions", ["type"])
    op.create_index("ix_transactions_category", "transactions", ["category"])
    op.create_index("ix_transactions_date", "transactions", ["transaction_date"])

    # ─── Budgets ──────────────────────────────────────────────────────────
    op.create_table(
        "budgets",
        sa.Column("id", UUID(as_uuid=True), server_default=sa.text("gen_random_uuid()"), primary_key=True),
        sa.Column("user_id", UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("category", sa.String(50), nullable=False),
        sa.Column("monthly_limit", sa.Numeric(12, 2), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.UniqueConstraint("user_id", "category", name="uq_user_budget_category"),
    )
    op.create_index("ix_budgets_user_id", "budgets", ["user_id"])

    # ─── Savings Goals ────────────────────────────────────────────────────
    op.create_table(
        "savings_goals",
        sa.Column("id", UUID(as_uuid=True), server_default=sa.text("gen_random_uuid()"), primary_key=True),
        sa.Column("user_id", UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("goal_name", sa.String(100), nullable=False),
        sa.Column("target_amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("current_amount", sa.Numeric(12, 2), server_default=sa.text("0"), nullable=False),
        sa.Column("target_date", sa.Date, nullable=True),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )
    op.create_index("ix_savings_goals_user_id", "savings_goals", ["user_id"])

    # ─── Assets ───────────────────────────────────────────────────────────
    op.create_table(
        "assets",
        sa.Column("id", UUID(as_uuid=True), server_default=sa.text("gen_random_uuid()"), primary_key=True),
        sa.Column("user_id", UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("asset_type", sa.String(50), nullable=False),
        sa.Column("name", sa.String(100), nullable=False),
        sa.Column("amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )
    op.create_index("ix_assets_user_id", "assets", ["user_id"])

    # ─── Liabilities ──────────────────────────────────────────────────────
    op.create_table(
        "liabilities",
        sa.Column("id", UUID(as_uuid=True), server_default=sa.text("gen_random_uuid()"), primary_key=True),
        sa.Column("user_id", UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("liability_type", sa.String(50), nullable=False),
        sa.Column("name", sa.String(100), nullable=False),
        sa.Column("amount", sa.Numeric(12, 2), nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
        sa.Column("updated_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )
    op.create_index("ix_liabilities_user_id", "liabilities", ["user_id"])

    # ─── Net Worth Snapshots ──────────────────────────────────────────────
    op.create_table(
        "net_worth_snapshots",
        sa.Column("id", UUID(as_uuid=True), server_default=sa.text("gen_random_uuid()"), primary_key=True),
        sa.Column("user_id", UUID(as_uuid=True), sa.ForeignKey("users.id", ondelete="CASCADE"), nullable=False),
        sa.Column("total_assets", sa.Numeric(12, 2), nullable=False),
        sa.Column("total_liabilities", sa.Numeric(12, 2), nullable=False),
        sa.Column("net_worth", sa.Numeric(12, 2), nullable=False),
        sa.Column("snapshot_date", sa.Date, nullable=False),
        sa.Column("created_at", sa.DateTime(timezone=True), server_default=sa.func.now()),
    )
    op.create_index("ix_net_worth_snapshots_user_id", "net_worth_snapshots", ["user_id"])
    op.create_index("ix_net_worth_snapshots_date", "net_worth_snapshots", ["snapshot_date"])


def downgrade() -> None:
    op.drop_table("net_worth_snapshots")
    op.drop_table("liabilities")
    op.drop_table("assets")
    op.drop_table("savings_goals")
    op.drop_table("budgets")
    op.drop_table("transactions")
    op.drop_table("refresh_tokens")
    op.drop_table("users")

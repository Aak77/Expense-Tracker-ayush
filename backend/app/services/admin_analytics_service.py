"""
Admin Analytics Service for FinTrack Business Dashboard.
=========================================================

Platform-wide aggregation queries across ALL users for the analytics
dashboard. All responses are fully anonymous — no user names, emails,
or UUIDs are ever returned.
"""

from datetime import date, timedelta
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, desc, extract, case, distinct, and_, literal_column
from app.models.user import User
from app.models.transaction import Transaction
from app.models.budget import Budget
from app.models.savings_goal import SavingsGoal
from app.models.asset import Asset
from app.models.liability import Liability, NetWorthSnapshot
import logging

logger = logging.getLogger(__name__)


# ─── 1. Platform Overview KPIs ───────────────────────────────────────────────

async def get_platform_overview(db: AsyncSession) -> dict:
    """
    Return top-level KPIs across the entire platform.
    All data is aggregate — no individual user info is exposed.
    """
    today = date.today()
    thirty_days_ago = today - timedelta(days=30)

    # Total users
    total_users_result = await db.execute(select(func.count(User.id)))
    total_users = total_users_result.scalar() or 0

    # Active users (made a transaction in last 30 days)
    active_users_result = await db.execute(
        select(func.count(distinct(Transaction.user_id))).where(
            Transaction.transaction_date >= thirty_days_ago
        )
    )
    active_users = active_users_result.scalar() or 0

    # Total transactions
    total_txn_result = await db.execute(select(func.count(Transaction.id)))
    total_transactions = total_txn_result.scalar() or 0

    # Total income
    income_result = await db.execute(
        select(func.coalesce(func.sum(Transaction.amount), 0)).where(
            Transaction.type == "income"
        )
    )
    total_income = float(income_result.scalar())

    # Total expenses
    expense_result = await db.execute(
        select(func.coalesce(func.sum(Transaction.amount), 0)).where(
            Transaction.type == "expense"
        )
    )
    total_expenses = float(expense_result.scalar())

    # Average savings rate
    avg_savings_rate = ((total_income - total_expenses) / total_income * 100) if total_income > 0 else 0.0

    # Users with budgets (budget adoption rate)
    budget_users_result = await db.execute(
        select(func.count(distinct(Budget.user_id)))
    )
    users_with_budgets = budget_users_result.scalar() or 0
    budget_adoption_rate = (users_with_budgets / total_users * 100) if total_users > 0 else 0.0

    # Users with savings goals
    goal_users_result = await db.execute(
        select(func.count(distinct(SavingsGoal.user_id)))
    )
    users_with_goals = goal_users_result.scalar() or 0

    # Goal completion rate (goals where current_amount >= target_amount)
    completed_goals_result = await db.execute(
        select(func.count(SavingsGoal.id)).where(
            SavingsGoal.current_amount >= SavingsGoal.target_amount
        )
    )
    completed_goals = completed_goals_result.scalar() or 0

    total_goals_result = await db.execute(select(func.count(SavingsGoal.id)))
    total_goals = total_goals_result.scalar() or 0
    goal_completion_rate = (completed_goals / total_goals * 100) if total_goals > 0 else 0.0

    # Average net worth (latest snapshot per user)
    avg_nw_result = await db.execute(
        select(func.avg(NetWorthSnapshot.net_worth)).where(
            NetWorthSnapshot.snapshot_date == (
                select(func.max(NetWorthSnapshot.snapshot_date))
                .correlate(None)
                .scalar_subquery()
            )
        )
    )
    avg_net_worth = float(avg_nw_result.scalar() or 0)

    return {
        "total_users": total_users,
        "active_users": active_users,
        "total_transactions": total_transactions,
        "total_income": round(total_income, 2),
        "total_expenses": round(total_expenses, 2),
        "avg_savings_rate": round(avg_savings_rate, 1),
        "budget_adoption_rate": round(budget_adoption_rate, 1),
        "users_with_goals": users_with_goals,
        "goal_completion_rate": round(goal_completion_rate, 1),
        "avg_net_worth": round(avg_net_worth, 2),
    }


# ─── 2. User Growth Over Time ────────────────────────────────────────────────

async def get_user_growth(db: AsyncSession) -> list[dict]:
    """
    Return monthly new user signup counts over the full history.
    No individual user data is included.
    """
    result = await db.execute(
        select(
            extract("year", User.created_at).label("yr"),
            extract("month", User.created_at).label("mo"),
            func.count(User.id).label("new_users"),
        )
        .group_by("yr", "mo")
        .order_by("yr", "mo")
    )
    rows = result.all()

    output = []
    cumulative = 0
    for r in rows:
        cumulative += int(r.new_users)
        output.append({
            "month": f"{int(r.yr)}-{int(r.mo):02d}",
            "new_users": int(r.new_users),
            "cumulative_users": cumulative,
        })
    return output


# ─── 3. Monthly Income vs Expenses Trend ─────────────────────────────────────

async def get_monthly_trend(db: AsyncSession) -> list[dict]:
    """
    Return platform-wide monthly income and expenses aggregated
    across all users.
    """
    result = await db.execute(
        select(
            extract("year", Transaction.transaction_date).label("yr"),
            extract("month", Transaction.transaction_date).label("mo"),
            Transaction.type,
            func.sum(Transaction.amount).label("total"),
        )
        .group_by("yr", "mo", Transaction.type)
        .order_by("yr", "mo")
    )
    rows = result.all()

    trend_map: dict[str, dict] = {}
    for r in rows:
        key = f"{int(r.yr)}-{int(r.mo):02d}"
        if key not in trend_map:
            trend_map[key] = {"month": key, "income": 0.0, "expenses": 0.0}
        if r.type == "income":
            trend_map[key]["income"] = round(float(r.total), 2)
        else:
            trend_map[key]["expenses"] = round(float(r.total), 2)

    return sorted(trend_map.values(), key=lambda x: x["month"])


# ─── 4. Spending by Category ─────────────────────────────────────────────────

async def get_spending_by_category(db: AsyncSession) -> list[dict]:
    """
    Return total expense amount per category across all users.
    """
    result = await db.execute(
        select(
            Transaction.category,
            func.sum(Transaction.amount).label("total"),
            func.count(Transaction.id).label("tx_count"),
        )
        .where(Transaction.type == "expense")
        .group_by(Transaction.category)
        .order_by(desc("total"))
    )
    rows = result.all()
    grand_total = sum(float(r.total) for r in rows) if rows else 0

    return [
        {
            "category": r.category,
            "amount": round(float(r.total), 2),
            "transaction_count": int(r.tx_count),
            "percentage": round((float(r.total) / grand_total * 100) if grand_total > 0 else 0, 1),
        }
        for r in rows
    ]


# ─── 5. Top Merchants ────────────────────────────────────────────────────────

async def get_top_merchants(db: AsyncSession, limit: int = 15) -> list[dict]:
    """
    Return the top merchants by transaction count (expense only).
    Merchant = transaction description. No user info attached.
    """
    result = await db.execute(
        select(
            Transaction.description,
            func.count(Transaction.id).label("tx_count"),
            func.sum(Transaction.amount).label("total_spent"),
        )
        .where(
            Transaction.type == "expense",
            Transaction.description.isnot(None),
        )
        .group_by(Transaction.description)
        .order_by(desc("tx_count"))
        .limit(limit)
    )
    return [
        {
            "merchant": r.description,
            "transaction_count": int(r.tx_count),
            "total_spent": round(float(r.total_spent), 2),
        }
        for r in result.all()
    ]


# ─── 6. User Segments / Persona Distribution ─────────────────────────────────

async def get_user_segments(db: AsyncSession) -> dict:
    """
    Return anonymous aggregate statistics segmented by user behavior:
    - Budget adoption breakdown
    - Savings goal participation
    - Average assets/liabilities
    No individual user data is exposed.
    """
    total_users_result = await db.execute(select(func.count(User.id)))
    total_users = total_users_result.scalar() or 1

    # Budget category popularity
    budget_pop_result = await db.execute(
        select(
            Budget.category,
            func.count(Budget.id).label("cnt"),
        )
        .group_by(Budget.category)
        .order_by(desc("cnt"))
    )
    budget_categories = [
        {"category": r.category, "count": int(r.cnt)}
        for r in budget_pop_result.all()
    ]

    # Savings goal popularity
    goal_pop_result = await db.execute(
        select(
            SavingsGoal.goal_name,
            func.count(SavingsGoal.id).label("cnt"),
            func.avg(
                SavingsGoal.current_amount * 100.0 / func.nullif(SavingsGoal.target_amount, 0)
            ).label("avg_progress"),
        )
        .group_by(SavingsGoal.goal_name)
        .order_by(desc("cnt"))
    )
    goal_categories = [
        {
            "goal_name": r.goal_name,
            "count": int(r.cnt),
            "avg_progress": round(float(r.avg_progress or 0), 1),
        }
        for r in goal_pop_result.all()
    ]

    # Asset type distribution
    asset_dist_result = await db.execute(
        select(
            Asset.asset_type,
            func.count(Asset.id).label("cnt"),
            func.sum(Asset.amount).label("total_value"),
        )
        .group_by(Asset.asset_type)
        .order_by(desc("total_value"))
    )
    asset_types = [
        {
            "asset_type": r.asset_type,
            "count": int(r.cnt),
            "total_value": round(float(r.total_value), 2),
        }
        for r in asset_dist_result.all()
    ]

    # Liability type distribution
    liability_dist_result = await db.execute(
        select(
            Liability.liability_type,
            func.count(Liability.id).label("cnt"),
            func.sum(Liability.amount).label("total_value"),
        )
        .group_by(Liability.liability_type)
        .order_by(desc("total_value"))
    )
    liability_types = [
        {
            "liability_type": r.liability_type,
            "count": int(r.cnt),
            "total_value": round(float(r.total_value), 2),
        }
        for r in liability_dist_result.all()
    ]

    # Users by transaction volume (anonymous histogram)
    tx_per_user_result = await db.execute(
        select(
            func.count(Transaction.id).label("tx_count"),
        )
        .group_by(Transaction.user_id)
    )
    tx_counts = [int(r.tx_count) for r in tx_per_user_result.all()]
    
    # Build histogram buckets
    buckets = {"0-25": 0, "26-50": 0, "51-100": 0, "101-150": 0, "150+": 0}
    for c in tx_counts:
        if c <= 25:
            buckets["0-25"] += 1
        elif c <= 50:
            buckets["26-50"] += 1
        elif c <= 100:
            buckets["51-100"] += 1
        elif c <= 150:
            buckets["101-150"] += 1
        else:
            buckets["150+"] += 1

    activity_histogram = [{"range": k, "users": v} for k, v in buckets.items()]

    return {
        "total_users": total_users,
        "budget_categories": budget_categories,
        "goal_categories": goal_categories,
        "asset_types": asset_types,
        "liability_types": liability_types,
        "activity_histogram": activity_histogram,
    }


# ─── 7. Cohort Retention ─────────────────────────────────────────────────────

async def get_cohort_retention(db: AsyncSession) -> list[dict]:
    """
    Monthly cohort analysis: group users by signup month, then for each
    subsequent month, count how many had at least one transaction.
    Returns anonymous aggregate counts only.
    """
    # Get signup month for each user
    signup_subq = (
        select(
            User.id.label("user_id"),
            func.date_trunc("month", User.created_at).label("signup_month"),
        )
        .subquery()
    )

    # Get distinct (user_id, transaction_month) pairs
    activity_subq = (
        select(
            Transaction.user_id.label("user_id"),
            func.date_trunc("month", Transaction.transaction_date).label("activity_month"),
        )
        .distinct()
        .subquery()
    )

    # Join and compute months_since_signup
    result = await db.execute(
        select(
            signup_subq.c.signup_month,
            func.count(distinct(signup_subq.c.user_id)).label("cohort_size"),
            activity_subq.c.activity_month,
            func.count(distinct(activity_subq.c.user_id)).label("active_count"),
        )
        .join(
            activity_subq,
            signup_subq.c.user_id == activity_subq.c.user_id,
        )
        .where(activity_subq.c.activity_month >= signup_subq.c.signup_month)
        .group_by(signup_subq.c.signup_month, activity_subq.c.activity_month)
        .order_by(signup_subq.c.signup_month, activity_subq.c.activity_month)
    )
    rows = result.all()

    # First get cohort sizes
    cohort_sizes_result = await db.execute(
        select(
            func.date_trunc("month", User.created_at).label("signup_month"),
            func.count(User.id).label("cohort_size"),
        )
        .group_by("signup_month")
        .order_by("signup_month")
    )
    cohort_sizes = {
        r.signup_month: int(r.cohort_size) for r in cohort_sizes_result.all()
    }

    # Build cohort data
    cohort_map: dict[str, dict] = {}
    for r in rows:
        signup_key = r.signup_month.strftime("%Y-%m") if hasattr(r.signup_month, "strftime") else str(r.signup_month)[:7]
        activity_key = r.activity_month.strftime("%Y-%m") if hasattr(r.activity_month, "strftime") else str(r.activity_month)[:7]
        
        if signup_key not in cohort_map:
            cohort_size = cohort_sizes.get(r.signup_month, int(r.cohort_size))
            cohort_map[signup_key] = {
                "signup_month": signup_key,
                "cohort_size": cohort_size,
                "retention": {},
            }
        
        cohort_size = cohort_map[signup_key]["cohort_size"]
        active = int(r.active_count)
        retention_pct = round((active / cohort_size * 100) if cohort_size > 0 else 0, 1)
        cohort_map[signup_key]["retention"][activity_key] = {
            "active_users": active,
            "retention_pct": retention_pct,
        }

    return sorted(cohort_map.values(), key=lambda x: x["signup_month"])


# ─── 8. Anomaly Detection ────────────────────────────────────────────────────

async def get_anomaly_transactions(db: AsyncSession, limit: int = 20) -> list[dict]:
    """
    Return the top largest single expense transactions for anomaly review.
    User identity is fully anonymized — only anonymous user numbers shown.
    """
    # Subquery to assign anonymous row numbers to users (no PII exposed)
    result = await db.execute(
        select(
            Transaction.amount,
            Transaction.category,
            Transaction.description,
            Transaction.transaction_date,
            Transaction.type,
        )
        .where(Transaction.type == "expense")
        .order_by(desc(Transaction.amount))
        .limit(limit)
    )

    return [
        {
            "amount": round(float(r.amount), 2),
            "category": r.category,
            "merchant": r.description,
            "date": r.transaction_date.isoformat() if r.transaction_date else None,
            "type": r.type,
        }
        for r in result.all()
    ]

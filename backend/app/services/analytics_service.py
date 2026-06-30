"""
Analytics service for FinTrack.

Provides aggregated financial data used by the dashboard and chart endpoints:
dashboard summary, spending breakdowns, monthly trends, category comparisons,
and daily spending patterns.
"""

from datetime import datetime, date, timedelta, timezone
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, desc, and_, case, extract
from app.models.transaction import Transaction
from app.models.budget import Budget
from app.models.liability import NetWorthSnapshot
import uuid
import logging

logger = logging.getLogger(__name__)


def _parse_month(month: str | None) -> tuple[date, date]:
    """
    Parse a 'YYYY-MM' string into (first_day, last_day) of that month.
    Defaults to the current month when *month* is None.
    """
    if month:
        dt = datetime.strptime(month, "%Y-%m")
    else:
        dt = datetime.now()

    first_day = dt.replace(day=1).date() if isinstance(dt, datetime) else dt.replace(day=1)

    # last day = first day of next month − 1 day
    if first_day.month == 12:
        last_day = first_day.replace(year=first_day.year + 1, month=1) - timedelta(days=1)
    else:
        last_day = first_day.replace(month=first_day.month + 1) - timedelta(days=1)

    return first_day, last_day


# ─── Dashboard ────────────────────────────────────────────────────────────────

async def get_dashboard_data(
    db: AsyncSession, user_id: uuid.UUID
) -> dict:
    """
    Aggregate the main dashboard payload:
    - current-month income / expenses / savings / savings_rate
    - latest net-worth snapshot
    - 5 most-recent transactions
    - budget alerts (warning / danger / exceeded)
    """
    first_day, last_day = _parse_month(None)

    # ── Income & Expenses ─────────────────────────────────────────────────
    income_result = await db.execute(
        select(func.coalesce(func.sum(Transaction.amount), 0)).where(
            Transaction.user_id == user_id,
            Transaction.type == "income",
            Transaction.date >= first_day,
            Transaction.date <= last_day,
        )
    )
    total_income = float(income_result.scalar())

    expense_result = await db.execute(
        select(func.coalesce(func.sum(Transaction.amount), 0)).where(
            Transaction.user_id == user_id,
            Transaction.type == "expense",
            Transaction.date >= first_day,
            Transaction.date <= last_day,
        )
    )
    total_expenses = float(expense_result.scalar())

    savings = total_income - total_expenses
    savings_rate = (savings / total_income * 100) if total_income > 0 else 0.0

    # ── Net Worth ─────────────────────────────────────────────────────────
    nw_result = await db.execute(
        select(NetWorthSnapshot)
        .where(NetWorthSnapshot.user_id == user_id)
        .order_by(desc(NetWorthSnapshot.snapshot_date))
        .limit(1)
    )
    nw_snapshot = nw_result.scalar_one_or_none()
    net_worth = float(nw_snapshot.net_worth) if nw_snapshot else 0.0

    # ── Recent Transactions ───────────────────────────────────────────────
    txn_result = await db.execute(
        select(Transaction)
        .where(Transaction.user_id == user_id)
        .order_by(desc(Transaction.date), desc(Transaction.created_at))
        .limit(5)
    )
    recent_transactions = [
        {
            "id": str(t.id),
            "type": t.type,
            "category": t.category,
            "amount": float(t.amount),
            "description": t.description,
            "date": t.date.isoformat() if t.date else None,
        }
        for t in txn_result.scalars().all()
    ]

    # ── Budget Alerts ─────────────────────────────────────────────────────
    budget_result = await db.execute(
        select(Budget).where(Budget.user_id == user_id)
    )
    budgets = budget_result.scalars().all()

    budget_alerts = []
    for b in budgets:
        # Sum expenses for this budget's category in the current period
        spent_result = await db.execute(
            select(func.coalesce(func.sum(Transaction.amount), 0)).where(
                Transaction.user_id == user_id,
                Transaction.type == "expense",
                Transaction.category == b.category,
                Transaction.date >= first_day,
                Transaction.date <= last_day,
            )
        )
        spent = float(spent_result.scalar())
        limit_amount = float(b.amount)

        if limit_amount <= 0:
            continue

        utilization = (spent / limit_amount) * 100

        if utilization >= 100:
            status = "exceeded"
        elif utilization >= 85:
            status = "danger"
        elif utilization >= 70:
            status = "warning"
        else:
            continue  # healthy – skip

        budget_alerts.append({
            "id": str(b.id),
            "category": b.category,
            "limit": limit_amount,
            "spent": spent,
            "utilization": round(utilization, 1),
            "status": status,
        })

    return {
        "total_income": total_income,
        "total_expenses": total_expenses,
        "savings": savings,
        "savings_rate": round(savings_rate, 1),
        "net_worth": net_worth,
        "recent_transactions": recent_transactions,
        "budget_alerts": budget_alerts,
    }


# ─── Spending by Category ────────────────────────────────────────────────────

async def get_spending_by_category(
    db: AsyncSession,
    user_id: uuid.UUID,
    month: str = None,
) -> list[dict]:
    """
    Return a list of {category, amount, percentage} for expense transactions
    in the given month, grouped by category.
    """
    first_day, last_day = _parse_month(month)

    result = await db.execute(
        select(
            Transaction.category,
            func.sum(Transaction.amount).label("total"),
        )
        .where(
            Transaction.user_id == user_id,
            Transaction.type == "expense",
            Transaction.date >= first_day,
            Transaction.date <= last_day,
        )
        .group_by(Transaction.category)
        .order_by(desc("total"))
    )
    rows = result.all()

    grand_total = sum(float(r.total) for r in rows) if rows else 0

    return [
        {
            "category": r.category,
            "amount": float(r.total),
            "percentage": round(
                (float(r.total) / grand_total * 100) if grand_total > 0 else 0,
                1,
            ),
        }
        for r in rows
    ]


# ─── Monthly Trend ────────────────────────────────────────────────────────────

async def get_monthly_trend(
    db: AsyncSession,
    user_id: uuid.UUID,
    months: int = 6,
) -> list[dict]:
    """
    Return [{month, income, expenses}] for the last *months* months, ordered
    chronologically.
    """
    today = date.today()
    # Start from N months ago
    start_month = (today.month - months) % 12 or 12
    start_year = today.year - ((months - today.month) // 12 + (1 if today.month - months <= 0 else 0))
    start_date = date(start_year, start_month, 1)

    result = await db.execute(
        select(
            extract("year", Transaction.date).label("yr"),
            extract("month", Transaction.date).label("mo"),
            Transaction.type,
            func.sum(Transaction.amount).label("total"),
        )
        .where(
            Transaction.user_id == user_id,
            Transaction.date >= start_date,
        )
        .group_by("yr", "mo", Transaction.type)
        .order_by("yr", "mo")
    )
    rows = result.all()

    # Pivot into {(year, month): {income: x, expenses: y}}
    trend_map: dict[tuple[int, int], dict] = {}
    for r in rows:
        key = (int(r.yr), int(r.mo))
        if key not in trend_map:
            trend_map[key] = {"income": 0.0, "expenses": 0.0}
        if r.type == "income":
            trend_map[key]["income"] = float(r.total)
        else:
            trend_map[key]["expenses"] = float(r.total)

    # Fill in missing months with zeroes
    output: list[dict] = []
    current = start_date
    while current <= today:
        key = (current.year, current.month)
        data = trend_map.get(key, {"income": 0.0, "expenses": 0.0})
        output.append({
            "month": current.strftime("%Y-%m"),
            "income": data["income"],
            "expenses": data["expenses"],
        })
        # Advance to next month
        if current.month == 12:
            current = current.replace(year=current.year + 1, month=1)
        else:
            current = current.replace(month=current.month + 1)

    return output


# ─── Category Comparison (bar chart) ─────────────────────────────────────────

async def get_category_comparison(
    db: AsyncSession,
    user_id: uuid.UUID,
    month: str = None,
) -> list[dict]:
    """Return [{category, amount}] for all expense categories in a month."""
    first_day, last_day = _parse_month(month)

    result = await db.execute(
        select(
            Transaction.category,
            func.sum(Transaction.amount).label("total"),
        )
        .where(
            Transaction.user_id == user_id,
            Transaction.type == "expense",
            Transaction.date >= first_day,
            Transaction.date <= last_day,
        )
        .group_by(Transaction.category)
        .order_by(desc("total"))
    )
    return [
        {"category": r.category, "amount": float(r.total)}
        for r in result.all()
    ]


# ─── Daily Spending ──────────────────────────────────────────────────────────

async def get_daily_spending(
    db: AsyncSession,
    user_id: uuid.UUID,
    month: str = None,
) -> list[dict]:
    """Return [{date, amount}] for each day in a month."""
    first_day, last_day = _parse_month(month)

    result = await db.execute(
        select(
            Transaction.date,
            func.sum(Transaction.amount).label("total"),
        )
        .where(
            Transaction.user_id == user_id,
            Transaction.type == "expense",
            Transaction.date >= first_day,
            Transaction.date <= last_day,
        )
        .group_by(Transaction.date)
        .order_by(Transaction.date)
    )
    rows = result.all()

    # Build a complete calendar so the chart has no gaps
    spending_map = {r.date: float(r.total) for r in rows}
    output: list[dict] = []
    current = first_day
    end = min(last_day, date.today())
    while current <= end:
        output.append({
            "date": current.isoformat(),
            "amount": spending_map.get(current, 0.0),
        })
        current += timedelta(days=1)

    return output

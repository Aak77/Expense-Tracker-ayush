"""
Insights engine for FinTrack.

Analyses the user's financial data and produces 6-10 actionable insight
cards covering spending trends, budget health, savings rate, goal progress,
and net-worth changes.
"""

from datetime import datetime, date, timedelta, timezone
from calendar import monthrange
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select, func, desc, extract
from app.models.transaction import Transaction
from app.models.budget import Budget
from app.models.savings_goal import SavingsGoal
from app.models.liability import NetWorthSnapshot
import uuid
import logging

logger = logging.getLogger(__name__)


# ─── Helpers ──────────────────────────────────────────────────────────────────

def format_inr(amount: float) -> str:
    """
    Format *amount* in the Indian numbering system with the ₹ symbol.

    Examples:
        format_inr(123456.78)  -> '₹1,23,456.78'
        format_inr(1000)       -> '₹1,000.00'
        format_inr(45.5)       -> '₹45.50'
    """
    is_negative = amount < 0
    amount = abs(amount)

    integer_part = int(amount)
    decimal_part = f"{amount - integer_part:.2f}"[1:]  # e.g. ".78"

    s = str(integer_part)
    if len(s) <= 3:
        formatted = s
    else:
        # Last 3 digits, then groups of 2
        last3 = s[-3:]
        remaining = s[:-3]
        groups = []
        while remaining:
            groups.append(remaining[-2:])
            remaining = remaining[:-2]
        groups.reverse()
        formatted = ",".join(groups) + "," + last3

    result = f"₹{formatted}{decimal_part}"
    return f"-{result}" if is_negative else result


def _current_month_range() -> tuple[date, date]:
    """Return (first_day, last_day) of the current month."""
    today = date.today()
    first = today.replace(day=1)
    _, days = monthrange(today.year, today.month)
    last = today.replace(day=days)
    return first, last


def _prev_month_range() -> tuple[date, date]:
    """Return (first_day, last_day) of the previous month."""
    today = date.today()
    first_this = today.replace(day=1)
    last_prev = first_this - timedelta(days=1)
    first_prev = last_prev.replace(day=1)
    return first_prev, last_prev


# ─── Main Entry Point ────────────────────────────────────────────────────────

async def generate_insights(
    db: AsyncSession, user_id: uuid.UUID
) -> list[dict]:
    """
    Run a battery of financial analyses and return a list of insight dicts.

    Each insight has: id, type (warning|positive|info|danger), icon, title,
    description, action.
    """
    insights: list[dict] = []
    today = date.today()
    first_day, last_day = _current_month_range()
    prev_first, prev_last = _prev_month_range()
    days_elapsed = max((today - first_day).days + 1, 1)
    _, days_in_month = monthrange(today.year, today.month)

    # ── Fetch current-month totals ────────────────────────────────────────
    cur_expense_result = await db.execute(
        select(func.coalesce(func.sum(Transaction.amount), 0)).where(
            Transaction.user_id == user_id,
            Transaction.type == "expense",
            Transaction.transaction_date >= first_day,
            Transaction.transaction_date <= last_day,
        )
    )
    cur_expenses = float(cur_expense_result.scalar())

    cur_income_result = await db.execute(
        select(func.coalesce(func.sum(Transaction.amount), 0)).where(
            Transaction.user_id == user_id,
            Transaction.type == "income",
            Transaction.transaction_date >= first_day,
            Transaction.transaction_date <= last_day,
        )
    )
    cur_income = float(cur_income_result.scalar())

    # ── Fetch previous-month totals ───────────────────────────────────────
    prev_expense_result = await db.execute(
        select(func.coalesce(func.sum(Transaction.amount), 0)).where(
            Transaction.user_id == user_id,
            Transaction.type == "expense",
            Transaction.transaction_date >= prev_first,
            Transaction.transaction_date <= prev_last,
        )
    )
    prev_expenses = float(prev_expense_result.scalar())

    # ── 1. Month-over-month spending change ───────────────────────────────
    if prev_expenses > 0:
        pct_change = ((cur_expenses - prev_expenses) / prev_expenses) * 100
        if pct_change > 10:
            insights.append({
                "id": "insight_001",
                "type": "warning",
                "icon": "trending_up",
                "title": f"Spending up {pct_change:.0f}% this month",
                "description": (
                    f"You've spent {format_inr(cur_expenses)} so far vs "
                    f"{format_inr(prev_expenses)} all of last month."
                ),
                "action": None,
            })
        elif pct_change < -10:
            insights.append({
                "id": "insight_001",
                "type": "positive",
                "icon": "trending_down",
                "title": f"Spending down {abs(pct_change):.0f}% this month",
                "description": (
                    f"You've spent {format_inr(cur_expenses)} so far vs "
                    f"{format_inr(prev_expenses)} last month. Great job!"
                ),
                "action": None,
            })

    # ── 2. Top spending category ──────────────────────────────────────────
    top_cat_result = await db.execute(
        select(
            Transaction.category,
            func.sum(Transaction.amount).label("total"),
        )
        .where(
            Transaction.user_id == user_id,
            Transaction.type == "expense",
            Transaction.transaction_date >= first_day,
            Transaction.transaction_date <= last_day,
        )
        .group_by(Transaction.category)
        .order_by(desc("total"))
        .limit(1)
    )
    top_row = top_cat_result.first()
    if top_row:
        insights.append({
            "id": "insight_002",
            "type": "info",
            "icon": top_row.category.lower() if top_row.category else "category",
            "title": f"Top category: {top_row.category}",
            "description": (
                f"You spent {format_inr(float(top_row.total))} on "
                f"{top_row.category} this month."
            ),
            "action": None,
        })

    # ── 3. Average daily spending ─────────────────────────────────────────
    avg_daily = cur_expenses / days_elapsed
    insights.append({
        "id": "insight_003",
        "type": "info",
        "icon": "calendar",
        "title": f"Avg. daily spending: {format_inr(avg_daily)}",
        "description": (
            f"Over the last {days_elapsed} days you averaged "
            f"{format_inr(avg_daily)} per day."
        ),
        "action": None,
    })

    # ── 4. Projected monthly spending ─────────────────────────────────────
    projected = (cur_expenses / days_elapsed) * days_in_month
    if cur_income > 0 and projected > cur_income:
        insights.append({
            "id": "insight_004",
            "type": "danger",
            "icon": "warning",
            "title": f"Projected spending: {format_inr(projected)}",
            "description": (
                f"At this pace you'll spend {format_inr(projected)}, exceeding "
                f"your income of {format_inr(cur_income)}."
            ),
            "action": None,
        })
    else:
        insights.append({
            "id": "insight_004",
            "type": "info",
            "icon": "analytics",
            "title": f"Projected spending: {format_inr(projected)}",
            "description": (
                f"At current pace, you'll spend {format_inr(projected)} "
                f"this month."
            ),
            "action": None,
        })

    # ── 5. Budget danger alerts ───────────────────────────────────────────
    budget_result = await db.execute(
        select(Budget).where(Budget.user_id == user_id)
    )
    budgets = budget_result.scalars().all()

    for b in budgets:
        if b.category.lower() == "global":
            spent_result = await db.execute(
                select(func.coalesce(func.sum(Transaction.amount), 0)).where(
                    Transaction.user_id == user_id,
                    Transaction.type == "expense",
                    Transaction.transaction_date >= first_day,
                    Transaction.transaction_date <= last_day,
                )
            )
        else:
            spent_result = await db.execute(
                select(func.coalesce(func.sum(Transaction.amount), 0)).where(
                    Transaction.user_id == user_id,
                    Transaction.type == "expense",
                    Transaction.category == b.category,
                    Transaction.transaction_date >= first_day,
                    Transaction.transaction_date <= last_day,
                )
            )
        spent = float(spent_result.scalar())
        limit_amt = float(b.monthly_limit)
        if limit_amt > 0:
            utilization = (spent / limit_amt) * 100
            if utilization > 85:
                insights.append({
                    "id": f"insight_005_{b.category.lower().replace(' ', '_')}",
                    "type": "danger",
                    "icon": b.category.lower(),
                    "title": f"{b.category} budget at {utilization:.0f}%",
                    "description": (
                        f"You've used {format_inr(spent)} of your "
                        f"{format_inr(limit_amt)} {b.category} budget."
                    ),
                    "action": None,
                })

    # ── 6. Savings rate ───────────────────────────────────────────────────
    if cur_income > 0:
        savings_rate = ((cur_income - cur_expenses) / cur_income) * 100
        if savings_rate < 20:
            insights.append({
                "id": "insight_006",
                "type": "warning",
                "icon": "savings",
                "title": f"Savings rate: {savings_rate:.1f}%",
                "description": (
                    f"You're saving only {savings_rate:.1f}% of your income. "
                    "Aim for at least 20%."
                ),
                "action": None,
            })
        elif savings_rate > 40:
            insights.append({
                "id": "insight_006",
                "type": "positive",
                "icon": "savings",
                "title": f"Excellent savings rate: {savings_rate:.1f}%",
                "description": (
                    f"You're saving {savings_rate:.1f}% of your income this "
                    "month. Outstanding discipline!"
                ),
                "action": None,
            })
        else:
            insights.append({
                "id": "insight_006",
                "type": "info",
                "icon": "savings",
                "title": f"Savings rate: {savings_rate:.1f}%",
                "description": (
                    f"You're saving {savings_rate:.1f}% of your income. "
                    "Keep it up!"
                ),
                "action": None,
            })

    # ── 7. Consecutive month trend ────────────────────────────────────────
    # Look back 3 months for each category
    three_months_ago = today.replace(day=1)
    for _ in range(3):
        three_months_ago = (three_months_ago - timedelta(days=1)).replace(day=1)

    trend_result = await db.execute(
        select(
            Transaction.category,
            extract("year", Transaction.transaction_date).label("yr"),
            extract("month", Transaction.transaction_date).label("mo"),
            func.sum(Transaction.amount).label("total"),
        )
        .where(
            Transaction.user_id == user_id,
            Transaction.type == "expense",
            Transaction.transaction_date >= three_months_ago,
        )
        .group_by(Transaction.category, "yr", "mo")
        .order_by(Transaction.category, "yr", "mo")
    )
    trend_rows = trend_result.all()

    # Group by category → sorted list of monthly totals
    cat_trends: dict[str, list[float]] = {}
    for r in trend_rows:
        cat_trends.setdefault(r.category, []).append(float(r.total))

    for category, totals in cat_trends.items():
        if len(totals) >= 3:
            # Check if the last 3 values are strictly increasing
            if all(totals[i] < totals[i + 1] for i in range(len(totals) - 3, len(totals) - 1)):
                insights.append({
                    "id": f"insight_007_{category.lower().replace(' ', '_')}",
                    "type": "warning",
                    "icon": category.lower(),
                    "title": f"{category} rising for 3+ months",
                    "description": (
                        f"Your {category} spending has increased for 3 "
                        "consecutive months. Consider reviewing."
                    ),
                    "action": None,
                })

    # ── 8. Goal milestone alerts ──────────────────────────────────────────
    goal_result = await db.execute(
        select(SavingsGoal).where(SavingsGoal.user_id == user_id)
    )
    goals = goal_result.scalars().all()

    milestones = [25, 50, 75, 100]
    for g in goals:
        target = float(g.target_amount)
        current = float(g.current_amount)
        if target > 0:
            progress = (current / target) * 100
            for m in milestones:
                if progress >= m and progress < m + 25:
                    insights.append({
                        "id": f"insight_008_{str(g.id)[:8]}",
                        "type": "positive",
                        "icon": "flag",
                        "title": f"🎯 {g.goal_name}: {m}% reached!",
                        "description": (
                            f"You've saved {format_inr(current)} of your "
                            f"{format_inr(target)} goal for {g.goal_name}."
                        ),
                        "action": None,
                    })
                    break  # only show the highest milestone

    # ── 9. Savings suggestion ─────────────────────────────────────────────
    if cur_expenses > 0:
        cat_spend_result = await db.execute(
            select(
                Transaction.category,
                func.sum(Transaction.amount).label("total"),
            )
            .where(
                Transaction.user_id == user_id,
                Transaction.type == "expense",
                Transaction.transaction_date >= first_day,
                Transaction.transaction_date <= last_day,
            )
            .group_by(Transaction.category)
        )
        cat_spends = cat_spend_result.all()

        for cs in cat_spends:
            cat_name = cs.category.lower() if cs.category else ""
            cat_total = float(cs.total)
            pct_of_total = (cat_total / cur_expenses) * 100

            if cat_name in ("food", "entertainment", "dining", "eating out") and pct_of_total > 30:
                insights.append({
                    "id": f"insight_009_{cat_name}",
                    "type": "info",
                    "icon": cat_name,
                    "title": f"{cs.category} is {pct_of_total:.0f}% of expenses",
                    "description": (
                        f"You spent {format_inr(cat_total)} on {cs.category} "
                        f"({pct_of_total:.0f}% of total). Consider reducing "
                        "to save more."
                    ),
                    "action": None,
                })

    # ── 10. Net worth change ──────────────────────────────────────────────
    nw_result = await db.execute(
        select(NetWorthSnapshot)
        .where(NetWorthSnapshot.user_id == user_id)
        .order_by(desc(NetWorthSnapshot.snapshot_date))
        .limit(2)
    )
    snapshots = nw_result.scalars().all()

    if len(snapshots) >= 2:
        current_nw = float(snapshots[0].net_worth)
        prev_nw = float(snapshots[1].net_worth)
        nw_change = current_nw - prev_nw

        if nw_change > 0:
            insights.append({
                "id": "insight_010",
                "type": "positive",
                "icon": "account_balance",
                "title": f"Net worth up {format_inr(nw_change)}",
                "description": (
                    f"Your net worth increased from {format_inr(prev_nw)} "
                    f"to {format_inr(current_nw)} this month."
                ),
                "action": None,
            })
        elif nw_change < 0:
            insights.append({
                "id": "insight_010",
                "type": "warning",
                "icon": "account_balance",
                "title": f"Net worth down {format_inr(abs(nw_change))}",
                "description": (
                    f"Your net worth decreased from {format_inr(prev_nw)} "
                    f"to {format_inr(current_nw)} this month."
                ),
                "action": None,
            })

    logger.info(
        "Generated %d insights for user %s", len(insights), user_id
    )
    return insights

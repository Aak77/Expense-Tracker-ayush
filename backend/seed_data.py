"""
FinTrack Seed Data Script
=========================
Populates the database with realistic Indian transaction data for testing.

Usage:
    python seed_data.py

Requires DATABASE_URL and JWT_SECRET_KEY in .env file.
"""

import asyncio
import random
from datetime import date, timedelta
from decimal import Decimal

from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker

from app.config import settings
from app.database import Base
from app.models.user import User
from app.models.transaction import Transaction
from app.models.budget import Budget
from app.models.savings_goal import SavingsGoal
from app.models.asset import Asset
from app.models.liability import Liability, NetWorthSnapshot
from app.services.auth_service import hash_password


# ─── Seed Data Constants ─────────────────────────────────────────────────────

EXPENSE_TRANSACTIONS = [
    # Food & Dining
    {"category": "food", "description": "Swiggy - Biryani order", "amount": (150, 650)},
    {"category": "food", "description": "Zomato - Pizza delivery", "amount": (200, 800)},
    {"category": "food", "description": "Blinkit - Groceries", "amount": (300, 1500)},
    {"category": "food", "description": "BigBasket - Monthly groceries", "amount": (2000, 5000)},
    {"category": "food", "description": "DMart - Weekly shopping", "amount": (500, 2500)},
    {"category": "food", "description": "Chai & snacks - office canteen", "amount": (30, 100)},
    {"category": "food", "description": "Dominos - Weekend treat", "amount": (300, 900)},
    {"category": "food", "description": "Haldiram's - Namkeen & sweets", "amount": (150, 500)},

    # Transport
    {"category": "transport", "description": "Uber ride - Office commute", "amount": (100, 400)},
    {"category": "transport", "description": "Ola ride - Airport transfer", "amount": (300, 1200)},
    {"category": "transport", "description": "Delhi Metro recharge", "amount": (200, 500)},
    {"category": "transport", "description": "Petrol - Indian Oil", "amount": (500, 3000)},
    {"category": "transport", "description": "IRCTC - Train tickets", "amount": (300, 2500)},
    {"category": "transport", "description": "Rapido bike ride", "amount": (50, 200)},

    # Shopping
    {"category": "shopping", "description": "Amazon India - Electronics", "amount": (500, 15000)},
    {"category": "shopping", "description": "Flipkart - Fashion sale", "amount": (300, 5000)},
    {"category": "shopping", "description": "Myntra - Clothes shopping", "amount": (500, 4000)},
    {"category": "shopping", "description": "Reliance Digital - Accessories", "amount": (200, 8000)},
    {"category": "shopping", "description": "Nykaa - Skincare", "amount": (300, 2000)},
    {"category": "shopping", "description": "Croma - Headphones", "amount": (500, 5000)},

    # Entertainment
    {"category": "entertainment", "description": "Netflix subscription", "amount": (199, 649)},
    {"category": "entertainment", "description": "Spotify Premium", "amount": (119, 179)},
    {"category": "entertainment", "description": "Disney+ Hotstar", "amount": (149, 299)},
    {"category": "entertainment", "description": "BookMyShow - Movie tickets", "amount": (200, 800)},
    {"category": "entertainment", "description": "Amazon Prime subscription", "amount": (179, 1499)},
    {"category": "entertainment", "description": "PVR INOX - Weekend movie", "amount": (300, 1000)},

    # Bills & Utilities
    {"category": "bills", "description": "Jio prepaid recharge", "amount": (199, 999)},
    {"category": "bills", "description": "Airtel broadband", "amount": (499, 1499)},
    {"category": "bills", "description": "Electricity bill - Tata Power", "amount": (500, 3000)},
    {"category": "bills", "description": "Water bill - Municipal", "amount": (100, 500)},
    {"category": "bills", "description": "Gas bill - Indane LPG", "amount": (800, 1100)},
    {"category": "bills", "description": "House rent", "amount": (8000, 25000)},
    {"category": "bills", "description": "Society maintenance", "amount": (1000, 5000)},

    # Health
    {"category": "health", "description": "Apollo Pharmacy - Medicines", "amount": (100, 2000)},
    {"category": "health", "description": "Doctor consultation - Practo", "amount": (300, 1500)},
    {"category": "health", "description": "Gym membership - Cult.fit", "amount": (500, 2000)},
    {"category": "health", "description": "Star Health Insurance premium", "amount": (1000, 5000)},

    # Education
    {"category": "education", "description": "Udemy course purchase", "amount": (299, 1999)},
    {"category": "education", "description": "Unacademy subscription", "amount": (500, 3000)},
    {"category": "education", "description": "Books from Amazon", "amount": (200, 1500)},

    # Travel
    {"category": "travel", "description": "MakeMyTrip - Hotel booking", "amount": (1500, 8000)},
    {"category": "travel", "description": "Goibibo - Flight tickets", "amount": (2000, 12000)},
    {"category": "travel", "description": "OYO rooms - Weekend getaway", "amount": (800, 3000)},
]

INCOME_TRANSACTIONS = [
    {"category": "salary", "description": "Monthly salary - TCS", "amount": (35000, 85000)},
    {"category": "salary", "description": "Monthly salary - Infosys", "amount": (40000, 95000)},
    {"category": "salary", "description": "Monthly salary - Wipro", "amount": (30000, 75000)},
    {"category": "freelance", "description": "Upwork - Web development project", "amount": (5000, 25000)},
    {"category": "freelance", "description": "Fiverr - Logo design", "amount": (2000, 10000)},
    {"category": "investment", "description": "Zerodha - Mutual fund returns", "amount": (1000, 8000)},
    {"category": "investment", "description": "SBI FD interest", "amount": (500, 5000)},
    {"category": "gift", "description": "Diwali bonus", "amount": (5000, 20000)},
    {"category": "gift", "description": "Birthday gift from family", "amount": (1000, 10000)},
    {"category": "other", "description": "Cashback - CRED", "amount": (50, 500)},
]

BUDGETS = [
    {"category": "food", "monthly_limit": 8000},
    {"category": "transport", "monthly_limit": 3000},
    {"category": "shopping", "monthly_limit": 5000},
    {"category": "entertainment", "monthly_limit": 2000},
    {"category": "bills", "monthly_limit": 15000},
    {"category": "health", "monthly_limit": 3000},
    {"category": "education", "monthly_limit": 2000},
    {"category": "travel", "monthly_limit": 5000},
]

SAVINGS_GOALS = [
    {
        "goal_name": "Emergency Fund",
        "target_amount": 200000,
        "current_amount": 85000,
        "target_date": date(2027, 3, 31),
    },
    {
        "goal_name": "Goa Trip",
        "target_amount": 40000,
        "current_amount": 12000,
        "target_date": date(2026, 12, 15),
    },
    {
        "goal_name": "New MacBook Pro",
        "target_amount": 180000,
        "current_amount": 45000,
        "target_date": date(2027, 6, 30),
    },
    {
        "goal_name": "Wedding Fund",
        "target_amount": 500000,
        "current_amount": 120000,
        "target_date": date(2028, 12, 31),
    },
]

ASSETS = [
    {"asset_type": "bank_account", "name": "HDFC Savings Account", "amount": 125000},
    {"asset_type": "bank_account", "name": "SBI Savings Account", "amount": 45000},
    {"asset_type": "fixed_deposit", "name": "SBI FD - 2 Year", "amount": 100000},
    {"asset_type": "mutual_fund", "name": "Zerodha - Nifty 50 Index Fund", "amount": 65000},
    {"asset_type": "mutual_fund", "name": "Groww - HDFC Mid Cap Fund", "amount": 35000},
    {"asset_type": "investment", "name": "PPF Account", "amount": 80000},
    {"asset_type": "cash", "name": "Cash in hand", "amount": 5000},
]

LIABILITIES = [
    {"liability_type": "credit_card", "name": "HDFC Regalia Credit Card", "amount": 18500},
    {"liability_type": "credit_card", "name": "ICICI Amazon Pay Card", "amount": 7200},
    {"liability_type": "loan", "name": "Education Loan - SBI", "amount": 350000},
    {"liability_type": "borrowed_money", "name": "Borrowed from Rahul", "amount": 5000},
]


def random_amount(amount_range: tuple) -> Decimal:
    """Generate a random amount within the given range, rounded to 2 decimal places."""
    return Decimal(str(round(random.uniform(amount_range[0], amount_range[1]), 2)))


def random_date_in_range(start: date, end: date) -> date:
    """Generate a random date between start and end."""
    delta = (end - start).days
    return start + timedelta(days=random.randint(0, delta))


async def seed_database():
    """Populate the database with seed data."""
    engine = create_async_engine(settings.DATABASE_URL, echo=False)
    async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as db:
        # ─── Create Demo User ────────────────────────────────────────────
        print("🔐 Creating demo user...")
        demo_user = User(
            name="Ayush Kamble",
            email="ayush@fintrack.app",
            password_hash=hash_password("password123"),
        )
        db.add(demo_user)
        await db.flush()
        user_id = demo_user.id
        print(f"   ✅ User created: {demo_user.email} (ID: {user_id})")

        # ─── Generate Transactions (last 6 months) ───────────────────────
        print("💰 Generating transactions...")
        today = date.today()
        six_months_ago = today - timedelta(days=180)
        transaction_count = 0

        # Generate income transactions (1–2 per month for 6 months)
        for month_offset in range(6):
            month_start = date(today.year, today.month, 1) - timedelta(days=30 * month_offset)
            if month_start.month == 0:
                month_start = month_start.replace(year=month_start.year - 1, month=12)

            # Salary (once per month)
            salary_entry = random.choice(INCOME_TRANSACTIONS[:3])
            salary_txn = Transaction(
                user_id=user_id,
                amount=random_amount((45000, 65000)),
                type="income",
                category="salary",
                description=salary_entry["description"],
                transaction_date=month_start.replace(day=1),
            )
            db.add(salary_txn)
            transaction_count += 1

            # Occasional other income
            if random.random() > 0.5:
                other_income = random.choice(INCOME_TRANSACTIONS[3:])
                db.add(Transaction(
                    user_id=user_id,
                    amount=random_amount(other_income["amount"]),
                    type="income",
                    category=other_income["category"],
                    description=other_income["description"],
                    transaction_date=random_date_in_range(
                        month_start.replace(day=1),
                        month_start.replace(day=min(28, (month_start.replace(day=1) + timedelta(days=31)).day))
                    ),
                ))
                transaction_count += 1

        # Generate expense transactions (30–50 per month for 6 months)
        for month_offset in range(6):
            month_start = today - timedelta(days=30 * month_offset)
            month_end = month_start
            month_start = month_start - timedelta(days=29)

            num_expenses = random.randint(30, 50)
            for _ in range(num_expenses):
                expense = random.choice(EXPENSE_TRANSACTIONS)
                txn = Transaction(
                    user_id=user_id,
                    amount=random_amount(expense["amount"]),
                    type="expense",
                    category=expense["category"],
                    description=expense["description"],
                    transaction_date=random_date_in_range(month_start, month_end),
                )
                db.add(txn)
                transaction_count += 1

        print(f"   ✅ Created {transaction_count} transactions")

        # ─── Create Budgets ───────────────────────────────────────────────
        print("📊 Creating budgets...")
        for budget_data in BUDGETS:
            db.add(Budget(
                user_id=user_id,
                category=budget_data["category"],
                monthly_limit=Decimal(str(budget_data["monthly_limit"])),
            ))
        print(f"   ✅ Created {len(BUDGETS)} budgets")

        # ─── Create Savings Goals ─────────────────────────────────────────
        print("🎯 Creating savings goals...")
        for goal_data in SAVINGS_GOALS:
            db.add(SavingsGoal(
                user_id=user_id,
                goal_name=goal_data["goal_name"],
                target_amount=Decimal(str(goal_data["target_amount"])),
                current_amount=Decimal(str(goal_data["current_amount"])),
                target_date=goal_data["target_date"],
            ))
        print(f"   ✅ Created {len(SAVINGS_GOALS)} savings goals")

        # ─── Create Assets ────────────────────────────────────────────────
        print("🏦 Creating assets...")
        total_assets = Decimal("0")
        for asset_data in ASSETS:
            amount = Decimal(str(asset_data["amount"]))
            total_assets += amount
            db.add(Asset(
                user_id=user_id,
                asset_type=asset_data["asset_type"],
                name=asset_data["name"],
                amount=amount,
            ))
        print(f"   ✅ Created {len(ASSETS)} assets (Total: ₹{total_assets:,.2f})")

        # ─── Create Liabilities ───────────────────────────────────────────
        print("💳 Creating liabilities...")
        total_liabilities = Decimal("0")
        for liability_data in LIABILITIES:
            amount = Decimal(str(liability_data["amount"]))
            total_liabilities += amount
            db.add(Liability(
                user_id=user_id,
                liability_type=liability_data["liability_type"],
                name=liability_data["name"],
                amount=amount,
            ))
        print(f"   ✅ Created {len(LIABILITIES)} liabilities (Total: ₹{total_liabilities:,.2f})")

        # ─── Create Net Worth Snapshots (last 6 months) ──────────────────
        print("📈 Creating net worth snapshots...")
        net_worth = total_assets - total_liabilities
        for month_offset in range(6):
            snapshot_date = date(today.year, today.month, 1) - timedelta(days=30 * month_offset)
            # Simulate slight growth over time
            multiplier = Decimal(str(1 - (month_offset * 0.03)))
            db.add(NetWorthSnapshot(
                user_id=user_id,
                total_assets=(total_assets * multiplier).quantize(Decimal("0.01")),
                total_liabilities=(total_liabilities * Decimal(str(1 + (month_offset * 0.02)))).quantize(Decimal("0.01")),
                net_worth=(net_worth * multiplier).quantize(Decimal("0.01")),
                snapshot_date=snapshot_date.replace(day=1),
            ))
        print(f"   ✅ Created 6 net worth snapshots")

        # ─── Commit All ──────────────────────────────────────────────────
        await db.commit()

    await engine.dispose()

    print("\n" + "=" * 60)
    print("🎉 Seed data created successfully!")
    print("=" * 60)
    print(f"\n📧 Demo Login Credentials:")
    print(f"   Email:    ayush@fintrack.app")
    print(f"   Password: password123")
    print(f"\n💡 Start the server with: uvicorn app.main:app --reload")
    print(f"📚 API docs available at: http://localhost:8000/docs")


if __name__ == "__main__":
    asyncio.run(seed_database())

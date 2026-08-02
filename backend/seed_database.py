"""
FinTrack Synthetic Database Population & Analytics Preparation Seeder
======================================================================

Populates the PostgreSQL database with realistic synthetic financial data
for testing, demo dashboards, and advanced analytics (cohort analysis,
spending trends, forecasting, anomaly detection, business KPIs).

Usage:
    python seed_database.py [--seed 42] [--users 500] [--batch-size 50] [--clear]
"""

import argparse
import asyncio
import random
import time
from datetime import date, datetime, timedelta
from decimal import Decimal
from typing import Dict, List, Tuple, Any

from sqlalchemy import delete, select, func
from sqlalchemy.ext.asyncio import AsyncSession, create_async_engine, async_sessionmaker

from app.config import settings
from app.database import Base
from app.models.user import User, RefreshToken
from app.models.transaction import Transaction
from app.models.budget import Budget
from app.models.savings_goal import SavingsGoal
from app.models.asset import Asset
from app.models.liability import Liability, NetWorthSnapshot
from app.services.auth_service import hash_password


# ─── Data Constants & Indian Name Pools ─────────────────────────────────────

FIRST_NAMES_MALE = [
    "Aarav", "Aditya", "Advait", "Amit", "Aniket", "Arjun", "Ayush", "Dev", "Dhruv", 
    "Gautam", "Harsh", "Ishaan", "Karan", "Kunal", "Manish", "Mayank", "Nikhil", 
    "Pranav", "Rahul", "Rohan", "Sachin", "Sameer", "Siddharth", "Tushar", "Varun",
    "Vikram", "Yash", "Abhishek", "Deepak", "Rajesh", "Sanjay", "Suresh", "Vijay"
]

FIRST_NAMES_FEMALE = [
    "Aanya", "Ananya", "Anushka", "Avani", "Divya", "Isha", "Kavya", "Khushi", 
    "Meera", "Neha", "Nidhi", "Pooja", "Priya", "Riya", "Roshni", "Sakshi", 
    "Shreya", "Sneha", "Sonam", "Tanvi", "Tara", "Trisha", "Vaidya", "Vidya", 
    "Anjali", "Deepika", "Kiran", "Meenakshi", "Poonam", "Sunita", "Swati"
]

LAST_NAMES = [
    "Agarwal", "Banerjee", "Bhatia", "Chawla", "Deshmukh", "Dutta", "Gupta", 
    "Iyer", "Joshi", "Kamble", "Kapoor", "Kumar", "Mehta", "Mishra", "Nair", 
    "Patel", "Patil", "Rao", "Reddy", "Roy", "Sharma", "Singh", "Verma", 
    "Shah", "Kulkarni", "Chaudhary", "Pandey", "Deshpande", "Saxena"
]

EMAIL_DOMAINS = ["gmail.com", "yahoo.co.in", "outlook.com", "fintrack.app", "icloud.com"]

MERCHANTS_BY_CATEGORY = {
    "food": ["Swiggy", "Zomato", "Starbucks", "Dominos Pizza", "McDonalds", "Chai Point", "Haldiram's", "Barbeque Nation", "Subway", "Third Wave Coffee"],
    "groceries": ["Blinkit", "BigBasket", "DMart", "Reliance Fresh", "Zepto", "Nature's Basket", "Local Vegetable Vendor", "More Supermarket"],
    "rent": ["House Rent Transfer", "PG Accommodation Fee", "Society Maintenance", "Apartment Rent"],
    "utilities": ["Tata Power Electricity", "Airtel Broadband", "Jio Fiber", "Indane LPG Gas", "Municipal Water Supply", "Adani Electricity"],
    "fuel": ["Indian Oil Petrol Pump", "Bharat Petroleum", "HP Fuel Station", "Shell Petrol Station"],
    "shopping": ["Amazon India", "Flipkart", "Myntra", "Ajio", "Zara", "Decathlon", "Reliance Digital", "Nykaa", "Croma"],
    "entertainment": ["BookMyShow", "Netflix Subscription", "Spotify Premium", "Disney+ Hotstar", "PVR Cinemas", "INOX Movies", "Amazon Prime"],
    "healthcare": ["Apollo Pharmacy", "Practo Doctor Consult", "Cult.fit Gym", "PharmEasy", "Max Healthcare", "Thyrocare Labs"],
    "insurance": ["Star Health Insurance", "HDFC ERGO Premium", "LIC Policy Premium", "Care Health Insurance"],
    "education": ["Udemy Course", "Unacademy Subscription", "Coursera", "Bookstore Purchase", "College Fee Installment"],
    "travel": ["MakeMyTrip Flight", "Goibibo Hotel", "Uber Ride", "Ola Cabs", "IRCTC Train Ticket", "Rapido Bike", "Indigo Airlines"],
    "investments": ["Zerodha Coin MF", "Groww SIP", "SBI Mutual Fund", "PPF Deposit", "Sovereign Gold Bond"],
    "emi": ["HDFC Home Loan EMI", "SBI Car Loan EMI", "Bajaj Finserv Consumer EMI", "ICICI Personal Loan EMI"],
}

INCOME_SOURCES = {
    "salary": ["Monthly Salary", "TCS Salary", "Infosys Paycheck", "Wipro Salary", "Accenture Payroll", "HDFC Tech Salary"],
    "freelance": ["Upwork Web Dev Client", "Fiverr Graphic Design", "Consulting Fee", "Client Invoice Payment"],
    "bonus": ["Annual Performance Bonus", "Diwali Festival Bonus", "Quarterly Incentive"],
    "interest": ["SBI FD Quarterly Interest", "Savings Bank Interest", "PPF Annual Interest"],
    "cashback": ["CRED Pay Cashback", "Google Pay Scratch Card", "Paytm Cashback Point"],
    "dividend": ["TCS Stock Dividend", "Reliance Dividend Payout", "Nifty 50 ETF Dividend"],
}

SAVINGS_GOALS_POOL = [
    {"name": "Emergency Fund", "target_range": (100000, 300000)},
    {"name": "Goa Vacation", "target_range": (25000, 60000)},
    {"name": "Europe Trip", "target_range": (150000, 350000)},
    {"name": "New MacBook Pro", "target_range": (120000, 220000)},
    {"name": "Electric Scooter / Bike", "target_range": (80000, 180000)},
    {"name": "Car Down Payment", "target_range": (200000, 500000)},
    {"name": "House Down Payment", "target_range": (500000, 1500000)},
    {"name": "Wedding Fund", "target_range": (300000, 800000)},
    {"name": "Higher Education", "target_range": (200000, 600000)},
]


# ─── Seeder Logic & Persona Data Configurations ──────────────────────────────

PERSONAS = {
    "student": {
        "share": 0.30,
        "monthly_income": (12000, 25000),
        "income_types": ["freelance", "cashback", "interest"],
        "expense_categories": ["food", "groceries", "shopping", "entertainment", "travel", "utilities"],
        "budgets": ["food", "shopping", "entertainment"],
        "asset_types": ["bank_account", "cash"],
        "liability_prob": 0.20,
        "liability_types": ["education_loan", "credit_card"],
    },
    "working_professional": {
        "share": 0.40,
        "monthly_income": (50000, 150000),
        "income_types": ["salary", "bonus", "cashback", "dividend", "interest"],
        "expense_categories": ["food", "groceries", "rent", "utilities", "fuel", "shopping", "entertainment", "healthcare", "insurance", "travel", "investments", "emi"],
        "budgets": ["rent", "food", "fuel", "utilities", "shopping", "entertainment"],
        "asset_types": ["bank_account", "fixed_deposit", "mutual_fund", "stocks", "investment"],
        "liability_prob": 0.50,
        "liability_types": ["credit_card", "car_loan", "personal_loan", "home_loan"],
    },
    "freelancer": {
        "share": 0.15,
        "monthly_income": (35000, 110000),
        "income_types": ["freelance", "cashback", "dividend", "interest"],
        "expense_categories": ["food", "groceries", "rent", "utilities", "fuel", "shopping", "entertainment", "healthcare", "travel", "investments"],
        "budgets": ["food", "rent", "utilities", "travel"],
        "asset_types": ["bank_account", "mutual_fund", "cash", "stocks"],
        "liability_prob": 0.35,
        "liability_types": ["credit_card", "personal_loan"],
    },
    "family": {
        "share": 0.10,
        "monthly_income": (80000, 250000),
        "income_types": ["salary", "bonus", "dividend", "interest"],
        "expense_categories": ["food", "groceries", "rent", "utilities", "fuel", "shopping", "healthcare", "insurance", "education", "travel", "investments", "emi"],
        "budgets": ["groceries", "healthcare", "education", "utilities", "rent"],
        "asset_types": ["bank_account", "fixed_deposit", "mutual_fund", "gold", "investment"],
        "liability_prob": 0.60,
        "liability_types": ["home_loan", "car_loan", "credit_card"],
    },
    "retired": {
        "share": 0.05,
        "monthly_income": (30000, 70000),
        "income_types": ["interest", "dividend", "cashback"],
        "expense_categories": ["food", "groceries", "utilities", "healthcare", "insurance", "travel"],
        "budgets": ["healthcare", "groceries", "utilities"],
        "asset_types": ["bank_account", "fixed_deposit", "gold", "mutual_fund"],
        "liability_prob": 0.10,
        "liability_types": ["credit_card"],
    },
}

BEHAVIORS = ["consistent_saver", "overspender", "budget_follower", "goal_oriented", "casual_user", "inactive_user"]
BEHAVIOR_WEIGHTS = [0.20, 0.20, 0.25, 0.20, 0.10, 0.05]


# ─── Helper Functions ────────────────────────────────────────────────────────

def random_date_between(start_date: date, end_date: date) -> date:
    """Return a random date between start_date and end_date inclusive."""
    if start_date >= end_date:
        return start_date
    delta = (end_date - start_date).days
    return start_date + timedelta(days=random.randint(0, delta))


def quantize_amount(val: float) -> Decimal:
    """Format float to Decimal rounded to 2 places."""
    return Decimal(str(round(val, 2)))


# ─── Seeder Core Class ───────────────────────────────────────────────────────

class SyntheticSeeder:
    def __init__(self, session: AsyncSession, seed: int = 42, total_users: int = 500, batch_size: int = 50):
        self.db = session
        self.random_seed = seed
        self.total_users = total_users
        self.batch_size = batch_size
        self.today = date.today()
        self.start_history_date = self.today - timedelta(days=540)  # 18 months (~540 days)
        
        # Performance cache
        self.shared_password_hash = hash_password("password123")
        
        # Statistics counters
        self.counts = {
            "users": 0,
            "transactions": 0,
            "budgets": 0,
            "savings_goals": 0,
            "assets": 0,
            "liabilities": 0,
            "snapshots": 0,
        }

    async def clear_database(self):
        """Clear existing records across all application tables."""
        print("🧹 Clearing existing database records...")
        tables = [RefreshToken, NetWorthSnapshot, Transaction, Budget, SavingsGoal, Asset, Liability, User]
        for table in tables:
            await self.db.execute(delete(table))
        await self.db.commit()
        print("   ✅ Database cleared cleanly.")

    def _select_persona(self, idx: int) -> str:
        """Assign persona deterministically according to distribution weights."""
        if idx < int(self.total_users * 0.30):
            return "student"
        elif idx < int(self.total_users * 0.70):
            return "working_professional"
        elif idx < int(self.total_users * 0.85):
            return "freelancer"
        elif idx < int(self.total_users * 0.95):
            return "family"
        else:
            return "retired"

    def _generate_user_name_and_email(self, idx: int) -> Tuple[str, str]:
        """Generate unique Indian full name and email address."""
        is_male = random.choice([True, False])
        first = random.choice(FIRST_NAMES_MALE if is_male else FIRST_NAMES_FEMALE)
        last = random.choice(LAST_NAMES)
        name = f"{first} {last}"
        
        domain = random.choice(EMAIL_DOMAINS)
        clean_name = f"{first.lower()}.{last.lower()}{idx+101}"
        email = f"{clean_name}@{domain}"
        return name, email

    async def seed(self, should_clear: bool = False):
        """Execute the entire seeding process."""
        random.seed(self.random_seed)
        start_time = time.time()

        if should_clear:
            await self.clear_database()

        print(f"\n🚀 Starting synthetic database seeding for {self.total_users} users...")
        print(f"   🎲 Random seed: {self.random_seed}")
        print(f"   📅 Time range: {self.start_history_date} to {self.today} (18 months)")

        # Process in batches of users
        num_batches = (self.total_users + self.batch_size - 1) // self.batch_size

        for batch_num in range(num_batches):
            batch_start_idx = batch_num * self.batch_size
            batch_end_idx = min(batch_start_idx + self.batch_size, self.total_users)
            
            print(f"\n⏳ Processing Batch {batch_num + 1}/{num_batches} (Users {batch_start_idx + 1} to {batch_end_idx})...")
            await self._process_user_batch(batch_start_idx, batch_end_idx)

        elapsed = time.time() - start_time
        self._print_summary(elapsed)

    async def _process_user_batch(self, start_idx: int, end_idx: int):
        """Generate and insert records for a batch of users."""
        users_to_add = []
        batch_metadata = []

        # Step 1: Create Users
        for idx in range(start_idx, end_idx):
            persona_key = self._select_persona(idx)
            behavior_key = random.choices(BEHAVIORS, weights=BEHAVIOR_WEIGHTS)[0]
            
            name, email = self._generate_user_name_and_email(idx)
            
            # Signup date distributed across last 18 months
            signup_date = random_date_between(self.start_history_date, self.today - timedelta(days=30))
            created_at = datetime.combine(signup_date, datetime.min.time())

            user = User(
                name=name,
                email=email,
                password_hash=self.shared_password_hash,
                created_at=created_at,
                updated_at=created_at,
            )
            users_to_add.append(user)
            batch_metadata.append({
                "persona_key": persona_key,
                "behavior_key": behavior_key,
                "signup_date": signup_date,
            })

        self.db.add_all(users_to_add)
        await self.db.flush()  # Assigns UUID primary keys to user objects
        self.counts["users"] += len(users_to_add)

        # Step 2: Generate related entities per user
        txns_to_add = []
        budgets_to_add = []
        goals_to_add = []
        assets_to_add = []
        liabilities_to_add = []
        snapshots_to_add = []

        for user, meta in zip(users_to_add, batch_metadata):
            user_id = user.id
            persona = PERSONAS[meta["persona_key"]]
            behavior = meta["behavior_key"]
            signup_date = meta["signup_date"]

            # ── A. Budgets ──
            if behavior != "casual_user" and behavior != "inactive_user":
                num_budgets = random.randint(2, min(5, len(persona["budgets"])))
                selected_categories = random.sample(persona["budgets"], num_budgets)
                for cat in selected_categories:
                    limit = random.randint(2000, 25000)
                    budgets_to_add.append(Budget(
                        user_id=user_id,
                        category=cat,
                        monthly_limit=Decimal(str(limit)),
                        created_at=datetime.combine(signup_date, datetime.min.time())
                    ))

            # ── B. Savings Goals ──
            if behavior in ["consistent_saver", "goal_oriented"] or (random.random() < 0.3 and behavior != "casual_user"):
                num_goals = random.randint(1, 3)
                selected_goals = random.sample(SAVINGS_GOALS_POOL, num_goals)
                for g_info in selected_goals:
                    target_amt = random.randint(*g_info["target_range"])
                    # Goal progress based on behavior
                    if behavior == "consistent_saver":
                        curr_ratio = random.uniform(0.3, 0.85)
                    elif behavior == "goal_oriented":
                        curr_ratio = random.uniform(0.4, 0.95)
                    else:
                        curr_ratio = random.uniform(0.05, 0.4)
                    
                    curr_amt = quantize_amount(target_amt * curr_ratio)
                    target_d = signup_date + timedelta(days=random.randint(90, 540))

                    goals_to_add.append(SavingsGoal(
                        user_id=user_id,
                        goal_name=g_info["name"],
                        target_amount=Decimal(str(target_amt)),
                        current_amount=curr_amt,
                        target_date=target_d,
                        created_at=datetime.combine(signup_date, datetime.min.time())
                    ))

            # ── C. Assets ──
            num_assets = random.randint(2, 3)
            chosen_asset_types = random.sample(persona["asset_types"], min(num_assets, len(persona["asset_types"])))
            user_total_assets = Decimal("0")
            for a_type in chosen_asset_types:
                if a_type == "bank_account":
                    val = random.randint(5000, 150000)
                    a_name = f"{random.choice(['HDFC', 'SBI', 'ICICI', 'Axis'])} Savings Account"
                elif a_type == "fixed_deposit":
                    val = random.randint(20000, 300000)
                    a_name = f"{random.choice(['SBI', 'HDFC', 'Bank of Baroda'])} FD"
                elif a_type == "mutual_fund":
                    val = random.randint(15000, 250000)
                    a_name = f"{random.choice(['Zerodha Nifty 50 Index', 'Parag Parikh Flexi Cap', 'Mirae Asset Large Cap'])}"
                elif a_type == "stocks":
                    val = random.randint(10000, 200000)
                    a_name = "Equity Portfolio (Zerodha/Groww)"
                elif a_type == "gold":
                    val = random.randint(20000, 150000)
                    a_name = "Sovereign Gold Bonds / Gold Asset"
                else:
                    val = random.randint(2000, 20000)
                    a_name = "Cash in Hand"
                
                amount_dec = quantize_amount(val)
                user_total_assets += amount_dec
                assets_to_add.append(Asset(
                    user_id=user_id,
                    asset_type=a_type,
                    name=a_name,
                    amount=amount_dec,
                    created_at=datetime.combine(signup_date, datetime.min.time())
                ))

            # ── D. Liabilities ──
            user_total_liabilities = Decimal("0")
            if random.random() < persona["liability_prob"]:
                l_type = random.choice(persona["liability_types"])
                if l_type == "credit_card":
                    l_val = random.randint(3000, 45000)
                    l_name = f"{random.choice(['HDFC Regalia', 'ICICI Amazon Pay', 'SBI SimplyClick'])} Credit Card"
                elif l_type == "home_loan":
                    l_val = random.randint(1500000, 4500000)
                    l_name = "HDFC Home Loan"
                elif l_type == "car_loan":
                    l_val = random.randint(200000, 800000)
                    l_name = "SBI Auto Loan"
                elif l_type == "education_loan":
                    l_val = random.randint(100000, 500000)
                    l_name = "SBI Student Loan"
                else:
                    l_val = random.randint(10000, 80000)
                    l_name = "Personal Loan"

                l_dec = quantize_amount(l_val)
                user_total_liabilities += l_dec
                liabilities_to_add.append(Liability(
                    user_id=user_id,
                    liability_type=l_type,
                    name=l_name,
                    amount=l_dec,
                    created_at=datetime.combine(signup_date, datetime.min.time())
                ))

            # ── E. Transactions ──
            # Determine active date window for transactions
            if behavior == "inactive_user":
                active_end_date = min(signup_date + timedelta(days=90), self.today)
            else:
                active_end_date = self.today

            # Number of months active
            months_active = max(1, (active_end_date.year - signup_date.year) * 12 + active_end_date.month - signup_date.month + 1)
            
            for m in range(months_active):
                month_cur_date = signup_date + timedelta(days=m * 30)
                if month_cur_date > active_end_date:
                    break

                # 1. Income (1-2 times per month)
                inc_type = random.choice(persona["income_types"])
                inc_desc = random.choice(INCOME_SOURCES.get(inc_type, ["Monthly Income"]))
                inc_min, inc_max = persona["monthly_income"]
                
                inc_amount = quantize_amount(random.uniform(inc_min, inc_max))
                txns_to_add.append(Transaction(
                    user_id=user_id,
                    amount=inc_amount,
                    type="income",
                    category=inc_type,
                    description=inc_desc,
                    transaction_date=random_date_between(month_cur_date.replace(day=1), min(month_cur_date.replace(day=28), self.today)),
                    created_at=datetime.combine(month_cur_date, datetime.min.time())
                ))

                # 2. Expenses (8-15 transactions per active month)
                num_exp = random.randint(6, 14) if behavior != "casual_user" else random.randint(2, 5)
                for _ in range(num_exp):
                    exp_cat = random.choice(persona["expense_categories"])
                    merchant = random.choice(MERCHANTS_BY_CATEGORY.get(exp_cat, ["General Store"]))
                    
                    # Expense amount logic
                    if exp_cat in ["rent", "emi"]:
                        exp_amt = random.uniform(inc_min * 0.2, inc_min * 0.35)
                    elif exp_cat in ["groceries", "utilities"]:
                        exp_amt = random.uniform(1000, 6000)
                    elif exp_cat == "investments":
                        exp_amt = random.uniform(2000, 15000)
                    else:
                        exp_amt = random.uniform(150, 2500)

                    # Anomaly injection (1% chance of unusually high spending)
                    if random.random() < 0.01:
                        exp_amt *= random.uniform(4.0, 10.0)
                        merchant += " (Large Purchase/Emergency)"

                    # Behavior multiplier
                    if behavior == "overspender":
                        exp_amt *= 1.25

                    tx_date = random_date_between(month_cur_date.replace(day=1), min(month_cur_date + timedelta(days=28), self.today))
                    
                    txns_to_add.append(Transaction(
                        user_id=user_id,
                        amount=quantize_amount(exp_amt),
                        type="expense",
                        category=exp_cat,
                        description=merchant,
                        transaction_date=tx_date,
                        created_at=datetime.combine(tx_date, datetime.min.time())
                    ))

            # ── F. Net Worth Snapshots (Monthly across 18 months) ──
            curr_assets = user_total_assets
            curr_liab = user_total_liabilities
            
            # Generate monthly snapshots from signup date up to today
            for m in range(months_active):
                snap_date = signup_date + timedelta(days=m * 30)
                if snap_date > self.today:
                    break

                # Net worth trends logically based on behavior profile
                growth_factor = 1.0
                if behavior in ["consistent_saver", "goal_oriented"]:
                    growth_factor = 1.0 + (m * 0.015)  # Steady wealth growth
                elif behavior == "overspender":
                    growth_factor = 1.0 - (m * 0.01)   # Wealth erosion
                
                snap_assets = quantize_amount(float(curr_assets) * growth_factor)
                snap_liab = quantize_amount(float(curr_liab) * max(0.5, 1.0 - (m * 0.005)))
                net_worth = snap_assets - snap_liab

                snapshots_to_add.append(NetWorthSnapshot(
                    user_id=user_id,
                    total_assets=snap_assets,
                    total_liabilities=snap_liab,
                    net_worth=net_worth,
                    snapshot_date=snap_date.replace(day=1),
                    created_at=datetime.combine(snap_date, datetime.min.time())
                ))

        # Add all batch entities to session
        self.db.add_all(budgets_to_add)
        self.db.add_all(goals_to_add)
        self.db.add_all(assets_to_add)
        self.db.add_all(liabilities_to_add)
        self.db.add_all(txns_to_add)
        self.db.add_all(snapshots_to_add)

        # Commit batch
        await self.db.commit()

        # Update stats counters
        self.counts["budgets"] += len(budgets_to_add)
        self.counts["savings_goals"] += len(goals_to_add)
        self.counts["assets"] += len(assets_to_add)
        self.counts["liabilities"] += len(liabilities_to_add)
        self.counts["transactions"] += len(txns_to_add)
        self.counts["snapshots"] += len(snapshots_to_add)

        print(f"   ✅ Batch inserted: {len(users_to_add)} Users, {len(txns_to_add)} Transactions, {len(snapshots_to_add)} Snapshots.")

    def _print_summary(self, elapsed: float):
        """Display clean terminal summary of inserted records."""
        print("\n" + "=" * 65)
        print("🎉 SYNTHETIC DATABASE SEEDING COMPLETED SUCCESSFULLY!")
        print("=" * 65)
        print(f"⏱️  Execution Time: {elapsed:.2f} seconds")
        print("\n📊 Generated Database Record Summary:")
        print(f"   • Users:               {self.counts['users']:,}")
        print(f"   • Transactions:        {self.counts['transactions']:,}")
        print(f"   • Budgets:             {self.counts['budgets']:,}")
        print(f"   • Savings Goals:       {self.counts['savings_goals']:,}")
        print(f"   • Assets:              {self.counts['assets']:,}")
        print(f"   • Liabilities:         {self.counts['liabilities']:,}")
        print(f"   • Net Worth Snapshots: {self.counts['snapshots']:,}")
        print("-" * 65)
        print(f"📧 Demo Account Login:")
        print(f"   Email:    demo_user_101@fintrack.app (or demo_user_1 to demo_user_500)")
        print(f"   Password: password123")
        print("=" * 65 + "\n")


# ─── Command Line Entry Point ────────────────────────────────────────────────

async def main():
    parser = argparse.ArgumentParser(description="FinTrack Synthetic Database Population & Analytics Seeder")
    parser.add_argument("--seed", type=int, default=42, help="Random seed for deterministic generation (default: 42)")
    parser.add_argument("--users", type=int, default=500, help="Number of users to generate (default: 500)")
    parser.add_argument("--batch-size", type=int, default=50, help="Batch size for database ingestion (default: 50)")
    parser.add_argument("--clear", action="store_true", help="Clear existing database records before seeding")

    args = parser.parse_args()

    engine = create_async_engine(settings.DATABASE_URL, echo=False)
    async_session = async_sessionmaker(engine, class_=AsyncSession, expire_on_commit=False)

    async with async_session() as session:
        try:
            seeder = SyntheticSeeder(
                session=session,
                seed=args.seed,
                total_users=args.users,
                batch_size=args.batch_size,
            )
            await seeder.seed(should_clear=args.clear)
        except Exception as e:
            await session.rollback()
            print(f"\n❌ Error during database seeding: {e}")
            raise
        finally:
            await engine.dispose()


if __name__ == "__main__":
    asyncio.run(main())

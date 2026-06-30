# FinTrack Backend 🇮🇳

**Personal Finance Tracker API** — A production-ready FastAPI backend for tracking expenses, managing budgets, setting savings goals, monitoring net worth, and generating financial insights. Built for Indian users with all amounts in INR (₹).

## Tech Stack

| Technology | Purpose |
|---|---|
| **FastAPI** | Web framework (Python 3.11+) |
| **PostgreSQL** | Database (via Supabase) |
| **SQLAlchemy** | Async ORM |
| **Alembic** | Database migrations |
| **JWT** | Authentication (access + refresh tokens) |
| **Pydantic v2** | Request/response validation |
| **bcrypt** | Password hashing |
| **slowapi** | Rate limiting |

## Project Structure

```
backend/
├── app/
│   ├── main.py                 # FastAPI app factory, CORS, routes
│   ├── config.py               # Settings from environment variables
│   ├── database.py             # Async SQLAlchemy engine & session
│   ├── exceptions.py           # Custom exception classes & handlers
│   ├── models/                 # SQLAlchemy ORM models
│   │   ├── user.py             # User + RefreshToken
│   │   ├── transaction.py      # Transaction
│   │   ├── budget.py           # Budget
│   │   ├── savings_goal.py     # SavingsGoal
│   │   ├── asset.py            # Asset
│   │   └── liability.py        # Liability + NetWorthSnapshot
│   ├── schemas/                # Pydantic v2 schemas
│   │   ├── user.py             # Auth & user schemas
│   │   ├── transaction.py      # Transaction CRUD schemas
│   │   ├── budget.py           # Budget with spending enrichment
│   │   ├── savings_goal.py     # Goal with progress tracking
│   │   ├── asset.py            # Asset schemas
│   │   └── liability.py        # Liability + NetWorth schemas
│   ├── routers/                # API route handlers
│   │   ├── auth.py             # Authentication (register, login, JWT)
│   │   ├── transactions.py     # Transaction CRUD + filters
│   │   ├── budgets.py          # Budget management + spending calc
│   │   ├── savings_goals.py    # Savings goals + enrichment
│   │   ├── assets_liabilities.py # Net worth management
│   │   ├── analytics.py        # Dashboard & charts
│   │   └── insights.py         # AI-powered financial insights
│   ├── services/               # Business logic
│   │   ├── auth_service.py     # JWT, password hashing, token mgmt
│   │   ├── analytics_service.py # Analytics computations
│   │   └── insights_service.py  # Insight generation engine
│   └── middleware/
│       └── auth_middleware.py   # JWT authentication dependency
├── alembic/                    # Database migrations
│   ├── env.py
│   └── versions/
│       └── 001_initial_migration.py
├── alembic.ini
├── seed_data.py                # Test data with Indian transactions
├── requirements.txt
├── .env.example
└── README.md
```

## Quick Start

### 1. Clone & Install

```bash
cd backend
python -m venv venv
source venv/bin/activate  # On Windows: venv\Scripts\activate
pip install -r requirements.txt
```

### 2. Configure Environment

```bash
cp .env.example .env
# Edit .env with your Supabase PostgreSQL URL and JWT secret
```

**Required variables:**
- `DATABASE_URL` — Your Supabase PostgreSQL connection string (use `postgresql+asyncpg://` prefix)
- `JWT_SECRET_KEY` — A strong random secret for signing JWTs

### 3. Run Migrations

```bash
alembic upgrade head
```

### 4. Seed Test Data (Optional)

```bash
python seed_data.py
```

This creates a demo user with 6 months of realistic Indian transaction data.

**Demo credentials:**
- Email: `ayush@fintrack.app`
- Password: `password123`

### 5. Start the Server

```bash
uvicorn app.main:app --reload --port 8000
```

📚 API Docs: [http://localhost:8000/docs](http://localhost:8000/docs)
🏥 Health Check: [http://localhost:8000/health](http://localhost:8000/health)

## API Endpoints

### Authentication — `/api/v1/auth`
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/register` | Create new account |
| POST | `/login` | Login with email/password |
| POST | `/refresh` | Refresh access token |
| POST | `/logout` | Invalidate refresh token |
| POST | `/forgot-password` | Request password reset |
| POST | `/reset-password` | Reset password with token |
| GET | `/me` | Get current user profile |
| PUT | `/me` | Update profile |
| PUT | `/me/password` | Change password |

### Transactions — `/api/v1/transactions`
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/` | Create transaction |
| GET | `/` | List with filters & pagination |
| GET | `/{id}` | Get single transaction |
| PUT | `/{id}` | Update transaction |
| DELETE | `/{id}` | Delete transaction |

**Query Filters:** `type`, `category`, `start_date`, `end_date`, `search`, `page`, `limit`

### Budgets — `/api/v1/budgets`
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/` | Create/upsert budget |
| GET | `/` | List with spending metrics |
| PUT | `/{id}` | Update budget limit |
| DELETE | `/{id}` | Delete budget |

### Savings Goals — `/api/v1/savings-goals`
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/` | Create goal |
| GET | `/` | List with progress tracking |
| GET | `/{id}` | Get goal details |
| PUT | `/{id}` | Update goal |
| DELETE | `/{id}` | Delete goal |

### Net Worth — `/api/v1/net-worth`
| Method | Endpoint | Description |
|--------|----------|-------------|
| POST | `/assets` | Add asset |
| GET | `/assets` | List all assets |
| PUT | `/assets/{id}` | Update asset |
| DELETE | `/assets/{id}` | Delete asset |
| POST | `/liabilities` | Add liability |
| GET | `/liabilities` | List all liabilities |
| PUT | `/liabilities/{id}` | Update liability |
| DELETE | `/liabilities/{id}` | Delete liability |
| GET | `/summary` | Net worth summary |
| GET | `/history` | 12-month snapshot history |

### Analytics — `/api/v1/analytics`
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/dashboard` | Full dashboard data |
| GET | `/spending-by-category` | Pie chart data |
| GET | `/monthly-trend` | Line chart data |
| GET | `/category-comparison` | Bar chart data |
| GET | `/daily-spending` | Daily spending chart |

### Insights — `/api/v1/insights`
| Method | Endpoint | Description |
|--------|----------|-------------|
| GET | `/` | Auto-generated financial insights |

## Security

- **JWT Authentication** — 15-minute access tokens, 30-day refresh tokens
- **Password Hashing** — bcrypt via passlib
- **Data Isolation** — All queries filter by authenticated user's ID
- **Rate Limiting** — 5 requests/minute on auth endpoints
- **CORS** — Configured for mobile app origins
- **Parameterized Queries** — SQLAlchemy ORM prevents SQL injection

## Deployment

### Railway

```bash
# Set environment variables in Railway dashboard
# Start command:
uvicorn app.main:app --host 0.0.0.0 --port $PORT
```

### Render

Create a `render.yaml` or set the start command:
```bash
uvicorn app.main:app --host 0.0.0.0 --port 10000
```

### Docker (Optional)

```dockerfile
FROM python:3.11-slim
WORKDIR /app
COPY requirements.txt .
RUN pip install --no-cache-dir -r requirements.txt
COPY . .
CMD ["uvicorn", "app.main:app", "--host", "0.0.0.0", "--port", "8000"]
```

## Error Response Format

All errors follow a consistent format:

```json
{
  "error": true,
  "code": "TRANSACTION_NOT_FOUND",
  "message": "Transaction with this ID does not exist",
  "status_code": 404
}
```

## License

Private — FinTrack Personal Finance App

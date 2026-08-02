from fastapi import FastAPI, Request
from fastapi.middleware.cors import CORSMiddleware
from fastapi.responses import JSONResponse
from slowapi import _rate_limit_exceeded_handler
from slowapi.errors import RateLimitExceeded
from datetime import datetime, timezone

from app.config import settings
from app.exceptions import AppException, app_exception_handler, generic_exception_handler

# Import all routers
from app.routers import auth, transactions, budgets, savings_goals, assets_liabilities, analytics, insights, admin_analytics


def create_app() -> FastAPI:
    """Application factory for the FinTrack API."""
    app = FastAPI(
        title=settings.APP_NAME,
        description=(
            "FinTrack — Personal Finance Tracker API for Indian users. "
            "Track expenses, manage budgets, set savings goals, monitor net worth, "
            "and get AI-powered financial insights. All amounts in INR (₹)."
        ),
        version=settings.APP_VERSION,
        docs_url="/docs",
        redoc_url="/redoc",
        openapi_url="/openapi.json",
    )

    # ─── CORS Middleware ──────────────────────────────────────────────────
    app.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins_list + ["*"],  # Allow all for mobile
        allow_credentials=True,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    # ─── Rate Limit Error Handler ─────────────────────────────────────────
    app.add_exception_handler(RateLimitExceeded, _rate_limit_exceeded_handler)

    # ─── Custom Exception Handlers ────────────────────────────────────────
    app.add_exception_handler(AppException, app_exception_handler)

    # ─── Register Routers ─────────────────────────────────────────────────
    app.include_router(auth.router)
    app.include_router(transactions.router)
    app.include_router(budgets.router)
    app.include_router(savings_goals.router)
    app.include_router(assets_liabilities.router)
    app.include_router(analytics.router)
    app.include_router(insights.router)
    app.include_router(admin_analytics.router)

    # ─── Health Check ─────────────────────────────────────────────────────
    @app.get("/health", tags=["Health"])
    async def health_check():
        return {
            "status": "ok",
            "app": settings.APP_NAME,
            "version": settings.APP_VERSION,
            "environment": settings.ENVIRONMENT,
            "timestamp": datetime.now(timezone.utc).isoformat(),
        }

    # ─── Root ─────────────────────────────────────────────────────────────
    @app.get("/", tags=["Root"])
    async def root():
        return {
            "app": settings.APP_NAME,
            "version": settings.APP_VERSION,
            "docs": "/docs",
            "health": "/health",
        }

    return app


app = create_app()

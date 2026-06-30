from fastapi import HTTPException, status
from fastapi.responses import JSONResponse
from fastapi.requests import Request


class AppException(HTTPException):
    """Base application exception with consistent error format."""

    def __init__(self, status_code: int, code: str, message: str):
        self.error_code = code
        self.error_message = message
        super().__init__(status_code=status_code, detail=message)


# ─── Authentication Errors ───────────────────────────────────────────────────

class InvalidCredentialsError(AppException):
    def __init__(self, message: str = "Invalid email or password"):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="INVALID_CREDENTIALS",
            message=message,
        )


class TokenExpiredError(AppException):
    def __init__(self, message: str = "Token has expired"):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="TOKEN_EXPIRED",
            message=message,
        )


class TokenInvalidError(AppException):
    def __init__(self, message: str = "Invalid token"):
        super().__init__(
            status_code=status.HTTP_401_UNAUTHORIZED,
            code="TOKEN_INVALID",
            message=message,
        )


class UnauthorizedAccessError(AppException):
    def __init__(self, message: str = "You do not have permission to access this resource"):
        super().__init__(
            status_code=status.HTTP_403_FORBIDDEN,
            code="UNAUTHORIZED_ACCESS",
            message=message,
        )


# ─── User Errors ─────────────────────────────────────────────────────────────

class UserNotFoundError(AppException):
    def __init__(self, message: str = "User not found"):
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            code="USER_NOT_FOUND",
            message=message,
        )


class UserAlreadyExistsError(AppException):
    def __init__(self, message: str = "A user with this email already exists"):
        super().__init__(
            status_code=status.HTTP_409_CONFLICT,
            code="USER_ALREADY_EXISTS",
            message=message,
        )


# ─── Transaction Errors ──────────────────────────────────────────────────────

class TransactionNotFoundError(AppException):
    def __init__(self, message: str = "Transaction not found"):
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            code="TRANSACTION_NOT_FOUND",
            message=message,
        )


class InvalidTransactionTypeError(AppException):
    def __init__(self, message: str = "Transaction type must be 'income' or 'expense'"):
        super().__init__(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            code="INVALID_TRANSACTION_TYPE",
            message=message,
        )


# ─── Budget Errors ───────────────────────────────────────────────────────────

class BudgetNotFoundError(AppException):
    def __init__(self, message: str = "Budget not found"):
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            code="BUDGET_NOT_FOUND",
            message=message,
        )


class DuplicateBudgetCategoryError(AppException):
    def __init__(self, message: str = "A budget for this category already exists"):
        super().__init__(
            status_code=status.HTTP_409_CONFLICT,
            code="DUPLICATE_BUDGET_CATEGORY",
            message=message,
        )


# ─── Savings Goal Errors ─────────────────────────────────────────────────────

class GoalNotFoundError(AppException):
    def __init__(self, message: str = "Savings goal not found"):
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            code="GOAL_NOT_FOUND",
            message=message,
        )


# ─── Asset / Liability Errors ────────────────────────────────────────────────

class AssetNotFoundError(AppException):
    def __init__(self, message: str = "Asset not found"):
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            code="ASSET_NOT_FOUND",
            message=message,
        )


class LiabilityNotFoundError(AppException):
    def __init__(self, message: str = "Liability not found"):
        super().__init__(
            status_code=status.HTTP_404_NOT_FOUND,
            code="LIABILITY_NOT_FOUND",
            message=message,
        )


# ─── Validation Errors ───────────────────────────────────────────────────────

class ValidationError(AppException):
    def __init__(self, message: str = "Validation error"):
        super().__init__(
            status_code=status.HTTP_422_UNPROCESSABLE_ENTITY,
            code="VALIDATION_ERROR",
            message=message,
        )


# ─── Exception Handlers ──────────────────────────────────────────────────────

async def app_exception_handler(request: Request, exc: AppException) -> JSONResponse:
    """Global handler for all AppException subclasses."""
    return JSONResponse(
        status_code=exc.status_code,
        content={
            "error": True,
            "code": exc.error_code,
            "message": exc.error_message,
            "status_code": exc.status_code,
        },
    )


async def generic_exception_handler(request: Request, exc: Exception) -> JSONResponse:
    """Catch-all handler for unexpected errors."""
    return JSONResponse(
        status_code=status.HTTP_500_INTERNAL_SERVER_ERROR,
        content={
            "error": True,
            "code": "INTERNAL_SERVER_ERROR",
            "message": "An unexpected error occurred",
            "status_code": 500,
        },
    )

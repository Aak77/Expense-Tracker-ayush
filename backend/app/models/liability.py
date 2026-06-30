import uuid
from sqlalchemy import Column, String, Numeric, Date, DateTime, ForeignKey, text
from sqlalchemy.dialects.postgresql import UUID
from sqlalchemy.orm import relationship
from sqlalchemy.sql import func
from app.database import Base


class Liability(Base):
    __tablename__ = "liabilities"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text('gen_random_uuid()'))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    liability_type = Column(String(50), nullable=False)  # 'credit_card', 'loan', 'borrowed_money'
    name = Column(String(100), nullable=False)
    amount = Column(Numeric(12, 2), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    # Relationships
    user = relationship("User", back_populates="liabilities")


class NetWorthSnapshot(Base):
    __tablename__ = "net_worth_snapshots"

    id = Column(UUID(as_uuid=True), primary_key=True, server_default=text('gen_random_uuid()'))
    user_id = Column(UUID(as_uuid=True), ForeignKey("users.id", ondelete="CASCADE"), nullable=False)
    total_assets = Column(Numeric(12, 2), nullable=False)
    total_liabilities = Column(Numeric(12, 2), nullable=False)
    net_worth = Column(Numeric(12, 2), nullable=False)
    snapshot_date = Column(Date, nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now())

    # Relationships
    user = relationship("User", back_populates="net_worth_snapshots")

from sqlalchemy import (
    Column,
    Integer,
    String,
    Boolean,
    Text,
    JSON,
    PrimaryKeyConstraint,
    UniqueConstraint,
    Enum,
    DateTime,
)
from sqlalchemy.ext.declarative import declarative_base
from sqlalchemy.sql import func

Base = declarative_base()


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String, unique=True, index=True)
    name = Column(String)
    hashed_password = Column(String)
    device_id = Column(String)
    device_type = Column(String)
    is_subscribed = Column(Boolean, default=False)
    subscription_type = Column(String, default="trial")


class UserTasks(Base):
    __tablename__ = "user_tasks"
    id = Column(Integer, primary_key=True, autoincrement=True)
    user_id = Column(Integer, nullable=False)
    task_id = Column(Integer, nullable=False)
    extracted_text = Column(Text, nullable=False)
    qa_text = Column(Text, nullable=True)
    adapter_id = Column(Text, nullable=True)
    layout_text = Column(JSON)
    __table_args__ = (UniqueConstraint('user_id', 'task_id', name='uq_user_task'),)


class ProgressStatus(Base):
    __tablename__ = "progress_status"
    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, nullable=False)
    task_id = Column(Integer, nullable=False)
    status = Column(Enum('STARTED', 'PDF_PROCESSED', 'QA_GENERATED', 'ADAPTER_TRAINING', 'COMPLETED', 'FAILED'), nullable=False)
    updated_at = Column(DateTime(timezone=True), server_default=func.now(), onupdate=func.now())

    __table_args__ = (UniqueConstraint('user_id', 'task_id', name='uq_user_task_progress'),)

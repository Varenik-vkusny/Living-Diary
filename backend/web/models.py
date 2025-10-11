from sqlalchemy import String, Integer, Column, Boolean, DateTime, ForeignKey
from datetime import datetime, timezone
from sqlalchemy.orm import relationship
from .database import Base


def get_utc_now():
    return datetime.now(timezone.utc)


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    firebase_uid = Column(String, unique=True, index=True, nullable=False)
    username = Column(String)
    email = Column(String, unique=True)
    profile_completed = Column(Boolean, default=False)
    chat_id = Column(Integer, nullable=True)

    notes = relationship("Note", back_populates="owner")
    reminders = relationship("Reminder", back_populates="user")
    history = relationship("AIContext", back_populates="user")


class Note(Base):
    __tablename__ = "notes"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    content = Column(String, nullable=False)
    created_at = Column(DateTime(timezone=True), default=get_utc_now)

    owner_id = Column(Integer, ForeignKey("users.id"))

    owner = relationship("User", back_populates="notes")


class AIContext(Base):
    __tablename__ = "ai_context"

    id = Column(Integer, primary_key=True, index=True)
    role = Column(String, nullable=False)
    content = Column(String)
    created_at = Column(DateTime(timezone=True), default=get_utc_now)

    user_id = Column(Integer, ForeignKey("users.id"))

    user = relationship("User", back_populates="history")


class Reminder(Base):
    __tablename__ = "reminders"

    id = Column(Integer, primary_key=True, index=True)
    content = Column(String)
    reminder_at = Column(DateTime(timezone=True), default=get_utc_now)
    is_active = Column(Boolean, default=False)

    user_id = Column(Integer, ForeignKey("users.id"))

    user = relationship("User", back_populates="reminders")

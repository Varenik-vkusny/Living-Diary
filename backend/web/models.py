from sqlalchemy import String, Integer, Column, Boolean, DateTime, ForeignKey
from datetime import datetime
from sqlalchemy.orm import relationship
from .database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    firebase_uid = Column(String, unique=True, index=True, nullable=False)
    username = Column(String)
    email = Column(String, unique=True)
    profile_completed = Column(Boolean, default=False)

    notes = relationship("Note", back_populates="owner")

    history = relationship("AIContext", back_populates="user")


class Note(Base):
    __tablename__ = "notes"

    id = Column(Integer, primary_key=True, index=True)
    title = Column(String)
    content = Column(String, nullable=False)
    created_at = Column(DateTime, default=datetime.now())

    owner_id = Column(Integer, ForeignKey("users.id"))

    owner = relationship("User", back_populates="notes")


class AIContext(Base):
    __tablename__ = "ai_context"

    id = Column(Integer, primary_key=True)
    role = Column(String, nullable=False)
    content = Column(String)
    created_at = Column(DateTime, default=datetime.now())

    user_id = Column(Integer, ForeignKey("users.id"))

    user = relationship("User", back_populates="history")

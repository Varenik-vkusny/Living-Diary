from sqlalchemy import String, Integer, Column, Boolean
from .database import Base


class User(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True)
    firebase_uid = Column(String, unique=True, index=True, nullable=False)
    username = Column(String)
    email = Column(String, unique=True)
    profile_completed = Column(Boolean, default=False)

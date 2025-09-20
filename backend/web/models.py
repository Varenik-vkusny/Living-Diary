from sqlalchemy import String, Integer, Column
from .database import Base


class User(Base):
    id = Column(Integer, primary_key=True)
    username = Column(String)
    email = Column(String, unique=True)

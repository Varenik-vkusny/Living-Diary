from sqlalchemy.ext.asyncio.engine import create_async_engine
from sqlalchemy.ext.asyncio import async_sessionmaker
from sqlalchemy.pool import NullPool
from sqlalchemy.orm import declarative_base
from uuid import uuid4
from .config import get_settings

settings = get_settings()

DATABASE_URL = settings.database_url

async_engine = create_async_engine(
    DATABASE_URL,
    poolclass=NullPool,
    connect_args={
        "statement_cache_size": 0,
        "prepared_statement_name_func": lambda: f"__asyncpg_{uuid4()}__",
    },
)

AsyncLocalSession = async_sessionmaker(bind=async_engine, expire_on_commit=False)


Base = declarative_base()


async def get_db():
    async with AsyncLocalSession() as session:
        yield session

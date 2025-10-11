from sqlalchemy.ext.asyncio.engine import create_async_engine
from sqlalchemy.ext.asyncio import async_sessionmaker
from sqlalchemy.pool import NullPool
from sqlalchemy.orm import declarative_base
from uuid import uuid4
from .config import get_settings

settings = get_settings()

DATABASE_URL = settings.database_url

print(f"--- DATABASE_URL ИСПОЛЬЗУЕТСЯ: {DATABASE_URL} ---")

connect_args = {
    "statement_cache_size": 0,
    "prepared_statement_cache_size": 0,
    "server_settings": {
        "application_name": "living-diary-app",
        "statement_timeout": "30000",
    },
}

async_engine = create_async_engine(
    DATABASE_URL, connect_args=connect_args, poolclass=NullPool, pool_pre_ping=True
)

AsyncLocalSession = async_sessionmaker(bind=async_engine, expire_on_commit=False)


Base = declarative_base()


async def get_db():
    async with AsyncLocalSession() as session:
        yield session

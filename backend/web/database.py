from sqlalchemy.ext.asyncio.engine import create_async_engine
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy.orm import declarative_base, sessionmaker
from .config import get_settings

settings = get_settings()

DATABASE_URL = settings.database_url

async_engine = create_async_engine(DATABASE_URL)

AsyncLocalSession = sessionmaker(
    bind=async_engine, class_=AsyncSession, expire_on_commit=False
)


Base = declarative_base()


async def get_db():
    async with AsyncLocalSession() as session:
        yield session

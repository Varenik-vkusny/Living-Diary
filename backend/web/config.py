from pydantic_settings import SettingsConfigDict, BaseSettings
from pydantic import computed_field
from functools import lru_cache


class Settings(BaseSettings):
    db_driver: str = "postgresql+asyncpg"
    db_user: str
    db_password: str
    db_host: str
    db_port: int
    db_name: str
    db_pooler_params: str = ""

    db_direct_port: int

    gemini_api_key: str

    celery_broker_url: str
    celery_result_backend: str

    bot_token: str

    @computed_field
    @property
    def database_url(self) -> str:
        return (
            f"{self.db_driver}://{self.db_user}:{self.db_password}"
            f"@{self.db_host}:{self.db_port}/{self.db_name}{self.db_pooler_params}"
        )

    @computed_field
    @property
    def direct_url(self) -> str:
        return (
            f"{self.db_driver}://{self.db_user}:{self.db_password}"
            f"@{self.db_host}:{self.db_direct_port}/{self.db_name}"
        )

    model_config = SettingsConfigDict(env_file=".env.docker", extra="ignore")


@lru_cache
def get_settings():
    settings = Settings()

    return settings

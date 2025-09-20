from pydantic_settings import SettingsConfigDict
from pydantic import computed_field


class Settings:
    db_driver: str = "postgres+asyncpg"
    db_user: str
    db_password: str
    db_host: str
    db_port: int
    db_name: str
    db_pooler_params: str = ""

    db_direct_port: str

    @computed_field
    @property
    def database_url(self):
        return f"{self.db_driver}://{self.db_host}:{self.db_password}@{self.db_host}:{self.db_port}/{self.db_name}{self.db_pooler_params}"

    @computed_field
    @property
    def direct_url(self):
        return f"{self.db_driver}://{self.db_host}:{self.db_password}@{self.db_host}:{self.db_direct_port}/{self.db_name}"

    model_config = SettingsConfigDict(env_file=".env", extra="True")


def get_settings():
    return Settings()

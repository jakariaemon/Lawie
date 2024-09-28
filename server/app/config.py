import os

from pydantic_settings import BaseSettings


class Settings(BaseSettings):
    SECRET_KEY: str
    ALGORITHM: str = "HS256"
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    DATABASE_URL: str = (
        f"sqlite:///{os.path.join(os.path.dirname(__file__), 'sql_app.db')}"
    )
    SMTP_HOST: str
    SMTP_PORT: int
    SMTP_USER: str
    SMTP_PASSWORD: str
    FROM_EMAIL: str
    WORKERS: int
    API_TOKEN_PREDIBASE_1: str

    LOG_LEVEL: str

    DOMAIN_NAME: str

    ADMIN_EMAIL: str

    SERVICE_ACCOUNT_FILE: str
    UPSTAGE_API_KEY: str

    class Config:
        env_file = ".env"


settings = Settings()



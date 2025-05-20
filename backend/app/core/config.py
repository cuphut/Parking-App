import os
from dotenv import load_dotenv
from pydantic_settings import BaseSettings

load_dotenv()  # Đọc file .env

class Settings(BaseSettings):
    PROJECT_NAME: str = "Parking Management API"
    API_V1_STR: str = "/api/v1"
    SECRET_KEY: str = os.getenv("SECRET_KEY", "supersecretkey")
    ACCESS_TOKEN_EXPIRE_MINUTES: int = 30
    DATABASE_URL: str = os.getenv("DATABASE_URL")

settings = Settings()
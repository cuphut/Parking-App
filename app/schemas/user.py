from pydantic import BaseModel
from typing import Annotated
from pydantic.types import StringConstraints

class UserBase(BaseModel):
    username: Annotated[str, StringConstraints(
        min_length=3,
        max_length=50,
        pattern=r"^[a-zA-Z0-9_]+$"
    )]

class UserCreate(UserBase):
    password: Annotated[str, StringConstraints(min_length=8)]
    role: bool = False

class UserResponse(UserBase):
    id: int
    role: bool

    class Config:
        from_attributes = True  # Cho phép ánh xạ từ ORM model

class UserLogin(BaseModel):
    username: Annotated[str, StringConstraints(
        min_length=3,
        max_length=50,
        pattern=r"^[a-zA-Z0-9_]+$"
    )]
    password: Annotated[str, StringConstraints(min_length=8)]

class UserChangePassword(BaseModel):
    new_password: Annotated[str, StringConstraints(min_length=8)]
from pydantic import BaseModel, EmailStr, Field
from typing import Optional
from datetime import datetime


class UserBase(BaseModel):
    name: str
    email: EmailStr


class UserCreate(UserBase):
    password: str = Field(..., min_length=8)
    repeat_password: str
    device_id: str
    device_type: str


class User(UserBase):
    id: int
    is_subscribed: bool
    subscription_type: str

    class Config:
        from_attributes = True


class Token(BaseModel):
    access_token: str
    token_type: str
    user: dict


class TokenData(BaseModel):
    email: Optional[str] = None


class PasswordReset(BaseModel):
    token: str
    new_password: str = Field(..., min_length=8)


class Message(BaseModel):
    message: str


class ContactRequest(BaseModel):
    email: EmailStr
    message: str


class ChatRequest(BaseModel):
    user_id: str
    conversation_id: str
    request_id: str
    device_id: str
    subscription: bool
    message: str
    adapter_id: str


class ChatResponse(BaseModel):
    response: str


class ChatHistoryResponse(BaseModel):
    user_id: str
    conversation_id: str
    request_id: str
    device_id: str
    subscription: bool
    message: str
    response: str
    timestamp: datetime

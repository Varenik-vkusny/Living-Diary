from pydantic import BaseModel, ConfigDict, EmailStr
from datetime import datetime
from typing import Optional


class UserOut(BaseModel):
    id: int
    username: str
    email: EmailStr

    model_config = ConfigDict(from_attributes=True)


class UserUpdate(BaseModel):
    username: Optional[str] = None
    email: Optional[EmailStr] = None


class NoteIn(BaseModel):
    title: str
    content: str


class NoteInBot(NoteIn):
    userId: str


class NoteOut(NoteIn):
    id: int
    created_at: datetime
    owner: UserOut

    model_config = ConfigDict(from_attributes=True)


class NoteOutWithComment(NoteOut):
    comment: str

    model_config = ConfigDict(from_attributes=True)


class NoteUpdate(BaseModel):
    title: Optional[str] = None
    content: Optional[str] = None


class UserInChatId(BaseModel):
    user_uid: str
    chat_id: int

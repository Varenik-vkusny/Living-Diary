from fastapi import APIRouter, Depends, status
from .. import models
from ..dependencies import get_current_user


router = APIRouter()


@router.post("/notes", status_code=status.HTTP_200_OK)
async def create_note(current_user: models.User = Depends(get_current_user)):
    return {
        "message": f"Заметка создана для пользователя с ID: {current_user.id} и email: {current_user.email}"
    }

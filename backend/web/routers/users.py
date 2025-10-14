from fastapi import APIRouter, Depends, status, HTTPException
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from ..dependencies import get_current_user
from ..database import get_db
from .. import models, schemas

router = APIRouter()


@router.patch("/me", response_model=schemas.UserOut, status_code=status.HTTP_200_OK)
async def patch_user(
    user_data: schemas.UserUpdate,
    current_user: models.User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    user_dict = user_data.model_dump(exclude_unset=True)

    for key, value in user_dict.items():
        setattr(current_user, key, value)

    await db.commit()
    await db.refresh(current_user)

    return current_user


@router.get("/me", response_model=schemas.UserOut, status_code=status.HTTP_200_OK)
async def get_user_info(
    current_user: models.User = Depends(get_current_user),
):

    return current_user


@router.post("/chat_id", status_code=status.HTTP_200_OK)
async def save_chat_id(
    user_data: schemas.UserInChatId, db: AsyncSession = Depends(get_db)
):

    user_res = await db.execute(
        select(models.User).where(models.User.firebase_uid == user_data.user_uid)
    )

    user = user_res.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND, detail="Юзер с таким id не найден!"
        )

    user.chat_id = user_data.chat_id

    await db.commit()

    return

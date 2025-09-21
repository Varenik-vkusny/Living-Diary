from fastapi import APIRouter, Depends, status
from sqlalchemy.ext.asyncio import AsyncSession
from ..dependencies import get_current_user, get_db
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

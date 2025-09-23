import logging
from firebase_admin import auth
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi import Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from .database import get_db
from . import models

logging.basicConfig(level=logging.INFO)

bearer_scheme = HTTPBearer()


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db),
) -> models.User:

    token = credentials.credentials

    try:

        decoded_token = auth.verify_id_token(token)
    except auth.ExpiredIdTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Token has expired"
        )

    firebase_uid = decoded_token["user_id"]
    logging.info(f"Токен валиден. Firebase UID: {firebase_uid}")

    user_result = await db.execute(
        select(models.User).where(models.User.firebase_uid == firebase_uid)
    )

    user_db = user_result.scalar_one_or_none()

    if not user_db:
        logging.info(f"Пользователь с UID {firebase_uid} не найден. Создаю нового.")
        new_user = models.User(
            username=decoded_token.get("name", "New User"),
            firebase_uid=firebase_uid,
            email=decoded_token.get("email"),
        )

        db.add(new_user)
        await db.commit()
        await db.refresh(new_user)
        logging.info(f"Новый пользователь создан с ID: {new_user.id} в нашей БД.")

        return new_user
    logging.info(f"Найден существующий пользователь с ID: {user_db.id} в нашей БД.")
    return user_db

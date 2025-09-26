import logging
from firebase_admin import auth
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi import Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from .database import get_db, AsyncLocalSession
from . import models
from .ai_service import get_ai_comment


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

    user_result = await db.execute(
        select(models.User).where(models.User.firebase_uid == firebase_uid)
    )

    user_db = user_result.scalar_one_or_none()

    if not user_db:
        new_user = models.User(
            username=decoded_token.get("name", "New User"),
            firebase_uid=firebase_uid,
            email=decoded_token.get("email"),
        )

        db.add(new_user)
        await db.commit()
        await db.refresh(new_user)

        return new_user
    return user_db


async def generate_and_save_ai_comment(user_firebase_uid: str) -> str:

    async with AsyncLocalSession() as db:
        try:
            logging.info("Начинается генерация")
            history_result = await db.execute(
                select(models.AI_context)
                .where(models.AI_context.owner_firebase_uid == user_firebase_uid)
                .order_by(models.AI_context.created_at.asc())
            )

            history_db = history_result.scalars().all()

            history = [
                {"role": record.role, "parts": [record.content]}
                for record in history_db
            ]

            comment = await get_ai_comment(history)

            logging.info(comment)

            ai_comment = models.AI_context(
                owner_firebase_uid=user_firebase_uid, content=comment, role="model"
            )

            db.add(ai_comment)
            await db.commit()

        except Exception as e:
            print(f"ОШИБКА В ФОНОВОЙ ЗАДАЧЕ: {e}")

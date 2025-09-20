from firebase_admin import auth
from fastapi.security import OAuth2PasswordBearer
from fastapi import Depends, HTTPException, status
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from .database import get_db
from . import models


oauth_token = OAuth2PasswordBearer(tokenUrl="/token")


async def get_current_user(
    token: str = Depends(oauth_token), db: AsyncSession = Depends(get_db)
) -> models.User:

    try:
        decoded_token = auth.verify_id_token(token)
    except auth.InvalidIdTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Invalid token"
        )
    except auth.ExpiredIdTokenError:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED, detail="Token has expired"
        )

    firebase_uid = decoded_token["uid"]

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

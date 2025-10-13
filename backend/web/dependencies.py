import logging
from firebase_admin import auth
from fastapi.security import HTTPBearer, HTTPAuthorizationCredentials
from fastapi import (
    Depends,
    HTTPException,
    status,
    Query,
    WebSocket,
    WebSocketDisconnect,
    Request,
)
from sqlalchemy import select
from sqlalchemy.ext.asyncio import AsyncSession
from .database import get_db
from .config import get_settings
from . import models

settings = get_settings()


logging.basicConfig(level=logging.INFO)

bearer_scheme = HTTPBearer()

INTERNAL_SECRET_KEY = settings.internal_secret_key


async def get_current_user(
    credentials: HTTPAuthorizationCredentials = Depends(bearer_scheme),
    db: AsyncSession = Depends(get_db),
) -> models.User | None:

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


async def get_current_user_ws(
    websocket: WebSocket, token: str = Query(...), db: AsyncSession = Depends(get_db)
) -> models.User | None:

    try:
        decoded_token = auth.verify_id_token(token)
    except auth.ExpiredIdTokenError:
        await websocket.close(code=1008, reason="Invalid authentication credentials")
        raise WebSocketDisconnect(code=1008)

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


async def verify_internal_secret_key(request: Request):

    internal_secret = request.headers.get("X-Internal-Secret")

    logging.info(f"Internal-secret: {internal_secret}")

    if internal_secret != INTERNAL_SECRET_KEY:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Invalid internal secret key",
        )


async def get_service_user(
    request: Request, db: AsyncSession = Depends(get_db)
) -> models.User | None:

    internal_secret = request.headers.get("X-Internal-Secret")

    logging.info(f"Internal-secret: {internal_secret}")

    if internal_secret != INTERNAL_SECRET_KEY:
        return None

    if request.method != "GET":
        return None

    user_id = request.query_params.get("userId")

    if not user_id:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Параметр 'userId' обязателен для сервисных GET-запросов.",
        )

    user_res = await db.execute(
        select(models.User).where(models.User.firebase_uid == user_id)
    )
    user = user_res.scalar_one_or_none()

    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail=f"Пользователь с userId '{user_id}' не найден.",
        )

    return user

import logging
from fastapi import (
    APIRouter,
    Depends,
    WebSocket,
    WebSocketDisconnect,
)
from datetime import datetime, timezone
from ..database import AsyncLocalSession
from .. import models
from ..dependencies import get_current_user_ws
from ..ai_service import get_ai_comment_streaming
from ..services import get_ai_history

logging.basicConfig(level=logging.INFO)

router = APIRouter()


@router.websocket("/ws")
async def send_message(
    websocket: WebSocket, user: models.User = Depends(get_current_user_ws)
):

    await websocket.accept()

    try:
        async with AsyncLocalSession() as db:
            while True:
                message_text = await websocket.receive_text()
                now_utc = datetime.now(timezone.utc)

                user_message = models.AIContext(
                    user_id=user.id, role="user", content=message_text
                )

                db.add(user_message)
                await db.commit()

                history = await get_ai_history(user.id, db)

                full_ai_comment = ""
                async for chunk in get_ai_comment_streaming(history, now_utc):
                    full_ai_comment += chunk
                    await websocket.send_text(chunk)

                async with AsyncLocalSession() as db:
                    new_ai_comment = models.AIContext(
                        user_id=user.id, role="model", content=full_ai_comment.strip()
                    )
                    db.add(new_ai_comment)
                    await db.commit()

    except WebSocketDisconnect:
        logging.info(f"Websocket соединение разорвано для user_id {user.id}")
    except Exception as e:
        logging.error(f"Ошибка в WebSocket для user {user.id}: {e}", exc_info=True)
        await websocket.close(code=1011, reason="An internal error occurred.")

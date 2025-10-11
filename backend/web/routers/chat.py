import logging
import re
import asyncio
from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect
from datetime import datetime, timezone
from .. import models
from ..dependencies import get_flexible_user
from ..ai_service import generate_comment_process, add_reminder_data_to_db
from ..services import get_ai_history
from ..database import AsyncLocalSession

logging.basicConfig(level=logging.INFO)

router = APIRouter()


@router.websocket("/ws")
async def send_message(
    websocket: WebSocket,
    user: models.User = Depends(get_flexible_user),
):

    await websocket.accept()

    try:
        while True:
            message_text = await websocket.receive_text()
            now_utc = datetime.now(timezone.utc)
            async with AsyncLocalSession() as db:

                user_message = models.AIContext(
                    user_id=user.id, role="user", content=message_text
                )

                db.add(user_message)
                await db.commit()

                history = await get_ai_history(user.id, db, now_utc)

                streaming_comment = generate_comment_process(
                    history[-1]["parts"][0], history[:-1], now_utc
                )

                full_comment = ""
                stream_buffer = ""
                reminder_marker = "[REMINDER:"

                async for chunk in streaming_comment:
                    full_comment += chunk
                    stream_buffer += chunk

                    if reminder_marker in stream_buffer:
                        marker_pos = stream_buffer.find(reminder_marker)
                        text_to_send = stream_buffer[:marker_pos]

                        if text_to_send:
                            await websocket.send_text(text_to_send)

                        stream_buffer = stream_buffer[marker_pos:]
                    else:
                        await websocket.send_text(stream_buffer)
                        stream_buffer = ""

                cleaned_comment = full_comment.strip()
                reg = r"\[REMINDER: (.*?) \| (.*?)\]"
                match = re.search(reg, cleaned_comment)

                if match:
                    datetime_str = match.group(1)
                    reminder_text = match.group(2).strip()

                    try:
                        reminder_datetime = datetime.strptime(
                            datetime_str, "%Y-%m-%d %H:%M:%S"
                        )
                        asyncio.create_task(
                            add_reminder_data_to_db(
                                reminder_datetime,
                                reminder_text,
                                user.id,
                            )
                        )
                    except ValueError:
                        logging.info(
                            f"Ошибка: Не удалось преобразовать строку '{datetime_str}' в дату (проверьте формат)."
                        )
                    cleaned_comment = re.sub(reg, "", cleaned_comment).strip()

                if cleaned_comment:
                    new_ai_comment = models.AIContext(
                        user_id=user.id,
                        role="model",
                        content=cleaned_comment,
                    )
                    db.add(new_ai_comment)
                    await db.commit()

    except WebSocketDisconnect:
        logging.info(f"Websocket соединение разорвано для user_id {user.id}")
    except Exception as e:
        logging.error(f"Ошибка в WebSocket для user {user.id}: {e}", exc_info=True)
        await websocket.close(code=1011, reason="An internal error occurred.")

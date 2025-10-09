import logging
import re
from fastapi import APIRouter, Depends, WebSocket, WebSocketDisconnect, BackgroundTasks
from datetime import datetime, timezone
from ..database import AsyncLocalSession
from .. import models
from ..dependencies import get_current_user_ws
from ..ai_service import _generate_comment_process, add_reminder_data_to_db
from ..services import get_ai_history

logging.basicConfig(level=logging.INFO)

router = APIRouter()


@router.websocket("/ws")
async def send_message(
    websocket: WebSocket,
    user: models.User = Depends(get_current_user_ws),
):

    await websocket.accept()
    background_tasks = BackgroundTasks()

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

                streaming_comment = _generate_comment_process(
                    history[-1]["parts"][0], history[:-1], now_utc
                )

                full_comment = ""
                async for chunk in streaming_comment:
                    await websocket.send_text(chunk)
                    full_comment += chunk

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
                        background_tasks.add_task(
                            add_reminder_data_to_db,
                            reminder_datetime,
                            reminder_text,
                            user.id,
                        )
                    except ValueError:
                        logging.info(
                            f"Ошибка: Не удалось преобразовать строку '{datetime_str}' в дату (проверьте формат)."
                        )

                    cleaned_comment = re.sub(reg, "", cleaned_comment).strip()

                if cleaned_comment:
                    async with AsyncLocalSession() as session_for_saving:
                        new_ai_comment = models.AIContext(
                            user_id=user.id,
                            role="model",
                            content=cleaned_comment,
                        )
                        session_for_saving.add(new_ai_comment)
                        await session_for_saving.commit()

                await background_tasks()

    except WebSocketDisconnect:
        logging.info(f"Websocket соединение разорвано для user_id {user.id}")
    except Exception as e:
        logging.error(f"Ошибка в WebSocket для user {user.id}: {e}", exc_info=True)
        await websocket.close(code=1011, reason="An internal error occurred.")

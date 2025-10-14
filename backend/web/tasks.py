import logging
import asyncio
from sqlalchemy import select, update
from sqlalchemy.orm import selectinload
from datetime import datetime, timezone
from telegram import Bot
from . import models
from .celery_app import celery
from .database import AsyncLocalSession
from .config import get_settings

logging.basicConfig(level=logging.INFO)

settings = get_settings()

BOT_TOKEN = settings.bot_token
CHAT_ID = settings.chat_id

bot = Bot(token=BOT_TOKEN)


@celery.task
async def check_reminders():

    logging.info("Celery проверяет активные напоминания...")

    async with AsyncLocalSession() as session:
        try:
            utc_now = datetime.now(timezone.utc)
            active_reminders_res = await session.execute(
                select(models.Reminder)
                .where(
                    models.Reminder.reminder_at == utc_now,
                    models.Reminder.is_active == True,
                )
                .options(selectinload(models.Reminder.user))
            )

            active_reminders = active_reminders_res.scalars().all()

            if not active_reminders:
                logging.info("Нет ни одного активного напоминания")
                return

            for reminder in active_reminders:
                user = reminder.user
                if user:
                    # if user and user.chat_id:
                    logging.info(
                        f"Отправляю напоминания для юзера {reminder.user_id} с текстом {reminder.content}"
                    )

                    await bot.send_message(chat_id=user.chat_id, text=reminder.content)
                else:
                    logging.info("Не удалось найти юзера для отправки уведомления!")

            logging.info("Все напоминания отправлены!")

            reminder_ids = [r.id for r in active_reminders]

            update_r = (
                update(models.Reminder)
                .where(models.Reminder.id.in_(reminder_ids))
                .values(is_active=False)
            )

            await session.execute(update_r)
            await session.commit()

            logging.info(
                f"Успешно обработано и деактивировано {len(reminder_ids)} напоминаний."
            )
        except Exception as e:
            logging.error(f"Ошибка при обработке напоминаний: {e}", exc_info=True)
            await session.rollback()

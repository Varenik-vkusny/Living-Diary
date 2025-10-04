import logging
import asyncio
from sqlalchemy import select, update
from datetime import datetime, timezone
from . import models
from .celery_app import celery
from .database import create_async_engine, sessionmaker, AsyncSession
from .config import get_settings

logging.basicConfig(level=logging.INFO)


@celery.task
def check_reminders():

    asyncio.run(process_reminders())


async def process_reminders():

    settings = get_settings()
    engine = create_async_engine(settings.database_url)
    AsyncSessionLocal = sessionmaker(
        bind=engine, class_=AsyncSession, expire_on_commit=False
    )

    logging.info("Celery проверяет активные напоминания...")

    async with AsyncSessionLocal() as session:
        try:
            utc_now = datetime.now(timezone.utc)
            active_reminders_res = await session.execute(
                select(models.Reminder).where(
                    models.Reminder.reminder_at >= utc_now,
                    models.Reminder.is_active == True,
                )
            )

            active_reminders = active_reminders_res.scalars().all()

            if not active_reminders:
                logging.info("Нет ни одного активного напоминания")
                return

            for reminder in active_reminders:
                logging.info(
                    f"Отправляю напоминания для юзера {reminder.user_id} с текстом {reminder.content}"
                )

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

    await engine.dispose()

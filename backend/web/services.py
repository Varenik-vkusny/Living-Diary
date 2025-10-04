import logging
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from datetime import datetime
from . import models
from .ai_service import summary_ai_context

logging.basicConfig(level=logging.INFO)

CONTEXT_MAX_SYMBOLS = 100000


async def get_ai_history(user_id: int, db: AsyncSession, now_utc: datetime):
    history_result = await db.execute(
        select(models.AIContext)
        .where(models.AIContext.user_id == user_id)
        .order_by(models.AIContext.created_at.asc())
    )

    history_db = history_result.scalars().all()

    if sum(len(record.content) for record in history_db) > CONTEXT_MAX_SYMBOLS:

        logging.info("Порог контекста превышен. Запускаю суммаризацию.")

        last_user_record = history_db.pop()

        full_history = "\n".join(
            [
                f"{rec.role}: {rec.content} [created at {rec.created_at.strftime('%Y-%m-%d %H:%M')}]"
                for rec in history_db
            ]
        )

        shorted_history = await summary_ai_context(full_history, now_utc)

        for record in history_db:
            await db.delete(record)

        summary_context = models.AIContext(
            user_id=user_id,
            role="user",
            content=f"Summary of our past conversations: {shorted_history}",
        )

        db.add(summary_context)
        await db.commit()

        history_db = [summary_context, last_user_record]

    history = [
        {
            "role": record.role,
            "parts": [
                f"{record.content} [created at {record.created_at.strftime('%Y-%m-%d %H:%M')}]"
            ],
        }
        for record in history_db
    ]

    if not history:
        raise ValueError("История для генерации комментария пуста.")

    return history

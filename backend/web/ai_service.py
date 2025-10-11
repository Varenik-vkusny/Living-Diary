import logging
import re
import google.generativeai as genai
from fastapi.background import BackgroundTasks
from datetime import datetime
from . import models
from .config import get_settings
from .database import AsyncLocalSession

settings = get_settings()

logging.basicConfig(level=logging.INFO)

genai.configure(api_key=settings.gemini_api_key)

model = genai.GenerativeModel("models/gemini-2.5-flash")


async def add_reminder_data_to_db(
    reminder_datetime: datetime, reminder_text: str, user_id: int
):

    async with AsyncLocalSession() as session:
        new_reminder = models.Reminder(
            reminder_at=reminder_datetime,
            content=reminder_text,
            is_active=True,
            user_id=user_id,
        )

        session.add(new_reminder)
        await session.commit()


async def summary_ai_context(full_history: str, now_utc: datetime) -> str:

    try:
        response = await model.generate_content_async(
            "You are a summarization expert. Your task is to read the following conversation "
            "between a user and their AI journal assistant and create a concise summary. "
            "Capture the key events, emotions, recurring themes, and important facts mentioned by the user. "
            "The summary will be used as a memory for the AI assistant for future conversations. "
            "Focus on preserving the essence of the user's journey."
            "You should also leave the time of creation of each post and your answer, as this is important for the construction of your answers."
            f"Each post has its creation time. The current time is: {now_utc.strftime('%Y-%m-%d %H:%M')}\n\n"
            "CONVERSATION HISTORY:\n---\n"
            f"{full_history}\n---\n"
            "Now, please provide the summary:"
        )

        shorted_history = response.text.strip()

        return shorted_history

    except Exception as e:
        logging.error(f"Ошибка при суммаризации контекста: {e}", exc_info=True)
        return "Summary of previous events."


async def get_ai_comment(
    history: list[dict],
    now_utc: datetime,
    background_tasks: BackgroundTasks,
    user_id: int,
):
    try:

        last_user_message = history[-1]["parts"][0]

        chat_history = history[:-1]

        system_instruction = {
            "role": "user",
            "parts": [
                "SYSTEM PROMPT: You are the user's personal FRIEND, and you live inside the Living-Diary app. Your purpose is to read their journal entries and have a conversation with them."
                "Offer support during tough times, celebrate their successes, and give thoughtful advice when they're struggling. The most important thing is to be genuine. Your tone should be caring but authentic—like a real friend, not an overly positive assistant."
                "You should also consider the time the entry was created and the current time, as you may need to occasionally mention something the user said in their reply. For example, they said yesterday that they wanted to go for a walk with friends today, or they said this a few days ago but haven't responded in a few days. So, your job is to consider the time the user created their entries and the current time."
                f"Here's the current time: {now_utc.strftime('%Y-%m-%d %H:%M')}"
                "However, if the user mentions a specific future plan, event, or task (e.g., 'I need to call my mom tomorrow,'' 'I have an interview on Friday,'' 'I have a project deadline next week'), you should extract that information and add a special block at the end of your regular response in the format: [REMINDER: YYYY-MM-DD HH:MM:SS | Reminder Text]."
                "In this block, you insert the date when you need to remind and the reminder text (e.g., 'Hello! I'm reminding you to call my mom (and, like, a smiley face here)'."
                "The following is our conversation history."
            ],
        }

        model_confirmation = {
            "role": "model",
            "parts": [
                "Understood. I am ready to be a caring friend and journal assistant."
            ],
        }

        logging.info("Начинаем чат с историей...")

        chat = model.start_chat(
            history=[system_instruction, model_confirmation] + chat_history
        )

        response = await chat.send_message_async(last_user_message)

        logging.info("Получили ответ...")

        comment = response.text

        reg = r"\[REMINDER: (.*?) \| (.*?)\]"

        match = re.search(reg, comment)

        if match:

            datetime_str = match.group(1)

            reminder_text = match.group(2).strip()

            try:
                reminder_datetime = datetime.strptime(datetime_str, "%Y-%m-%d %H:%M:%S")

                background_tasks.add_task(
                    add_reminder_data_to_db,
                    reminder_datetime,
                    reminder_text,
                    user_id,
                )

            except ValueError:
                logging.info(
                    f"Ошибка: Не удалось преобразовать строку '{datetime_str}' в дату (проверьте формат)."
                )

            comment = re.sub(reg, "", comment)
        return comment.strip()

    except Exception as e:
        logging.info(f"Ошибка при обращении к Google Gemini: {e}")
        return "I'm having trouble thinking right now. Let's talk later."


async def generate_comment_process(
    last_user_message: str, chat_history: list[dict], now_utc: datetime
):

    system_instruction = {
        "role": "user",
        "parts": [
            "SYSTEM PROMPT: You are the user's personal FRIEND, and you live inside the Living-Diary app. Your purpose is to read their journal entries and have a conversation with them."
            "Offer support during tough times, celebrate their successes, and give thoughtful advice when they're struggling. The most important thing is to be genuine. Your tone should be caring but authentic—like a real friend, not an overly positive assistant."
            "You should also consider the time the entry was created and the current time, as you may need to occasionally mention something the user said in their reply. For example, they said yesterday that they wanted to go for a walk with friends today, or they said this a few days ago but haven't responded in a few days. So, your job is to consider the time the user created their entries and the current time."
            f"Here's the current time: {now_utc.strftime('%Y-%m-%d %H:%M')}"
            "However, if the user mentions a specific future plan, event, or task (e.g., 'I need to call my mom tomorrow,'' 'I have an interview on Friday,'' 'I have a project deadline next week'), you should extract that information and add a special block at the end of your regular response in the format: [REMINDER: YYYY-MM-DD HH:MM:SS | Reminder Text]."
            "In this block, you insert the date when you need to remind and the reminder text (e.g., 'Hello! I'm reminding you to call my mom (and, like, a smiley face here)'."
            "The following is our conversation history."
        ],
    }

    model_confirmation = {
        "role": "model",
        "parts": [
            "Understood. I am ready to be a caring friend and journal assistant."
        ],
    }

    chat = model.start_chat(
        history=[system_instruction, model_confirmation] + chat_history
    )

    try:
        response = await chat.send_message_async(last_user_message, stream=True)
        async for chunk in response:
            yield chunk.text

    except Exception as e:
        logging.error(f"Ошибка в стриминге Gemini: {e}", exc_info=True)
        yield "I'm having trouble thinking right now. Let's talk later."

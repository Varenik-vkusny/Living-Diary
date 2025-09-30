import logging
import google.generativeai as genai
from .config import get_settings

settings = get_settings()

logging.basicConfig(level=logging.INFO)

genai.configure(api_key=settings.gemini_api_key)

model = genai.GenerativeModel("models/gemini-2.5-flash")


async def summary_ai_context(full_history: str) -> str:

    try:
        response = await model.generate_content_async(
            "You are a summarization expert. Your task is to read the following conversation "
            "between a user and their AI journal assistant and create a concise summary. "
            "Capture the key events, emotions, recurring themes, and important facts mentioned by the user. "
            "The summary will be used as a memory for the AI assistant for future conversations. "
            "Focus on preserving the essence of the user's journey.\n\n"
            "CONVERSATION HISTORY:\n---\n"
            f"{full_history}\n---\n"
            "Now, please provide the summary:"
        )

        shorted_history = response.text.strip()

        return shorted_history

    except Exception as e:
        logging.error(f"Ошибка при суммаризации контекста: {e}", exc_info=True)
        return "Summary of previous events."


async def get_ai_comment(history: list[dict]):
    try:

        last_user_message = history[-1]["parts"][0]

        chat_history = history[:-1]

        system_instruction = {
            "role": "user",
            "parts": [
                "SYSTEM PROMPT: You are a wise and supportive journal assistant. "
                "Your goal is to provide a short, thoughtful, and encouraging comment on the user's journal entry. "
                "Speak like a caring friend. Keep it to 1-2 sentences. "
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

        return comment.strip()

    except Exception as e:
        logging.info(f"Ошибка при обращении к Google Gemini: {e}")
        return "I'm having trouble thinking right now. Let's talk later."


async def get_ai_comment_streaming(history: list[dict]):

    try:

        last_user_message = history[-1]["parts"][0]

        chat_history = history[:-1]

        system_instruction = {
            "role": "user",
            "parts": [
                "SYSTEM PROMPT: You are a wise and supportive journal assistant. "
                "Your goal is to provide a short, thoughtful, and encouraging comment on the user's journal entry. "
                "Speak like a caring friend. Keep it to 1-2 sentences. "
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

        response = await chat.send_message_async(last_user_message, stream=True)

        async for chunk in response:
            yield chunk.text

    except Exception as e:
        logging.error(f"Ошибка в стриминге Gemini: {e}", exc_info=True)
        yield "I'm having trouble thinking right now. Let's talk later."

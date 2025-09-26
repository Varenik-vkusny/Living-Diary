import logging
import google.generativeai as genai
from .config import get_settings

settings = get_settings()

logging.basicConfig(level=logging.INFO)

genai.configure(api_key=settings.gemini_api_key)

model = genai.GenerativeModel("gemini-2.5-flash")


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

        chat = model.start_chat(
            history=[system_instruction, model_confirmation] + chat_history
        )

        response = await chat.send_message_async(last_user_message)

        comment = response.text

        return comment.strip()

    except Exception as e:
        logging.info(f"Ошибка при обращении к Google Gemini: {e}")
        return "I'm having trouble thinking right now. Let's talk later."

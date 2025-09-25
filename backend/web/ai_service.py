import logging
import google.generativeai as genai
from .config import get_settings

settings = get_settings()

logging.basicConfig(level=logging.INFO)

genai.configure(api_key=settings.gemini_api_key)

model = genai.GenerativeModel("gemini-2.5-flash")


async def get_ai_comment(note_content: str):
    try:
        prompt = f"You're a personal friend to the user, whom you meet when they download the app. Your job is to be such a good friend that they'll want to come back later to make another entry. You're in the Live Diary app, bringing it to life and commenting on the user's new entries. Here is user`s content: {note_content}"

        response = await model.generate_content_async(prompt)

        comment = response.text

        return comment.strip()

    except Exception as e:
        logging.info(f"Ошибка при обращении к Google Gemini: {e}")
        return "I'm having trouble thinking right now. Let's talk later."

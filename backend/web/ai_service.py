from openai import AsyncOpenAI
from .config import get_settings

settings = get_settings()

client = AsyncOpenAI(api_key=settings.openai_api_key)


async def get_ai_comment(note_content: str) -> str:

    try:
        response = await client.chat.completions.create(
            model="gpt-3.5-turbo",
            messages=[
                {
                    "role": "system",
                    "content": "You're essentially the user's personal friend. Analyze their new blog post and comment on it. Be the kind of friend that makes them want to come back and make more posts.",
                },
                {"role": "user", "content": note_content},
            ],
        )

        comment = response.choices[0].message.content
        return comment.strip()
    except Exception as e:
        print(f"Ошибка при обращении к OpenAI: {e}")
        return "I'm having trouble thinking right now. Let's talk later."

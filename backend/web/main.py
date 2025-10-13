import firebase_admin
import logging
from fastapi import FastAPI
from fastapi.middleware.trustedhost import TrustedHostMiddleware
from contextlib import asynccontextmanager
from firebase_admin import credentials
from .routers import notes, users, chat

logging.basicConfig(level=logging.INFO)


@asynccontextmanager
async def lifespan(app: FastAPI):

    logging.info("Приложение запускается...")

    if not firebase_admin._apps:
        cred = credentials.Certificate("firebase-credentials.json")
        firebase_admin.initialize_app(cred)

    yield

    logging.info("Приложение останавливается...")


app = FastAPI(lifespan=lifespan)

app.add_middleware(
    TrustedHostMiddleware, allowed_hosts=["*.ngrok-free.app", "localhost", "127.0.0.1"]
)

app.include_router(notes.router, prefix="/notes", tags=["Notes"])
app.include_router(users.router, prefix="/users", tags=["Users"])
app.include_router(chat.router, prefix="/chat", tags=["Chat"])


@app.get("/")
async def hello():
    return {"message": "Hello!"}

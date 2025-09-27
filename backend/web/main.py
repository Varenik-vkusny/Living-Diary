import firebase_admin
import logging
from fastapi import FastAPI
from contextlib import asynccontextmanager
from firebase_admin import credentials
from .routers import notes, users

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

app.include_router(notes.router, prefix="/notes", tags=["Notes"])
app.include_router(users.router, prefix="/users", tags=["Users"])


@app.get("/")
async def hello():
    return {"message": "Hello!"}

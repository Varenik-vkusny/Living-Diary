import firebase_admin
from fastapi import FastAPI
from contextlib import asynccontextmanager
from firebase_admin import credentials
from .routers import notes

cred = credentials.Certificate("firebase-credentials.json")
firebase_admin.initialize_app(cred)


@asynccontextmanager
async def lifespan(app: FastAPI):

    yield


app = FastAPI(lifespan=lifespan)

app.include_router(notes.router)

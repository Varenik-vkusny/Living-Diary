import firebase_admin
from fastapi import FastAPI
from contextlib import asynccontextmanager
from firebase_admin import credentials
from .routers import notes, users

cred = credentials.Certificate("firebase-credentials.json")
firebase_admin.initialize_app(cred)


@asynccontextmanager
async def lifespan(app: FastAPI):

    yield


app = FastAPI(lifespan=lifespan)

app.include_router(notes.router, prefix="/notes", tags=["Notes"])
app.include_router(users.router, prefix="/users", tags=["Users"])


@app.get("/")
async def hello():
    return {"message": "Hello!"}

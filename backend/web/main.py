import firebase_admin
from fastapi import FastAPI, Request
from contextlib import asynccontextmanager
from firebase_admin import credentials
from .routers import notes, users


@asynccontextmanager
async def lifespan(app: FastAPI):

    if not firebase_admin._apps:
        cred = credentials.Certificate("firebase-credentials.json")
        firebase_admin.initialize_app(cred)

    yield


app = FastAPI(lifespan=lifespan)

app.include_router(notes.router, prefix="/notes", tags=["Notes"])
app.include_router(users.router, prefix="/users", tags=["Users"])


@app.post("/debug/headers")
async def debug_headers(request: Request):
    """
    Этот эндпоинт просто возвращает все заголовки,
    которые он получил в запросе.
    """
    return {"headers": dict(request.headers)}


@app.get("/")
async def hello():
    return {"message": "Hello!"}

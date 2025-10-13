import logging
from fastapi import APIRouter, Depends, status, HTTPException, BackgroundTasks
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from sqlalchemy.ext.asyncio import AsyncSession
from datetime import datetime, timezone
from .. import models, schemas
from ..dependencies import (
    get_current_user,
    verify_internal_secret_key,
    get_service_user,
)
from ..database import get_db
from ..ai_service import get_ai_comment
from ..services import get_ai_history


logging.basicConfig(level=logging.INFO)

router = APIRouter()


async def generate_and_save_ai_comment(
    user_id: int, db: AsyncSession, background_tasks: BackgroundTasks
) -> str:

    now_utc = datetime.now(timezone.utc)
    logging.info("Начинается генерация")

    history = await get_ai_history(user_id, db, now_utc)

    logging.info("Взяли историю...")

    comment = await get_ai_comment(history, now_utc, background_tasks, user_id)

    logging.info("Сгенерировали коммент от ИИ")

    logging.info(comment)

    ai_comment = models.AIContext(user_id=user_id, content=comment, role="model")

    db.add(ai_comment)
    await db.commit()
    await db.refresh(ai_comment)
    logging.info("Бд сработала")

    return ai_comment.content


@router.post(
    "/", response_model=schemas.NoteOutWithComment, status_code=status.HTTP_201_CREATED
)
async def create_note(
    note: schemas.NoteIn,
    backgroundtasks: BackgroundTasks,
    current_user: models.User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):

    new_note = models.Note(**note.model_dump(), owner_id=current_user.id)

    user_comment = models.AIContext(
        user_id=current_user.id,
        role="user",
        content=new_note.content,
    )

    db.add_all([new_note, user_comment])
    await db.commit()
    logging.info("Бд сработала")

    ai_comment = await generate_and_save_ai_comment(
        current_user.id, db, backgroundtasks
    )

    await db.refresh(new_note, ["owner"])
    logging.info("Бд сработала")

    new_note.comment = ai_comment
    logging.info("Бд сработала")

    return new_note


@router.post(
    "/bot/", response_model=schemas.NoteOut, status_code=status.HTTP_201_CREATED
)
async def create_note_bot(
    note: schemas.NoteInBot,
    _=Depends(verify_internal_secret_key),
    db: AsyncSession = Depends(get_db),
):

    logging.info(f"Firebase Айди юзера: {note.userId}")

    user_res = await db.execute(
        select(models.User).where(models.User.firebase_uid == note.userId)
    )

    user_db = user_res.scalar_one_or_none()

    new_note = models.Note(title=note.title, content=note.content, owner_id=user_db.id)

    user_comment = models.AIContext(
        user_id=user_db.id,
        role="user",
        content=new_note.content,
    )

    db.add_all([new_note, user_comment])
    await db.commit()
    logging.info("Бд сработала")

    await db.refresh(new_note, ["owner"])
    logging.info("Бд сработала")

    return new_note


@router.get("/", response_model=list[schemas.NoteOut], status_code=status.HTTP_200_OK)
async def get_notes(
    current_user: models.User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):

    notes_res = await db.execute(
        select(models.Note)
        .options(selectinload(models.Note.owner))
        .where(models.Note.owner_id == current_user.id)
        .order_by(models.Note.created_at.desc())
    )
    logging.info("Бд сработала")

    notes_db = notes_res.scalars().all()
    logging.info("Бд сработала")

    if not notes_db:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="У вас еще нет записей, создайте новые!",
        )

    return notes_db


@router.get(
    "/bot/", response_model=list[schemas.NoteOut], status_code=status.HTTP_200_OK
)
async def get_notes_bot(
    current_user: models.User = Depends(get_service_user),
    db: AsyncSession = Depends(get_db),
):

    if current_user is None:
        raise HTTPException(
            status_code=status.HTTP_400_BAD_REQUEST,
            detail="Не удалось найти internal_secret_key",
        )

    notes_res = await db.execute(
        select(models.Note)
        .options(selectinload(models.Note.owner))
        .where(models.Note.owner_id == current_user.id)
        .order_by(models.Note.created_at.desc())
    )
    logging.info("Бд сработала")

    notes_db = notes_res.scalars().all()
    logging.info("Бд сработала")

    if not notes_db:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="У вас еще нет записей, создайте новые!",
        )

    return notes_db


@router.patch(
    "/{note_id}", response_model=schemas.NoteOut, status_code=status.HTTP_200_OK
)
async def patch_note(
    note_id: int,
    note_data: schemas.NoteUpdate,
    current_user: models.User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):
    note_res = await db.execute(select(models.Note).where(models.Note.id == note_id))

    note_db = note_res.scalar_one_or_none()

    if not note_db:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Записи с таким id не найдено!",
        )

    if note_db.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Эта запись вам не принадлежит! Вы не можете ее редактировать!",
        )

    note_dict = note_data.model_dump(exclude_unset=True)

    for key, value in note_dict.items():
        setattr(note_db, key, value)

    await db.commit()
    await db.refresh(note_db)

    return note_db


@router.delete("/{note_id}", status_code=status.HTTP_204_NO_CONTENT)
async def delete_note(
    note_id: int,
    current_user: models.User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):

    note_res = await db.execute(select(models.Note).where(models.Note.id == note_id))

    note_db = note_res.scalar_one_or_none()

    if not note_db:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="Записи с таким id не найдено!",
        )

    if note_db.owner_id != current_user.id:
        raise HTTPException(
            status_code=status.HTTP_403_FORBIDDEN,
            detail="Эта запись вам не принадлежит! Вы не можете ее удалить!",
        )

    await db.delete(note_db)
    await db.commit()

    return

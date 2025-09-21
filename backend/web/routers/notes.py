from fastapi import APIRouter, Depends, status, HTTPException
from fastapi.background import BackgroundTasks
from sqlalchemy.ext.asyncio import AsyncSession
from sqlalchemy import select
from sqlalchemy.orm import selectinload
from .. import models, schemas
from ..dependencies import get_current_user, get_db
from ..ai_service import get_ai_comment


router = APIRouter()


async def generate_and_save_ai_comment(note_id: int, db: AsyncSession) -> str:

    note = await db.get(models.Note, note_id)

    if not note:
        return

    comment = await get_ai_comment(note.content)

    note.comment = comment
    await db.commit()


@router.post("/", response_model=schemas.NoteOut, status_code=status.HTTP_200_OK)
async def create_note(
    note: schemas.NoteIn,
    background_tasks: BackgroundTasks,
    current_user: models.User = Depends(get_current_user),
    db: AsyncSession = Depends(get_db),
):

    new_note = models.Note(
        **note.model_dump(),
        owner_id=current_user.id,
        owner_firebase_uid=current_user.firebase_uid
    )

    db.add(new_note)
    await db.commit()
    await db.refresh(new_note)

    background_tasks.add_task(generate_and_save_ai_comment, new_note.id, db)

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

    notes_db = notes_res.scalars().all()

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

    await db.delete()
    await db.commit()

    return

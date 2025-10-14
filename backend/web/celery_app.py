from celery import Celery
from celery.schedules import crontab
from .config import get_settings


settings = get_settings()

celery = Celery(
    "tasks",
    broker=settings.celery_broker_url,
    backend=settings.celery_result_backend,
    include=["backend.web.tasks"],
)


celery.conf.beat_schedule = {
    "check-reminders-every-minute": {
        "task": "backend.web.tasks.check_reminders",
        "schedule": crontab(minute="*/2"),
    }
}

celery.conf.timezone = "UTC"

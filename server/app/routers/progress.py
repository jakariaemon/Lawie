from fastapi import APIRouter, HTTPException
from sqlalchemy.orm import sessionmaker
from app.models import ProgressStatus
from app.database import engine

router = APIRouter(prefix="/progress", tags=["progress"])


@router.get("/{user_id}/{task_id}")
async def get_progress(user_id: int, task_id: int):
    Session = sessionmaker(bind=engine)
    with Session() as session:
        progress = (
            session.query(ProgressStatus)
            .filter_by(user_id=user_id, task_id=task_id)
            .first()
        )
        if progress:
            return {"status": progress.status, "updated_at": progress.updated_at}
        else:
            raise HTTPException(status_code=404, detail="Progress not found")

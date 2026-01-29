from fastapi import APIRouter
from exercise.height import HeightExercise

router = APIRouter()

@router.post("/height")
def calculate_height(payload: dict):
    video_path = payload.get("video_path")
    return HeightExercise(video_path).run()

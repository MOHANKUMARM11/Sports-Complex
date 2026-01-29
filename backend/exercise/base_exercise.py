import cv2
from services.pose_service import PoseService

class BaseExercise:
    def __init__(self, video_path):
        self.video_path = video_path
        self.pose_service = PoseService()
        self.cap = cv2.VideoCapture(video_path)

    def run(self):
        raise NotImplementedError("Must implement run()")

    def release(self):
        self.cap.release()

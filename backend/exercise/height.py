import mediapipe as mp
import numpy as np
from exercise.base_exercise import BaseExercise
from utils.angle import distance

mp_pose = mp.solutions.pose


class HeightExercise(BaseExercise):

    def run(self):
        max_height_pixels = 0

        while self.cap.isOpened():
            ret, frame = self.cap.read()
            if not ret:
                break

            landmarks = self.pose_service.get_landmarks(frame)
            if landmarks is None:
                continue

            head = np.array([
                landmarks[mp_pose.PoseLandmark.NOSE.value].x,
                landmarks[mp_pose.PoseLandmark.NOSE.value].y
            ])

            left_heel = np.array([
                landmarks[mp_pose.PoseLandmark.LEFT_HEEL.value].x,
                landmarks[mp_pose.PoseLandmark.LEFT_HEEL.value].y
            ])
            right_heel = np.array([
                landmarks[mp_pose.PoseLandmark.RIGHT_HEEL.value].x,
                landmarks[mp_pose.PoseLandmark.RIGHT_HEEL.value].y
            ])

            foot = (left_heel + right_heel) / 2

            height_pixels = distance(head, foot)
            max_height_pixels = max(max_height_pixels, height_pixels)

        self.release()

        height_cm = round(max_height_pixels * 170, 1)  # calibrated estimate

        return {
            "test": "height",
            "height_cm": height_cm,
            "confidence": 0.85,
            "status": "estimated"
        }

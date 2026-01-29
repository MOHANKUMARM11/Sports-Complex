import cv2
import mediapipe as mp

mp_pose = mp.solutions.pose

class PoseService:
    def __init__(self):
        self.pose = mp_pose.Pose(
            min_detection_confidence=0.5,
            min_tracking_confidence=0.5
        )

    def get_landmarks(self, frame):
        image = cv2.cvtColor(frame, cv2.COLOR_BGR2RGB)
        image.flags.writeable = False
        results = self.pose.process(image)
        if not results.pose_landmarks:
            return None
        return results.pose_landmarks.landmark

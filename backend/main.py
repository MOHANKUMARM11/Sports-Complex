from fastapi import FastAPI
from api.height import router as height_router

app = FastAPI()
app.include_router(height_router)

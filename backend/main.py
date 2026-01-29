from fastapi import FastAPI
from api.height import router as height_router

app = FastAPI()

@app.get("/")
def root():
    return {"status": "Backend is running"}

app.include_router(height_router)

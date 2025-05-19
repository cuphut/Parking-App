from fastapi import FastAPI
from app.api.v1 import auth, registered_vehicle, parking_lot
from app.core.config import settings
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="Parking Management API", version="1.0")

# CORS middleware (nếu bạn cần cho app Flutter hoặc front-end khác gọi API)
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"], 
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

# Gắn các router API vào app
app.include_router(auth.router)
app.include_router(registered_vehicle.router)
app.include_router(parking_lot.router)
# app.include_router(detection.router, prefix="/api/v1/detection", tags=["detection"])

@app.get("/")
def root():
    return {"message": "Welcome to Parking Management API"}

# Nếu muốn chạy trực tiếp:
# uvicorn app.main:app --reload

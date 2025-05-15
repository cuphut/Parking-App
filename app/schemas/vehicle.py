# app/schemas/vehicle.py
from pydantic import BaseModel

class VehicleCreate(BaseModel):
    license_plate: str
    owner: str
    type: str

class VehicleOut(BaseModel):
    id: int
    license_plate: str
    owner: str
    type: str
    is_parked: bool

    class Config:
        orm_mode = True

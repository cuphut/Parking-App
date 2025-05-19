from pydantic import BaseModel
from typing import Annotated, Optional
from pydantic.types import StringConstraints
from datetime import datetime
from .registered_vehicle import VehicleResponse

class ParkingLotBase(BaseModel):
    license_plate: Annotated[str, StringConstraints(min_length=1, max_length=20)]
    entry_time: Optional[datetime] = None
    exit_time: Optional[datetime] = None

class ParkingLotCreate(ParkingLotBase):
    pass

class ParkingLotResponse(ParkingLotBase):
    id: int
    registered_vehicle: Optional[VehicleResponse] = None

    class Config:
        from_attributes = True
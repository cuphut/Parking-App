from sqlalchemy import Column, Integer, String, ForeignKey, DateTime
from sqlalchemy.orm import relationship
from app.db.session import Base
from datetime import datetime

class ParkingLot(Base):
    __tablename__ = "parking_lot"

    id = Column(Integer, primary_key=True, autoincrement=True)
    license_plate = Column(String, ForeignKey("registered_vehicles.license_plate", ondelete="CASCADE"), nullable=False)
    entry_time = Column(DateTime, default=datetime.utcnow)
    exit_time = Column(DateTime, nullable=True)

    registered_vehicles = relationship("RegisteredVehicle", back_populates="parking_lot")

    def __repr__(self):
        return f"<Parking {self.license_plate}>"

from sqlalchemy import Column, String, Text, Integer
from sqlalchemy.orm import relationship
from app.db.session import Base

class RegisteredVehicle(Base):
    __tablename__ = "registered_vehicles"

    license_plate = Column(String, primary_key=True)
    owner_name = Column(String, nullable=False)
    phone_number = Column(String, nullable=False)
    company = Column(String, nullable=True)
    floor_number = Column(Integer, nullable=True)
    image_path = Column(Text, nullable=True)

    parking_lot = relationship("ParkingLot", back_populates="registered_vehicles", cascade="all, delete")

    def __repr__(self):
        return f"<Vehicle {self.license_plate}>"

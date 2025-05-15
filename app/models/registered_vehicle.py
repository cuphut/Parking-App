from sqlalchemy import Column, String, Text
from sqlalchemy.orm import relationship
from app.db.session import Base

class RegisteredVehicle(Base):
    __tablename__ = "registered_vehicles"

    license_plate = Column(String, primary_key=True)
    owner_name = Column(String, nullable=False)
    phone_number = Column(String, nullable=False)
    company = Column(String, nullable=True)
    floor_number = Column(String, nullable=True)
    image_path = Column(Text, nullable=True)

    # Quan hệ One-to-Many với ParkingLot
    parking_records = relationship("ParkingLot", back_populates="vehicle", cascade="all, delete")

    def __repr__(self):
        return f"<Vehicle {self.license_plate}>"

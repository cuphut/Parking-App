from sqlalchemy.orm import Session
from sqlalchemy import and_
from app.models.parking_lot import ParkingLot
from app.models.registered_vehicle import RegisteredVehicle
from app.schemas.parking_lot import ParkingLotCreate, ParkingLotResponse
from datetime import datetime

class ParkingLotService:
    @staticmethod
    def create_parking_lot(db: Session, parking: ParkingLotCreate) -> ParkingLotResponse:
        """
        Tạo bản ghi bãi đỗ xe mới.

        Args:
            db: SQLAlchemy session
            parking: Schema chứa thông tin bản ghi bãi đỗ (license_plate, entry_time, exit_time)

        Returns:
            ParkingLotResponse: Thông tin bản ghi bãi đỗ đã tạo

        Raises:
            ValueError: Nếu license_plate không tồn tại trong registered_vehicles
        """
        # Kiểm tra xem license_plate có tồn tại trong registered_vehicles không
        db_vehicle = db.query(RegisteredVehicle).filter(RegisteredVehicle.license_plate == parking.license_plate).first()
        if not db_vehicle:
            raise ValueError("Vehicle not registered")

        db_parking = ParkingLot(
            license_plate=parking.license_plate,
            entry_time=datetime.utcnow(),
            exit_time=None
        )
        db.add(db_parking)
        db.commit()
        db.refresh(db_parking)
        return ParkingLotResponse.from_orm(db_parking)

    @staticmethod
    def get_parking_lot(db: Session, parking_id: int) -> ParkingLotResponse:
        """
        Lấy thông tin bản ghi bãi đỗ xe theo ID.

        Args:
            db: SQLAlchemy session
            parking_id: ID của bản ghi bãi đỗ

        Returns:
            ParkingLotResponse: Thông tin bản ghi bãi đỗ

        Raises:
            ValueError: Nếu bản ghi không tồn tại
        """
        db_parking = db.query(ParkingLot).filter(ParkingLot.id == parking_id).first()
        if not db_parking:
            raise ValueError("Parking record not found")
        return ParkingLotResponse.from_orm(db_parking)

    @staticmethod
    def get_vehicles_without_exit_time(db: Session) -> list[ParkingLotResponse]:
        """
        Lấy danh sách các phương tiện chưa có thời gian ra (exit_time là NULL).

        Args:
            db: SQLAlchemy session

        Returns:
            list[ParkingLotResponse]: Danh sách các bản ghi bãi đỗ chưa có exit_time
        """
        parking_records = db.query(ParkingLot).filter(ParkingLot.exit_time.is_(None)).all()
        return [ParkingLotResponse.from_orm(record) for record in parking_records]
    
    @staticmethod
    def update_exit_time(db: Session, parking_id: int) -> ParkingLotResponse:
        """
        Cập nhật thời gian ra (exit_time) cho bản ghi bãi đỗ xe thành thời gian hiện tại.

        Args:
            db: SQLAlchemy session
            parking_id: ID của bản ghi bãi đỗ

        Returns:
            ParkingLotResponse: Thông tin bản ghi bãi đỗ sau khi cập nhật

        Raises:
            ValueError: Nếu bản ghi không tồn tại hoặc đã có exit_time
        """
        db_parking = db.query(ParkingLot).filter(ParkingLot.id == parking_id).first()
        if not db_parking:
            raise ValueError("Parking record not found")
        if db_parking.exit_time is not None:
            raise ValueError("Exit time already set")

        db_parking.exit_time = datetime.utcnow()
        db.commit()
        db.refresh(db_parking)
        return ParkingLotResponse.from_orm(db_parking)
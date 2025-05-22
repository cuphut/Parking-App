from sqlalchemy.orm import Session
from sqlalchemy import desc
from app.models.parking_lot import ParkingLot
from app.models.registered_vehicle import RegisteredVehicle
from app.schemas.parking_lot import ParkingLotCreate, ParkingLotResponse
from datetime import datetime, timezone
from sqlalchemy.orm import joinedload

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
            raise ValueError("Chưa được đăng ký")

        db_parking = ParkingLot(
            license_plate=parking.license_plate,
            entry_time = datetime.now(timezone.utc),
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
    def get_parking_lot(db: Session) -> list[ParkingLotResponse]:
        """
        Lấy danh sách các phương tiện .

        Args:
            db: SQLAlchemy session

        Returns:
            list[ParkingLotResponse]: Danh sách các bản ghi bãi đỗ
        """
        parking_records = (
            db.query(ParkingLot)
            .options(joinedload(ParkingLot.registered_vehicles))
            .order_by(desc(ParkingLot.entry_time))
            .all()
        )
        return [ParkingLotResponse.from_orm(record) for record in parking_records]
    
    @staticmethod
    def get_vehicles_without_exit_time(db: Session) -> list[ParkingLotResponse]:
        """
        Lấy danh sách các phương tiện chưa có thời gian ra (exit_time là NULL).

        Args:
            db: SQLAlchemy session

        Returns:
            list[ParkingLotResponse]: Danh sách các bản ghi bãi đỗ chưa có exit_time
        """
        parking_records = (
            db.query(ParkingLot)
            .options(joinedload(ParkingLot.registered_vehicles))
            .filter(ParkingLot.exit_time.is_(None))
            .order_by(desc(ParkingLot.entry_time))
            .all()
        )
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

        db_parking.exit_time = datetime.now(timezone.utc)
        db.commit()
        db.refresh(db_parking)
        return ParkingLotResponse.from_orm(db_parking)
    
    @staticmethod
    def get_active_parking_by_plate(db: Session, license_plate: str):
        return db.query(ParkingLot).filter(
            ParkingLot.license_plate == license_plate,
            ParkingLot.exit_time == None
        ).first()

    @staticmethod
    def delete_parking(db: Session, license_plate: str) -> None:
        """
        Xóa phương tiện theo biển số.

        Args:
            db: SQLAlchemy session
            license_plate: Biển số phương tiện cần xóa

        Raises:
            ValueError: Nếu phương tiện không tồn tại
        """

        db_vehicle = db.query(ParkingLot).filter(ParkingLot.license_plate == license_plate).first()
        if not db_vehicle:
            raise ValueError("Vehicle not found")

        db.delete(db_vehicle)
        db.commit()
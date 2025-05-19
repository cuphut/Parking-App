from sqlalchemy.orm import Session
from app.models.registered_vehicle import RegisteredVehicle
from app.schemas.registered_vehicle import VehicleCreate, VehicleResponse
import re
from fastapi import UploadFile
from pathlib import Path
from datetime import datetime
import shutil

class VehicleService:

    @staticmethod
    def clean_license_plate(license_plate: str) -> str:
        """
        Xóa các ký tự đặc biệt khỏi biển số xe, chỉ giữ lại chữ và số.

        Args:
            license_plate: Biển số xe gốc

        Returns:
            str: Biển số xe đã được làm sạch
        """
        return re.sub(r'[^a-zA-Z0-9]', '', license_plate)

    @staticmethod
    def create_vehicle(db: Session, vehicle: VehicleCreate, image: UploadFile) -> VehicleResponse:
        """
        Tạo một phương tiện mới trong cơ sở dữ liệu.

        Args:
            db: SQLAlchemy session
            vehicle: Schema chứa thông tin phương tiện

        Returns:
            VehicleResponse: Schema chứa thông tin phương tiện đã tạo

        Raises:
            ValueError: Nếu biển số đã tồn tại
        """
        print('debug')
        clean_plate = VehicleService.clean_license_plate(vehicle.license_plate)
        vehicle.license_plate = clean_plate

        # Kiểm tra license_plate đã tồn tại chưa
        db_vehicle = db.query(RegisteredVehicle).filter(RegisteredVehicle.license_plate == vehicle.license_plate).first()
        if db_vehicle:
            raise ValueError("License plate already registered")
        
        # Kiểm tra định dạng file hình ảnh
        allowed_extensions = {'.jpg', '.jpeg', '.png'}
        file_extension = Path(image.filename).suffix.lower()
        if file_extension not in allowed_extensions:
            raise ValueError("Invalid image format. Only JPG, JPEG, PNG are allowed")

        # Tạo thư mục lưu trữ nếu chưa tồn tại
        upload_dir = Path("uploads/vehicles")
        upload_dir.mkdir(parents=True, exist_ok=True)
        print(upload_dir)

        # Tạo tên file duy nhất: license_plate + timestamp
        timestamp = datetime.utcnow().strftime("%Y%m%d%H%M%S")
        file_name = f"{vehicle.license_plate}_{timestamp}{file_extension}"
        file_path = upload_dir / file_name

        # Lưu file hình ảnh
        with file_path.open("wb") as buffer:
            shutil.copyfileobj(image.file, buffer)

        # Tạo đường dẫn tương đối để lưu vào database
        relative_path = f"/uploads/vehicles/{file_name}"

        # Tạo bản ghi phương tiện
        db_vehicle = RegisteredVehicle(
            license_plate=vehicle.license_plate,
            owner_name=vehicle.owner_name,
            phone_number=vehicle.phone_number,
            company=vehicle.company,
            floor_number=vehicle.floor_number,
            image_path=relative_path
        )
        db.add(db_vehicle)
        db.commit()
        db.refresh(db_vehicle)
        return VehicleResponse.from_orm(db_vehicle)

    @staticmethod
    def get_vehicle_by_license_plate(db: Session, license_plate: str) -> VehicleResponse:
        """
        Lấy thông tin phương tiện theo biển số.

        Args:
            db: SQLAlchemy session
            license_plate: Biển số phương tiện

        Returns:
            VehicleResponse: Schema chứa thông tin phương tiện

        Raises:
            ValueError: Nếu phương tiện không tồn tại
        """
        clean_plate = VehicleService.clean_license_plate(license_plate)
        license_plate = clean_plate

        db_vehicle = db.query(RegisteredVehicle).filter(RegisteredVehicle.license_plate == license_plate).first()
        if not db_vehicle:
            raise ValueError("Vehicle not found")
        return VehicleResponse.from_orm(db_vehicle)
    
    @staticmethod
    def get_all_vehicles(db: Session) -> VehicleResponse:
        """
        Lấy thông tin phương tiện theo biển số.

        Args:
            db: SQLAlchemy session
            license_plate: Biển số phương tiện

        Returns:
            VehicleResponse: Schema chứa thông tin phương tiện

        Raises:
            ValueError: Nếu phương tiện không tồn tại
        """
        vehicles = db.query(RegisteredVehicle).all()
        return [VehicleResponse.from_orm(vehicle) for vehicle in vehicles]

    @staticmethod
    def update_vehicle(db: Session, license_plate: str, vehicle_update: VehicleCreate) -> VehicleResponse:
        """
        Cập nhật thông tin phương tiện theo biển số.

        Args:
            db: SQLAlchemy session
            license_plate: Biển số phương tiện cần cập nhật
            vehicle_update: Schema chứa thông tin cập nhật

        Returns:
            VehicleResponse: Schema chứa thông tin phương tiện sau khi cập nhật

        Raises:
            ValueError: Nếu phương tiện không tồn tại
        """

        clean_plate = VehicleService.clean_license_plate(license_plate)
        license_plate = clean_plate

        clean_plate = VehicleService.clean_license_plate(vehicle_update.license_plate)
        vehicle_update.license_plate = clean_plate

        db_vehicle = db.query(RegisteredVehicle).filter(RegisteredVehicle.license_plate == license_plate).first()
        if not db_vehicle:
            raise ValueError("Vehicle not found")

        # Cập nhật các trường từ vehicle_update
        for key, value in vehicle_update.dict(exclude_unset=True).items():
            setattr(db_vehicle, key, value)

        db.commit()
        db.refresh(db_vehicle)
        return VehicleResponse.from_orm(db_vehicle)

    @staticmethod
    def delete_vehicle(db: Session, license_plate: str) -> None:
        """
        Xóa phương tiện theo biển số.

        Args:
            db: SQLAlchemy session
            license_plate: Biển số phương tiện cần xóa

        Raises:
            ValueError: Nếu phương tiện không tồn tại
        """

        clean_plate = VehicleService.clean_license_plate(license_plate)
        license_plate = clean_plate

        db_vehicle = db.query(RegisteredVehicle).filter(RegisteredVehicle.license_plate == license_plate).first()
        if not db_vehicle:
            raise ValueError("Vehicle not found")

        db.delete(db_vehicle)
        db.commit()
from fastapi import APIRouter, Depends, HTTPException, UploadFile, File
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.schemas.registered_vehicle import VehicleCreate, VehicleResponse
from app.services.registered_vehicle_service import VehicleService

router = APIRouter(prefix="/registered_vehicle", tags=["registered_vehicle"])

@router.post("/", response_model=VehicleResponse)
def create_vehicle(vehicle: VehicleCreate = Depends(VehicleCreate.as_form), image: UploadFile = File(...), db: Session = Depends(get_db)):
    """
    Tạo mới một phương tiện.

    Args:
        vehicle: Schema chứa thông tin phương tiện.
        db: SQLAlchemy session.

    Returns:
        VehicleResponse: Thông tin phương tiện đã tạo.

    Raises:
        HTTPException: Nếu biển số đã tồn tại (status code 400).
    """
    try:
        return VehicleService.create_vehicle(db, vehicle,image)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/vehicles", response_model=list[VehicleResponse])
def get_all_vehicles(db: Session = Depends(get_db)):
    """
    Lấy tất cả thông tin phương tiện.

    Args:
        db: SQLAlchemy session.

    Returns:
        list[VehicleResponse]: Danh sách thông tin tất cả xe đã đăng ký.
    """
    return VehicleService.get_all_vehicles(db)

@router.get("/{license_plate}", response_model=VehicleResponse)
def get_vehicle(license_plate: str, db: Session = Depends(get_db)):
    """
    Lấy thông tin phương tiện theo biển số.

    Args:
        license_plate: Biển số phương tiện.
        db: SQLAlchemy session.

    Returns:
        VehicleResponse: Thông tin phương tiện.

    Raises:
        HTTPException: Nếu phương tiện không tồn tại (status code 404).
    """
    try:
        
        return VehicleService.get_vehicle_by_license_plate(db, license_plate)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    


@router.put("/{license_plate}", response_model=VehicleResponse)
def update_vehicle(license_plate: str, vehicle: VehicleCreate, db: Session = Depends(get_db)):
    """
    Cập nhật thông tin phương tiện theo biển số.

    Args:
        license_plate: Biển số phương tiện cần cập nhật.
        vehicle: Schema chứa thông tin cập nhật.
        db: SQLAlchemy session.

    Returns:
        VehicleResponse: Thông tin phương tiện sau khi cập nhật.

    Raises:
        HTTPException: Nếu phương tiện không tồn tại (status code 404).
    """
    try:
        return VehicleService.update_vehicle(db, license_plate, vehicle)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

@router.delete("/{license_plate}")
def delete_vehicle(license_plate: str, db: Session = Depends(get_db)):
    """
    Xóa phương tiện theo biển số.

    Args:
        license_plate: Biển số phương tiện cần xóa.
        db: SQLAlchemy session.

    Returns:
        dict: Thông báo xóa thành công.

    Raises:
        HTTPException: Nếu phương tiện không tồn tại (status code 404).
    """
    try:
        VehicleService.delete_vehicle(db, license_plate)
        return {"message": "Vehicle deleted successfully"}
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
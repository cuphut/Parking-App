from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.schemas.parking_lot import ParkingLotCreate, ParkingLotResponse
from app.services.parking_lot_service import ParkingLotService

router = APIRouter(prefix="/parking-lot", tags=["parking-lot"])

@router.post("/", response_model=ParkingLotResponse)
def create_parking_lot(parking: ParkingLotCreate, db: Session = Depends(get_db)):
    """
    Tạo bản ghi bãi đỗ xe mới.

    Args:
        parking: Schema chứa thông tin bản ghi bãi đỗ (license_plate).
        db: SQLAlchemy session.

    Returns:
        ParkingLotResponse: Thông tin bản ghi bãi đỗ đã tạo.

    Raises:
        HTTPException: Nếu license_plate không tồn tại (status code 400).
    """
    try:
        return ParkingLotService.create_parking_lot(db, parking)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))

@router.get("/no-exit-time", response_model=list[ParkingLotResponse])
def get_vehicles_without_exit_time(db: Session = Depends(get_db)):
    """
    Lấy danh sách các phương tiện chưa có thời gian ra.

    Args:
        db: SQLAlchemy session.

    Returns:
        list[ParkingLotResponse]: Danh sách các bản ghi bãi đỗ chưa có exit_time.
    """
    return ParkingLotService.get_vehicles_without_exit_time(db)

@router.get("/", response_model=list[ParkingLotResponse])
def get_parking_lot(db: Session = Depends(get_db)):
    """
    Lấy danh sách các phương tiện chưa có thời gian ra.

    Args:
        db: SQLAlchemy session.

    Returns:
        list[ParkingLotResponse]: Danh sách các bản ghi bãi đỗ chưa có exit_time.
    """
    return ParkingLotService.get_parking_lot(db)

@router.get("/{id}", response_model=ParkingLotResponse)
def get_parking_lot(id: int, db: Session = Depends(get_db)):
    """
    Lấy thông tin bản ghi bãi đỗ xe theo ID.

    Args:
        id: ID của bản ghi bãi đỗ.
        db: SQLAlchemy session.

    Returns:
        ParkingLotResponse: Thông tin bản ghi bãi đỗ.

    Raises:
        HTTPException: Nếu bản ghi không tồn tại (status code 404).
    """
    try:
        return ParkingLotService.get_parking_lot(db, id)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))

@router.put("/exit/{parking_id}", response_model=ParkingLotResponse)
def set_exit_time(parking_id: int, db: Session = Depends(get_db)):
    try:
        return ParkingLotService.update_exit_time(db, parking_id)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    
@router.delete("/{license_plate}")
def delete_parking(license_plate: str, db: Session = Depends(get_db)):
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
        ParkingLotService.delete_parking(db, license_plate)
        return {"message": "Vehicle deleted successfully"}
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
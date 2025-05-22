from fastapi import APIRouter, UploadFile, File, Depends
from fastapi.responses import JSONResponse
from function.detect import detect_license_plates
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.schemas.parking_lot import ParkingLotCreate
from app.services.parking_lot_service import ParkingLotService

router = APIRouter(prefix="/detech-image", tags=["detech-image"])

@router.post("/")
async def upload_image(
    file: UploadFile = File(...),
    db: Session = Depends(get_db)
):
    if file.content_type not in ["image/jpeg", "image/png"]:
        return JSONResponse(status_code=400, content={"error": "Invalid image format"})

    image_bytes = await file.read()
    result = detect_license_plates(image_bytes)

    response_results = []
    for plate_data in result:
        plate_data_copy = plate_data.copy()  # Create a copy to avoid modifying original
        if plate_data.get("valid"):
            plate = plate_data["plate"]
            clean_plate = plate.replace("-", "").replace(" ", "")
            try:
                # Check if there's an active parking record
                active_parking = ParkingLotService.get_active_parking_by_plate(db, clean_plate)
                if active_parking:
                    # Update exit_time for the record
                    ParkingLotService.update_exit_time(db, active_parking.id)
                    plate_data_copy["operation"] = "exit"
                else:
                    # Create new entry_time record
                    parking_data = ParkingLotCreate(license_plate=clean_plate)
                    ParkingLotService.create_parking_lot(db, parking_data)
                    plate_data_copy["operation"] = "entry"
            except ValueError:
                plate_data_copy["operation"] = "error"
        else:
            plate_data_copy["operation"] = "invalid"
        response_results.append(plate_data_copy)

    return {"results": response_results}
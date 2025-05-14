from fastapi import FastAPI, File, UploadFile, HTTPException
from fastapi.responses import JSONResponse
from fastapi.middleware.cors import CORSMiddleware
from function.detect import detect_license_plates
from pydantic import BaseModel
from datetime import datetime
from database.database import (
    add_vehicle_to_db,
    delete_vehicle_from_db,
    get_vehicle_info,
    view_all_vehicle,
    create_vehicle_db,
    create_parking_table,
    add_parking_entry,
    view_all_parking,
    delete_parking_from_db
)


class VehicleInfo(BaseModel):
    plate: str
    name: str
    companyName: str
    companyFloor: str
    phone: str

app = FastAPI(title="License Plate Detector API")

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

create_vehicle_db()
create_parking_table()

@app.post("/upload-image")
async def upload_image(file: UploadFile = File(...)):
    if file.content_type not in ["image/jpeg", "image/png"]:
        return JSONResponse(status_code=400, content={"error": "Invalid image format"})
    
    image_bytes = await file.read()
    result = detect_license_plates(image_bytes)

    for plate_data in result:
        if plate_data.get("valid"):
            plate = plate_data["plate"]
            now = datetime.now().isoformat()
            add_parking_entry(plate, now)

    return {"results": result}


@app.post("/vehicles/")
def add_vehicle(info: VehicleInfo):
    try:
        add_vehicle_to_db(info.plate, info.name, info.companyName, info.companyFloor, info.phone)
        return {"message": "Thêm biển số thành công", "data": info}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.delete("/vehicles/{plate}")
def delete_vehicle(plate: str):
    try:
        delete_vehicle_from_db(plate)
        return {"message": f"Đã xoá biển số: {plate}"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/vehicles/")
def get_all_vehicles():
    try:
        rows = view_all_vehicle()
        return {"vehicles": [
            {
                "plate": row[0],
                "name": row[1],
                "companyName": row[2],
                "companyFloor": row[3],
                "phone": row[4],
            } for row in rows
        ]}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))

@app.get("/vehicles/{plate}")
def get_vehicle(plate: str):
    result = get_vehicle_info(plate)
    if result:
        return {
            "plate": result[0],
            "name": result[1],
            "companyName": result[2],
            "companyFloor": result[3],
            "phone": result[4],
        }
    raise HTTPException(status_code=404, detail="Không tìm thấy biển số")

@app.get("/parking/")
def get_all_parking():
    try:
        rows = view_all_parking()
        data = []
        for row in rows:
            plate, name, companyName, companyFloor, phone, timeIn, timeOut = row
            data.append({
                "plate": plate,
                "name": name,
                "companyName": companyName,
                "companyFloor": companyFloor,
                "phone": phone,
                "timeIn": timeIn,
                "timeOut": timeOut
            })
        return {"parking": data}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
    
@app.delete("/parking/{plate}")
def delete_parking(plate: str):
    try:
        delete_parking_from_db(plate)
        return {"message": f"Đã xoá biển số: {plate}"}
    except Exception as e:
        raise HTTPException(status_code=500, detail=str(e))
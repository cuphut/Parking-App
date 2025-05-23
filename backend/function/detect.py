import cv2
import torch
import numpy as np
from function import helper, utils_rotate
from app.services.registered_vehicle_service import VehicleService
from app.db.session import SessionLocal

# Load models chỉ 1 lần
yolo_LP_detect = torch.hub.load('yolov5', 'custom', path='model/LP_detector.pt', force_reload=True, source='local')
yolo_license_plate = torch.hub.load('yolov5', 'custom', path='model/LP_ocr.pt', force_reload=True, source='local')
yolo_license_plate.conf = 0.60

def preprocess_image(img):
    if len(img.shape) == 2:
        img = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    equalized = clahe.apply(gray)
    blurred = cv2.GaussianBlur(equalized, (3, 3), 0)
    sharpen_kernel = np.array([[0, -1, 0], [-1, 5, -1], [0, -1, 0]])
    sharpened = cv2.filter2D(blurred, -1, sharpen_kernel)
    return cv2.cvtColor(sharpened, cv2.COLOR_GRAY2BGR)

def format_license_plate(plate):
    plate = plate.strip().replace(" ", "")
    code = plate[:4]
    number = plate[4:]
    formatted_code = f"{code[:2]}-{code[2:]}"
    formatted_number = number
    return f"{formatted_code} {formatted_number}"

def detect_license_plates(image_bytes):
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    results = yolo_LP_detect(img, size=640)
    list_plates = results.pandas().xyxy[0].values.tolist()
    list_read_plates = set()
    results_info = []
    db = SessionLocal()

    if not list_plates:
        lp = helper.read_plate(yolo_license_plate, img)
        if lp != "unknown":
            list_read_plates.add(lp)
    else:
        for plate in list_plates:
            x1, y1, x2, y2 = map(int, plate[:4])
            crop_img = img[y1:y2, x1:x2]
            for cc in range(2):
                for ct in range(2):
                    preprocessed_img = preprocess_image(crop_img)
                    lp = helper.read_plate(yolo_license_plate, utils_rotate.deskew(preprocessed_img, cc, ct))
                    if lp != "unknown":
                        list_read_plates.add(lp)
                        break
                else:
                    continue
                break

    for plate in list_read_plates:
        try:
            info = VehicleService.get_vehicle_by_license_plate(db, plate)
            formatted_lp = format_license_plate(plate)
            results_info.append({
                "plate": formatted_lp,
                "name": info.owner_name,
                "companyName": info.company,
                "companyFloor": info.floor_number,
                "phone": info.phone_number,
                "valid": True
            })
        except ValueError:
            formatted_lp = format_license_plate(plate)
            results_info.append({
                "plate": formatted_lp,
                "message": "Chưa được đăng ký",
                "valid": False
            })


    return results_info
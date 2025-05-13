import cv2
import torch
import numpy as np
from function import helper, utils_rotate
from database.database import get_plate_info

# Load models chỉ 1 lần
yolo_LP_detect = torch.hub.load('yolov5', 'custom', path='model/LP_detector.pt', force_reload=True, source='local')
yolo_license_plate = torch.hub.load('yolov5', 'custom', path='model/LP_ocr.pt', force_reload=True, source='local')
yolo_license_plate.conf = 0.60

def preprocess_image(img):
    # Đảm bảo ảnh có 3 kênh
    if len(img.shape) == 2:
        img = cv2.cvtColor(img, cv2.COLOR_GRAY2BGR)

    # Chuyển sang grayscale
    gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    # Tăng tương phản bằng CLAHE (tốt hơn equalizeHist)
    clahe = cv2.createCLAHE(clipLimit=2.0, tileGridSize=(8, 8))
    equalized = clahe.apply(gray)

    # Làm mịn để giảm noise
    blurred = cv2.GaussianBlur(equalized, (3, 3), 0)

    # Tăng độ nét bằng kernel lọc
    sharpen_kernel = np.array([[0, -1, 0],
                               [-1, 5, -1],
                               [0, -1, 0]])
    sharpened = cv2.filter2D(blurred, -1, sharpen_kernel)

    # Trả ảnh dạng 3 kênh nếu pipeline cần ảnh màu
    return cv2.cvtColor(sharpened, cv2.COLOR_GRAY2BGR)


def detect_license_plates(image_bytes):
    nparr = np.frombuffer(image_bytes, np.uint8)
    img = cv2.imdecode(nparr, cv2.IMREAD_COLOR)
    results = yolo_LP_detect(img, size=640)
    list_plates = results.pandas().xyxy[0].values.tolist()
    list_read_plates = set()
    results_info = []

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
        info = get_plate_info(plate)
        if info:
            name, company, plate_number = info
            results_info.append({
                "plate": plate_number,
                "name": name,
                "company": company,
                "valid": True
            })
        else:
            results_info.append({
                "plate": plate,
                "name": None,
                "company": None,
                "valid": False
            })

    return results_info

from fastapi import FastAPI, File, UploadFile
from fastapi.responses import JSONResponse
from function.detect import detect_license_plates
from fastapi.middleware.cors import CORSMiddleware

app = FastAPI(title="License Plate Detector API")

# Optional: CORS cho phép gọi từ web frontend
app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],  # Sửa lại nếu cần hạn chế origin
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

@app.post("/upload-image")
async def upload_image(file: UploadFile = File(...)):
    if file.content_type not in ["image/jpeg", "image/png"]:
        return JSONResponse(status_code=400, content={"error": "Invalid image format"})
    
    image_bytes = await file.read()
    result = detect_license_plates(image_bytes)
    return {"results": result}

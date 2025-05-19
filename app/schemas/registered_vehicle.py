from pydantic import BaseModel, Field
from typing import Optional

class VehicleBase(BaseModel):
    license_plate: str = Field(
        ...,  # Bắt buộc
        title="Biển số xe",
        description="Biển số xe duy nhất (ví dụ: 29A-12345)",
        example="29A-12345",
        min_length=1,
        max_length=12
    )
    owner_name: str = Field(
        ...,  # Bắt buộc
        title="Tên chủ xe",
        description="Tên của chủ sở hữu phương tiện",
        example="Nguyen Van A",
        min_length=1,
        max_length=50
    )
    phone_number: str = Field(
        ...,  # Bắt buộc
        title="Số điện thoại",
        description="Số điện thoại của chủ xe (ví dụ: 0123456789)",
        example="0123456789",
        min_length=1,
        max_length=11
    )
    company: Optional[str] = Field(
        None,
        title="Công ty",
        description="Tên công ty (tùy chọn)",
        example="ABC Corp",
        max_length=100
    )
    floor_number: Optional[int] = Field(
        None,
        title="Số tầng",
        description="Tầng công ty",
        example=1,
        ge=0,
        le=999
    )
    image_path: Optional[str] = Field(
        None,
        title="Đường dẫn hình ảnh",
        description="Đường dẫn tới hình ảnh của xe",
        example="/uploads/vehicles/29A-12345_20250515174700.jpg",
        max_length=255
    )

class VehicleCreate(BaseModel):
    license_plate: str = Field(
        ..., min_length=6, max_length=12
    )
    owner_name: str = Field(
        ..., min_length=1, max_length=50
    )
    phone_number: str = Field(
        ..., min_length=10, max_length=11
    )
    company: Optional[str] = Field(None, max_length=100)
    floor_number: Optional[int] = Field(None, ge=0, le=999)

class VehicleResponse(VehicleBase):
    class Config:
        from_attributes = True
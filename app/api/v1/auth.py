from fastapi import APIRouter, Depends, HTTPException
from sqlalchemy.orm import Session
from app.db.session import get_db
from app.schemas.user import UserCreate, UserResponse, UserChangePassword, UserLogin
from app.services.user_service import UserService

router = APIRouter(prefix="/api/v1/auth", tags=["auth"])

@router.post("/register", response_model=UserResponse)
def register_user(user: UserCreate, db: Session = Depends(get_db)):
    """
    Đăng ký người dùng mới.

    Args:
        user: Schema chứa thông tin người dùng (username, password).
        db: SQLAlchemy session.

    Returns:
        UserResponse: Thông tin người dùng đã tạo (id, username, role).

    Raises:
        HTTPException: Nếu username đã tồn tại (status code 400).
    """
    try:
        return UserService.create_user(db, user)
    except ValueError as e:
        raise HTTPException(status_code=400, detail=str(e))
    
@router.get("/users/{username}", response_model=UserResponse)
def get_user_by_username(username: str, db: Session = Depends(get_db)):
    """
    Lấy thông tin người dùng theo username.

    Args:
        username: Tên người dùng cần tìm.
        db: SQLAlchemy session.

    Returns:
        UserResponse: Thông tin người dùng (id, username, role).

    Raises:
        HTTPException: Nếu người dùng không tồn tại (status code 404).
    """
    try:
        return UserService.get_user_by_username(db, username)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
    
@router.post("/login", response_model=UserResponse)
def login_user(user: UserLogin, db: Session = Depends(get_db)):
    """
    Đăng nhập người dùng.

    Args:
        user: Schema chứa thông tin đăng nhập (username, password).
        db: SQLAlchemy session.

    Returns:
        UserResponse: Thông tin người dùng (id, username, role).

    Raises:
        HTTPException: Nếu username hoặc password không đúng (status code 401).
    """
    try:
        db_user = UserService.get_user_by_username(db, user.username)
        if not UserService.verify_password(user.password, db_user.password_hash):
            raise ValueError("Invalid password")
        return UserResponse.from_orm(db_user)
    except ValueError as e:
        raise HTTPException(status_code=401, detail=str(e))
    
@router.get("/users", response_model=list[UserResponse])
def get_all_users(db: Session = Depends(get_db)):
    """
    Lấy danh sách tất cả người dùng.

    Args:
        db: SQLAlchemy session.

    Returns:
        list[UserResponse]: Danh sách thông tin tất cả người dùng (id, username, role).
    """
    return UserService.get_all_users(db)

@router.put("/users/{username}/change-password",response_model=UserResponse)
def change_password(username: str, user: UserChangePassword, db: Session = Depends(get_db)):
    """
    Đổi mật khẩu cho người dùng.

    Args:
        username: Tên người dùng cần đổi mật khẩu.
        user: Schema chứa mật khẩu mới.
        db: SQLAlchemy session.

    Returns:
        UserResponse: Thông tin người dùng sau khi đổi mật khẩu (id, username, role).

    Raises:
        HTTPException: Nếu người dùng không tồn tại (status code 404).
    """
    try:
        return UserService.change_password(db, username, user.new_password)
    except ValueError as e:
        raise HTTPException(status_code=404, detail=str(e))
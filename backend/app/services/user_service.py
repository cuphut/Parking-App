from sqlalchemy.orm import Session
from app.models.user import User
from app.schemas.user import UserCreate, UserResponse
from passlib.context import CryptContext

# Khởi tạo context để băm mật khẩu
pwd_context = CryptContext(schemes=["bcrypt"], deprecated="auto")

class UserService:
    @staticmethod
    def create_user(db: Session, user: UserCreate) -> UserResponse:
        """
        Tạo một người dùng mới trong cơ sở dữ liệu.
        
        Args:
            db: SQLAlchemy session
            user: Pydantic schema chứa thông tin người dùng
            
        Returns:
            UserResponse: Schema chứa thông tin người dùng đã tạo
            
        Raises:
            ValueError: Nếu username đã tồn tại
        """
        if db.query(User).filter(User.username == user.username).first():
            raise ValueError("Username already exists")
            
        hashed_password = pwd_context.hash(user.password)
        
        db_user = User(
            username=user.username,
            password_hash=hashed_password,
            role=user.role
        )
        
        db.add(db_user)
        db.commit()
        db.refresh(db_user)
        
        return UserResponse.from_orm(db_user)

    @staticmethod
    def get_user_by_username(db: Session, username: str) -> UserResponse:
        """
        Lấy thông tin người dùng theo username.
        
        Args:
            db: SQLAlchemy session
            username: Tên người dùng cần tìm
            
        Returns:
            UserResponse: Schema chứa thông tin người dùng
            
        Raises:
            ValueError: Nếu người dùng không tồn tại
        """
        db_user = db.query(User).filter(User.username == username).first()
        if not db_user:
            raise ValueError("User not found")
        return db_user

    @staticmethod
    def verify_password(plain_password: str, hashed_password: str) -> bool:
        """
        Xác minh mật khẩu người dùng.
        
        Args:
            plain_password: Mật khẩu gốc
            hashed_password: Mật khẩu đã băm
            
        Returns:
            bool: True nếu mật khẩu khớp, False nếu không
        """
        return pwd_context.verify(plain_password, hashed_password)
    
    @staticmethod
    def get_all_users(db: Session) -> UserResponse:
        """
        Lấy thông tin người dùng theo username.
        
        Args:
            db: SQLAlchemy session
            username: Tên người dùng cần tìm
            
        Returns:
            UserResponse: Schema chứa thông tin người dùng
            
        Raises:
            ValueError: Nếu người dùng không tồn tại
        """
        users = db.query(User).all()
        return [UserResponse.from_orm(user) for user in users]
    
    @staticmethod
    def change_password(db: Session, username: str, new_password: str) -> UserResponse:
        """
        Đổi mật khẩu cho người dùng.
        
        Args:
            db: SQLAlchemy session
            username: Tên người dùng cần đổi mật khẩu
            new_password: Mật khẩu mới
            
        Returns:
            UserResponse: Thông tin người dùng sau khi đổi mật khẩu
            
        Raises:
            ValueError: Nếu người dùng không tồn tại
        """
        db_user = db.query(User).filter(User.username == username).first()
        if not db_user:
            raise ValueError("User not found")
            
        db_user.password_hash = pwd_context.hash(new_password)
        db.commit()
        db.refresh(db_user)
        
        return UserResponse.from_orm(db_user)
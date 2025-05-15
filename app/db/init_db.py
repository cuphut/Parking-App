from app.db.session import engine, Base
from app.models import user, registered_vehicle,parking_lot  # Import tất cả các model

def init_db():
    print("Creating database tables...")
    Base.metadata.create_all(bind=engine)
    print("Database tables created.")

# Chạy lệnh tạo database (chỉ chạy lần đầu)
if __name__ == "__main__":
    init_db()

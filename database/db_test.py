import database

database.delete_parking_from_db("30A33918")
result = database.view_all_parking()
print(result)

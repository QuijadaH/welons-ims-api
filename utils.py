from sqlalchemy import select, insert
from sqlalchemy.exc import SQLAlchemyError

def rows_to_dicts(rows):
    return [dict(row._mapping) for row in rows]

def get_or_create_lookup(conn, table, column_name, value):
    """
    Tries to find a lookup value in its table.
    If not found, inserts it and returns the new ID.
    Returns the ID of the lookup value either way.
    """
    if value is None:
        return None

    # 1️⃣ Try to find existing record
    existing_id = conn.execute(
        select(table.c.id).where(table.c[column_name] == value)
    ).scalar_one_or_none()

    if existing_id:
        return existing_id

    # 2️⃣ Insert if not found
    result = conn.execute(
        insert(table).values({column_name: value})
    )
    return result.inserted_primary_key[0]

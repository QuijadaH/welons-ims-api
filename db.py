from sqlalchemy import create_engine, MetaData
from dotenv import load_dotenv
import os

# Load environment variables from .env
load_dotenv()

# Get the database URL
DATABASE_URL = os.getenv("DATABASE_URL")

# Create an SQLAlchemy engine
# echo=True lets you see generated SQL statements (good for learning/debugging)
engine = create_engine(DATABASE_URL, echo=True)

# Metadata object holds info about reflected tables
metadata = MetaData()
metadata.reflect(bind=engine)
print(metadata.tables.keys())
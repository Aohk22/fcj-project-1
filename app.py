# query-service/app.py (với db_handler riêng)
from typing import Annotated
from fastapi import FastAPI, HTTPException, Query
from .db_handler import get_static_report_by_hash # Import từ db_handler

app = FastAPI()

@app.get('/')
async def query_static_report(file_hash: Annotated[str, Query(description="SHA256 hash of the file to query")]):
    """
    Truy vấn báo cáo phân tích tĩnh từ DynamoDB bằng SHA256 hash của file.
    """
    try:
        report = get_static_report_by_hash(file_hash)

        if report is None:
            raise HTTPException(status_code = 404, detail = f"No static report found for hash: {file_hash}")
        
        return report

    except Exception as e:
        raise HTTPException(status_code = 500, detail = f"Internal server error: {str(e)}")

# query-service/app.py (với db_handler riêng)
import boto3
from typing import Annotated
from fastapi import FastAPI, HTTPException, Query, Response
from db_handler import get_static_report_by_hash # Import từ db_handler

app = FastAPI()

@app.get('/query/')
async def query_static_report(file_hash: Annotated[str, Query(description="SHA256 hash of the file to query")], response: Response):
    """
    Truy vấn báo cáo phân tích tĩnh từ DynamoDB bằng SHA256 hash của file.
    """
    try:
        ddb = boto3.resource('dynamodb', region_name='ap-southeast-2')
        # ddb = boto3.resource('dynamodb', region_name='ap-southeast-2', endpoint_url='http://localhost:8000')
        report = get_static_report_by_hash(ddb, file_hash)

        if report is None:
            response.status_code = 404
            return HTTPException(status_code = 404, detail = f"No static report found for hash: {file_hash}")

        response.status_code = 200
        return report
    except Exception as e:
        response.status_code = 500
        return HTTPException(status_code = 500, detail = f"Internal server error: {str(e)}")

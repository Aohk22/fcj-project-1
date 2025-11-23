import boto3
from typing import Annotated
from fastapi import FastAPI, File, HTTPException, Response

from app.core.file_processor import analyzeFile
from app.types.main import *
from app.database.main import insertReport

app = FastAPI()

@app.post('/upload/')
async def file_upload(raw: Annotated[bytes, File()], response: Response):
    try:
        result = analyzeFile(raw)
    except:
        response.status_code = 199
        return HTTPException(status_code=199, detail='Could not analyze file')

    ddb = boto3.resource('dynamodb', region_name='ap-southeast-2')
    # ddb = boto3.resource('dynamodb', region_name='ap-southeast-2', endpoint_url='http://localhost:8000')
    if insertReport(ddb, result) != 200:
        response.status_code = 199
        return HTTPException(status_code=199, detail='Could not insert to database')

    response.status_code = 200
    return result.model_dump()

import boto3
from typing import Annotated
from fastapi import FastAPI, File, HTTPException

from app.core.file_processor import analyzeFile
from app.types.main import *
from app.database.main import insertReport

app = FastAPI()

@app.post('/upload/')
async def file_upload(raw: Annotated[bytes, File()]):
    try:
        result = analyzeFile(raw)
    except Exception as e:
        print(e)
        raise HTTPException(status_code=199, detail='Could not analyze file')

    # ddb = boto3.resource('dynamodb', region_name='ap-southeast-2')
    # if 'ConsumedCapacity' not in insertReport(ddb, result):
    #     raise HTTPException(status_code=199, detail='Could not insert to database')

    return result.model_dump()

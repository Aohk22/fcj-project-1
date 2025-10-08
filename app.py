import boto3
from typing import Annotated
from fastapi import FastAPI, File, HTTPException
from core.file_processor import analyze_file
from db_handler import insert_static_report
from pefile import PEFormatError

app = FastAPI()


@app.post('/get_static/')
async def file_upload(raw_data: Annotated[bytes, File()]):
    try:
        result = analyze_file(raw_data) 
        ddb = boto3.resource('dynamodb', region_name='ap-southeast-2')
        result = insert_static_report(ddb, result)
        if 'ConsumedCapacity' not in result:
            raise HTTPException(status_code=199, detail='Could not insert to database')
    except PEFormatError:
        raise HTTPException(status_code=404, detail='File is not in the right format.')
    return result.model_dump()

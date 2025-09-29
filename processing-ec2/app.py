from typing import Annotated
from fastapi import FastAPI, File, HTTPException
from core.file_processor import analyze_file

from pefile import PEFormatError

app = FastAPI()


@app.post('/api/get_static/')
async def file_upload(raw_data: Annotated[bytes, File()]):
    try:
        result = analyze_file(raw_data) 
    except PEFormatError:
        raise HTTPException(status_code=404, detail='File is not in the right format.')
    return result

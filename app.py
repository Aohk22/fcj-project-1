from typing import Annotated
from fastapi import FastAPI, File, HTTPException
from core.file_processor import analyze_file
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pathlib import Path
import sys
from pefile import PEFormatError

app = FastAPI()


@app.post('/api/get_static/')
async def file_upload(raw_data: Annotated[bytes, File()]):
    try:
        result = analyze_file(raw_data) 
    except PEFormatError:
        raise HTTPException(status_code=404, detail='File is not in the right format.')
    return result


def find_index_html() -> Path:
    base_path = Path(__file__).parent
    index_file = next(base_path.rglob("index.html"), None)
    if index_file is None:
        print("index.html not found!", file=sys.stderr)
        sys.exit(1)
    return index_file

index_path = find_index_html()
frontend_path = index_path.parent

app.mount("/static", StaticFiles(directory=frontend_path), name="static")

@app.get("/")
async def root():
    return FileResponse(index_path)

from typing import Annotated
from fastapi import FastAPI, File, HTTPException
from core.file_processor import analyze_file
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse
from pathlib import Path

from pefile import PEFormatError

app = FastAPI()


@app.post('/api/get_static/')
async def file_upload(raw_data: Annotated[bytes, File()]):
    try:
        result = analyze_file(raw_data) 
    except PEFormatError:
        raise HTTPException(status_code=404, detail='File is not in the right format.')
    return result



frontend_path = Path(__file__).parent
app.mount("/static", StaticFiles(directory=frontend_path), name="static")

@app.get("/")
async def serve_index():
    index_file = frontend_path / "index.html"
    if index_file.exists():
        return FileResponse(index_file)
    return {"error": "index.html not found"}

from typing import Annotated
from fastapi import FastAPI, File
from fastapi.staticfiles import StaticFiles
from fastapi.responses import FileResponse, JSONResponse

from core.file_processor import analyze_file
from pefile import PEFormatError

app = FastAPI(
    title="Static File Analyzer API",
    description="API for static analysis of binary files, primarily PE files."
)

from fastapi.middleware.cors import CORSMiddleware

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)

app.mount("/static", StaticFiles(directory="static"), name="static")


@app.get("/")
async def serve_index():
    """Serves the main frontend application HTML page from the static directory."""
    return FileResponse("static/index.html")


@app.post("/api/get_static/")
async def file_upload(raw_data: Annotated[bytes, File()]):
    """
    Receives a binary file and returns a static analysis report.
    Always returns JSON with either results or an error message.
    """
    if not raw_data:
        return JSONResponse(
            content={"error": "No file data provided."},
            status_code=400,
        )

    try:
        result = analyze_file(raw_data)
        return JSONResponse(content=result, status_code=200)

    except PEFormatError:
        return JSONResponse(
            content={"error": "The file uploaded is not a valid Portable Executable (PE) format."},
            status_code=422,
        )

    except Exception as e:
        print(f"Internal analysis error: {e}")
        return JSONResponse(
            content={"error": f"Internal server error: {type(e).__name__}"},
            status_code=500,
        )

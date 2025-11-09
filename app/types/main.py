from pydantic import BaseModel
from app.types.pe import *
from app.types.elf import *

# General file information.
class FileHashes(BaseModel):
    md5: str
    sha1: str
    sha256: str
    ssdeep: str

class FileType(BaseModel):
    magic: str
    trid: list[str]

# Encapsulating classes.
class FileGeneral(BaseModel):
    hashes: FileHashes
    fileType: FileType
    strings: list[str]
    decomp: str

class FilePE(BaseModel):
    general: FileGeneral
    meta: FilePEMeta
    peSections: list[FilePESection]

class FileELF(BaseModel):
    general: FileGeneral
    elfHeader: FileELFHeader
    symEntries: list[FileELFSymEntry]
    elfSegments: list[FileELFSegment] | FileELFSegment

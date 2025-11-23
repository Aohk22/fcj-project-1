from typing import Union
from pydantic import BaseModel
from utils.types_files.pe import *
from utils.types_files.elf import *

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
    isMalware: bool | None 


class FilePE(BaseModel):
    meta: FilePEMeta
    peSections: list[FilePESection]

class FileELF(BaseModel):
    elfHeader: FileELFHeader
    symEntries: list[FileELFSymEntry] | FileELFSymEntry
    elfSegments: list[FileELFSegment] | FileELFSegment

class FileAll(BaseModel):
    general: FileGeneral
    typed: Union[FilePE, FileELF]

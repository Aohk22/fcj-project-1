from pydantic import BaseModel

class FileELFHeader(BaseModel):
    magic: str
    elfClass: str
    elfData: str
    elfType: str
    machine: str

class FileELFSymEntry(BaseModel):
    value: int
    size: int
    type: str
    vis: str
    name: str

# class FileELFSegment(BaseModel):
#     offset: int
#     addrVirt: int
#     addrPhys: int
#     sizeFile: int
#     sizeMem: int
#     flags: str

class FileELFSegment(BaseModel):
    content: str

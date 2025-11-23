from pydantic import BaseModel

class FileELFHeader(BaseModel):
    magic: str
    elfClass: str
    elfData: str
    elfType: str
    machine: str

class FileELFSymEntry(BaseModel):
    value: str
    size: str
    type: str
    vis: str
    name: str

# class FileELFSymEntry(BaseModel):
#     content: str

# class FileELFSegment(BaseModel):
#     offset: int
#     addrVirt: int
#     addrPhys: int
#     sizeFile: int
#     sizeMem: int
#     flags: str

class FileELFSegment(BaseModel):
    content: str

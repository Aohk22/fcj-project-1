from pydantic import BaseModel

class FilePEMeta(BaseModel):
    size: int
    arch: str
    date: str
    crcClaim: int | str
    crcReal: int

class FilePESection(BaseModel):
    name: str
    addrVirt: int
    sizeVirt: int
    sizePhys: int
    md5: str
    entropy: float
    suspicious: bool

from pydantic import BaseModel

class SectionHash(BaseModel):
    md5: str
    sha1: str
    sha256: str
    ssdeep: str

class SectionFileType(BaseModel):
    python_magic: str
    trid: list[str]

class SectionMeta(BaseModel):
    size: int
    architecture: str
    date: str
    crc_claim: int | str
    crc_calcd: int

class SectionPESection(BaseModel):
    name: str
    virt_addr: int
    virt_size: int
    phys_size: int
    md5: str
    entropy: float
    suspicious: bool

class StaticReport(BaseModel):
    hashes: SectionHash
    file_type: SectionFileType
    meta: SectionMeta
    pe_sections: list[SectionPESection]

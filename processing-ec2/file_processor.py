#!/usr/bin/env python3

import hashlib
import pefile
from pydantic import BaseModel
from utils import *

# custom
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

# for disabling editor error
# (doesn't work)
# class Structure(pefile.Structure):
#     Machine: str = ''
#     TimeDateStamp: str = ''
#     CheckSum: str = ''


def get_pe_section_info(section) -> SectionPESection:
    entr = section.get_entropy()
    pe_section = SectionPESection(
        name = section.Name.rstrip(b'\x00'),
        virt_addr = section.VirtualAddress,
        virt_size = section.Misc_VirtualSize,
        phys_size = section.SizeOfRawData,
        md5 = section.get_hash_md5(),
        entropy = entr,
        suspicious = True if (entr>7 or entr<3) else False,
    )
    return pe_section


def analyze_file(raw_data: bytes) -> dict:

    pe = pefile.PE(data=raw_data)

    hashes = SectionHash(
        md5 = hashlib.md5(raw_data).hexdigest(),
        sha1 = hashlib.sha1(raw_data).hexdigest(),
        sha256 = hashlib.sha256(raw_data).hexdigest(),
        ssdeep = ssdeep(raw_data),
    )

    file_type = SectionFileType(
        python_magic = from_magic(raw_data),
        trid = trid(raw_data),
    )

    meta = SectionMeta(
        size = len(raw_data),
        architecture = get_arch(pe.FILE_HEADER.Machine),
        date = get_timestamp(pe.FILE_HEADER.TimeDateStamp),
        crc_claim = pe.OPTIONAL_HEADER.CheckSum,
        crc_calcd = pe.generate_checksum(),
    )

    static_report = StaticReport(
        hashes = hashes,
        file_type = file_type,
        meta = meta,
        pe_sections = [get_pe_section_info(section) for section in pe.sections],
    )

    return static_report.model_dump()

if __name__ == '__main__':
    from pprint import pprint
    import sys
    fp = sys.argv[1]
    result = analyze_file(open(fp, 'rb').read())
    pprint(result)

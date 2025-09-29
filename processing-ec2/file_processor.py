#!/usr/bin/env python3

import hashlib
import pefile
from utils import *
from section_types import *


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

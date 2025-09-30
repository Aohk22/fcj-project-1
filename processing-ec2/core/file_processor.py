import hashlib
import pefile
import custom_types.types as ctypes
from helper import utils


def get_pe_section_info(section) -> ctypes.SectionPESection:
    entr = section.get_entropy()
    return ctypes.SectionPESection(
        name=section.Name.rstrip(b"\x00"),
        virt_addr=section.VirtualAddress,
        virt_size=section.Misc_VirtualSize,
        phys_size=section.SizeOfRawData,
        md5=section.get_hash_md5(),
        entropy=entr,
        suspicious=(entr > 7 or entr < 3),
    )


def analyze_file(raw_data: bytes) -> dict:
    pe = pefile.PE(data=raw_data)

    hashes = ctypes.SectionHash(
        md5=hashlib.md5(raw_data).hexdigest(),
        sha1=hashlib.sha1(raw_data).hexdigest(),
        sha256=hashlib.sha256(raw_data).hexdigest(),
        ssdeep=utils.ssdeep_hash(raw_data),
    )

    file_type = ctypes.SectionFileType(
        python_magic=utils.from_magic(raw_data),
        trid=utils.trid(raw_data),
    )

    meta = ctypes.SectionMeta(
        size=len(raw_data),
        architecture=utils.get_arch(pe.FILE_HEADER.Machine),
        date=utils.get_timestamp(pe.FILE_HEADER.TimeDateStamp),
        crc_claim=getattr(pe.OPTIONAL_HEADER, "CheckSum", "N/A"),
        crc_calcd=pe.generate_checksum(),
    )

    static_report = ctypes.StaticReport(
        hashes=hashes,
        file_type=file_type,
        meta=meta,
        pe_sections=[get_pe_section_info(section) for section in pe.sections],
    )

    return static_report.model_dump()

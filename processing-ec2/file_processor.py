#!/usr/bin/env python3

import hashlib
import subprocess as sp
import pefile
import magic
import time
from trid import tridAnalyze, trdpkg2defs

PATH_TRIDDEF = './triddefs.trd'
TRID_RESULT_CAP = 4


def ssdeep(raw_data: bytes) -> str:
    output = sp.run(['./ssdeep'], input=raw_data, capture_output=True).stdout
    hash_result = output.split(b'\n')[1].split(b',')[0]
    return hash_result.decode()


def from_magic(raw_data: bytes) -> str:
    result = magic.from_buffer(raw_data)
    return result


def trid(raw_data: bytes) -> list[str]:
    results_strs = list()
    triddefs = trdpkg2defs(PATH_TRIDDEF, usecache=True)
    results = tridAnalyze(raw_data, triddefs, stringcheck=True)
    if results:
        for res in results[:min(len(results), TRID_RESULT_CAP)]:
            results_strs.append(("%5.1f%% (.%s) %s (%i/%i/%i)" % (
                res.perc, res.triddef.ext,
                res.triddef.filetype,
                res.pts, res.patt, res.str)))
    return results_strs


def get_arch(arch_num: int) -> str:
    if arch_num == 0x14c:
        return '32 bits'
    elif arch_num == 8664:
        return '64 bits'
    else:
        return 'unknown'


def get_timestamp(ts_nu: int) -> str:
    ts = '0x%-8X' % (ts_nu)
    try:
        ts += ' [%s UTC]' % time.asctime(time.gmtime(ts_nu))
        that_year = time.gmtime(ts_nu)[0]
        this_year = time.gmtime(time.time())[0]
        if that_year < 2000 or that_year > this_year:
            ts += ' [SUSPICIOUS]'
    except:
        ts += ' [SUSPICIOUS]'
    return ts


def analyze_file(raw_data: bytes) -> dict:
    hashes = dict()
    file_type = dict()
    meta = dict()
    sections = dict()
    malware_profile = dict()

    pe = pefile.PE(data=raw_data)

    hashes['md5'] = hashlib.md5(raw_data).hexdigest()
    hashes['sha1'] = hashlib.sha1(raw_data).hexdigest()
    hashes['sha256'] = hashlib.sha256(raw_data).hexdigest()
    hashes['ssdeep'] = ssdeep(raw_data)

    file_type['python-magic'] = from_magic(raw_data)
    file_type['trid'] = trid(raw_data)

    meta['size'] = len(raw_data)
    meta['architecture'] = get_arch(pe.FILE_HEADER.Machine)
    meta['date'] = get_timestamp(pe.FILE_HEADER.TimeDateStamp)
    meta['crc_claimed'] = pe.OPTIONAL_HEADER.CheckSum
    meta['crc_calculated'] = pe.generate_checksum()

    for section in pe.sections:
        entr = section.get_entropy()
        section_name = section.Name.rstrip(b'\x00')
        sections[section_name] = {
            'virt_addr': section.VirtualAddress,
            'virt_size': section.Misc_VirtualSize,
            'phys_size': section.SizeOfRawData,
            'md5': section.get_hash_md5(),
        }
        if entr > 7 or entr < 3:
            sections[section_name]['entropy'] = str(entr) + ' [SUSPICIOUS]' 
        else:
            sections[section_name]['entropy'] = str(entr)

    malware_profile['hashes'] = hashes
    malware_profile['file_type'] = file_type
    malware_profile['meta'] = meta
    malware_profile['sections'] = sections

    return malware_profile

if __name__ == '__main__':
    from pprint import pprint
    import sys
    fp = sys.argv[1]
    result = analyze_file(open(fp, 'rb').read())
    pprint(result)

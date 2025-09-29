import subprocess as sp
import magic
import time
from trid.trid import tridAnalyze, trdpkg2defs


PATH_TRIDDEF = './triddefs.trd'
TRID_RESULT_CAP = 4


def ssdeep(raw_data: bytes) -> str:
    output = sp.run(['ssdeep'], input=raw_data, capture_output=True).stdout
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

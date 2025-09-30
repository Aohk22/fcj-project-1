import subprocess as sp
import time

try:
    import magic
except ImportError:
    magic = None

try:
    import ssdeep  
except ImportError:
    ssdeep = None

from trid.trid import tridAnalyze, trdpkg2defs


PATH_TRIDDEF = "./triddefs.trd"
TRID_RESULT_CAP = 4


def ssdeep_hash(raw_data: bytes) -> str:
    if not ssdeep:
        return "ssdeep not available"
    try:
        return ssdeep.hash(raw_data)
    except Exception as e:
        return f"ssdeep error: {type(e).__name__}"


def from_magic(raw_data: bytes) -> str:
    if not magic:
        return "libmagic not available"
    try:
        return magic.from_buffer(raw_data)
    except Exception as e:
        return f"magic error: {type(e).__name__}"


def trid(raw_data: bytes) -> list[str]:
    results_strs = []
    try:
        triddefs = trdpkg2defs(PATH_TRIDDEF, usecache=True)
        results = tridAnalyze(raw_data, triddefs, stringcheck=True)
        if results:
            for res in results[:min(len(results), TRID_RESULT_CAP)]:
                results_strs.append(
                    f"{res.perc:5.1f}% (.{res.triddef.ext}) {res.triddef.filetype} ({res.pts}/{res.patt}/{res.str})"
                )
    except Exception as e:
        results_strs.append(f"TrID error: {type(e).__name__}")
    return results_strs


def get_arch(arch_num: int) -> str:
    if arch_num == 0x14C:
        return "32 bits"
    elif arch_num == 0x8664:
        return "64 bits"
    else:
        return "unknown"


def get_timestamp(ts_nu: int) -> str:
    ts = f"0x{ts_nu:08X}"
    try:
        ts += f" [{time.asctime(time.gmtime(ts_nu))} UTC]"
        that_year = time.gmtime(ts_nu)[0]
        this_year = time.gmtime(time.time())[0]
        if that_year < 2000 or that_year > this_year:
            ts += " [SUSPICIOUS]"
    except Exception:
        ts += " [SUSPICIOUS]"
    return ts

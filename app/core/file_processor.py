import os
import re
import sys
import hashlib
import pefile
import subprocess as sp
import magic
import time
import tempfile

from app.types.main import *
from app.trid.trid import tridAnalyze, trdpkg2defs

MAGIC_PE = b'\x4d\x5a'
MAGIC_ELF = b'\x7F\x45\x4C\x46'

DIR_BASE = os.path.dirname(__file__)
TRIDDEF_PATH = os.path.join(DIR_BASE, 'triddefs.trd')
TRID_RESULT_CAP = 4

TEMP_BIN_PATH = os.makedirs('/tmp/bin/', exist_ok=True)
TEMP_BIN_FILE = os.path.join('/tmp/bin/', 'temp.exe')

GHIDRA_INSTALL = os.path.normpath('/opt/ghidra_11.4.2_PUBLIC')
GHIDRA_HEADLESS = os.path.join(GHIDRA_INSTALL, 'support', 'analyzeHeadless')
GHIDRA_APP_PROPERTIES = os.path.join(GHIDRA_INSTALL, 'Ghidra', 'application.properties')

MALWARE_HASH_DB_PATH = os.path.join(DIR_BASE, 'sha256_malware_1.txt')
MALWARE_HASHES = set()

# Load malware hashes once when the module is loaded
def _loadMalwareHashes():
    global MALWARE_HASHES
    if not MALWARE_HASHES: 
        try:
            with open(MALWARE_HASH_DB_PATH, 'r') as f:
                for line in f:
                    hash_value = line.strip()
                    if hash_value:
                        MALWARE_HASHES.add(hash_value)
            print(f"Loaded {len(MALWARE_HASHES)} malware hashes from {MALWARE_HASH_DB_PATH}")
        except FileNotFoundError:
            print(f"Malware hash database not found at {MALWARE_HASH_DB_PATH}. Malware detection will be skipped.")
        except Exception as e:
            print(f"Error loading malware hashes: {e}")

_loadMalwareHashes() 

def _checkMalwareBySha256(sha256_hash: str) -> bool:
    return sha256_hash in MALWARE_HASHES

# File helpers.
def _getHashSsdeep(raw: bytes) -> str:
    output = sp.run(['ssdeep'], input=raw, capture_output=True).stdout
    result = output.split(b'\n')[1].split(b',')[0]
    return result.decode()

def _getFileTypeTrid(raw_data: bytes) -> list[str]:
    results_strs = list()
    triddefs = trdpkg2defs(TRIDDEF_PATH, usecache=False)
    results = tridAnalyze(raw_data, triddefs, stringcheck=True)
    if results:
        for res in results[:min(len(results), TRID_RESULT_CAP)]:
            results_strs.append(("%5.1f%% (.%s) %s (%i/%i/%i)" % (
                res.perc, res.triddef.ext,
                res.triddef.filetype,
                res.pts, res.patt, res.str)))
    return results_strs

def _getStrings() -> list[str]:
    strings = sp.run(['strings', TEMP_BIN_FILE], capture_output=True, text=True).stdout
    strings = strings.split('\n')
    return strings

# PE helpers.
def _getPESections(section) -> FilePESection:
    entr = section.get_entropy()
    pe_section = FilePESection(
        name = section.Name.rstrip(b'\x00'),
        addrVirt = section.VirtualAddress,
        sizeVirt = section.Misc_VirtualSize,
        sizePhys = section.SizeOfRawData,
        md5 = section.get_hash_md5(),
        entropy = entr,
        suspicious = True if (entr>7 or entr<3) else False,
    )
    return pe_section

def _getPEMetaArch(arch_num: int) -> str:
    if arch_num == 0x14c:
        return '32 bits'
    elif arch_num == 8664:
        return '64 bits'
    else:
        return '(unknown)'

def _getPEMetaTimestamp(ts_nu: int) -> str:
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

# ELF helpers.
def _getELFHeader() -> FileELFHeader:
    head = sp.run(['readelf', '-h', TEMP_BIN_FILE], capture_output=True, text=True).stdout
    head = head.split('\n')[1:]
    def __getField(row: str):
        return row.split(':')[1].strip()
    return FileELFHeader(
        magic = __getField(head[0]),
        elfClass = __getField(head[1]),
        elfData = __getField(head[2]),
        elfType = __getField(head[3]),
        machine = __getField(head[7])
    )

# def _getELFSymEntries() -> list[FileELFSymEntry]:
def _getELFSymEntries() -> FileELFSymEntry | list[FileELFSymEntry]:
    sym = sp.run(['readelf', '-s', TEMP_BIN_FILE], capture_output=True, text=True).stdout

    # return FileELFSymEntry(content=sym)

    result: list[FileELFSymEntry] = list()
    sym = sym.split('\n')[3:]

    for i in range(len(sym)):
        fields = re.split(r'\s+', sym[i])[2:]
        if fields:
            result.append(FileELFSymEntry(
                value = fields[0],
                size = fields[1],
                type = fields[2],
                vis = fields[4],
                name = fields[6],
            ))
    return result

# Place holder.
def _getELFSegments() -> FileELFSegment:
    segment = sp.run(['readelf', '-l', TEMP_BIN_FILE], capture_output=True, text=True).stdout
    return FileELFSegment(content=segment)

# Decompilation
def _getDecompilation(conts: bytes) -> str:
    return "test"
    with tempfile.TemporaryDirectory() as tempdir:
        infile = tempfile.NamedTemporaryFile(dir=tempdir, delete=False)
        infile.write(conts)
        infile.flush()
        inname = infile.name
        infile.close()

        project_dir = tempfile.TemporaryDirectory(dir=tempdir)
        output_dir = tempfile.TemporaryDirectory(dir=tempdir)

        output_file = output_dir.name + "/out"
        parent_dir = DIR_BASE

        decompile_command = [
            f"{GHIDRA_HEADLESS}",
            project_dir.name,
            "temp",
            "-import",
            inname,
            "-scriptPath",
            f"{parent_dir}",
            "-postScript",
            f"{parent_dir}/DecompilerExplorer.java",
            output_file
        ]

        env = os.environ.copy()
        env['PATH'] = f"{parent_dir}/jdk/bin:{env['PATH']}"

        if not os.path.exists(output_file):
            decomp = sp.run(decompile_command, capture_output=True, env=env)
            if decomp.returncode != 0 or not os.path.exists(output_file):
                print(f'{decomp.stdout.decode()}\n{decomp.stderr.decode()}')
                sys.exit(1)

        with open(output_file, 'r') as f:
            return f.read()

# Main.
def analyzeFile(raw: bytes) -> FileAll:
    open(TEMP_BIN_FILE, 'wb').write(raw)
    result: FileAll | None = None

    sha256_hash = hashlib.sha256(raw).hexdigest()
    is_malware = _checkMalwareBySha256(sha256_hash)

    general = FileGeneral(
        hashes = FileHashes(
            md5 = hashlib.md5(raw).hexdigest(),
            sha1 = hashlib.sha1(raw).hexdigest(),
            sha256 = sha256_hash, 
            ssdeep = _getHashSsdeep(raw)
        ),
        fileType = FileType(
            magic = magic.from_buffer(raw),
            trid = _getFileTypeTrid(raw)
        ),
        strings = _getStrings(),
        decomp = _getDecompilation(raw),
        isMalware = is_malware 
    )

    if MAGIC_ELF in raw[:4]:
        fELF = FileELF(
            elfHeader = _getELFHeader(),
            symEntries = _getELFSymEntries(),
            elfSegments = _getELFSegments(),
        )
        result = FileAll(
            general = general,
            typed = fELF
        )

    elif MAGIC_PE in raw[:2]:
        pe = pefile.PE(data=raw)

        meta = FilePEMeta(
            size = len(raw),
            arch = _getPEMetaArch(pe.FILE_HEADER.Machine),
            date = _getPEMetaTimestamp(pe.FILE_HEADER.TimeDateStamp),
            crcClaim = pe.OPTIONAL_HEADER.CheckSum,
            crcReal = pe.generate_checksum(),
        )

        fPE = FilePE(
            meta = meta,
            peSections = [_getPESections(section) for section in pe.sections],
        )

        result = FileAll(
            general = general,
            typed = fPE
        )
    else:
        raise Exception('File type not supported yet.')

    os.remove(TEMP_BIN_FILE)
    return result


if __name__ == '__main__':
    import sys
    fn = sys.argv[1]
    data = b''
    with open(fn, 'rb') as f:
        data = f.read()
    analyzeFile(data)
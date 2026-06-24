import struct, sys, collections

PATH = r"C:\Modding\Starfield\OSF Seduce\OSFSeduce.esp"
data = open(PATH, "rb").read()
print("file size:", len(data))

def read_rec_header(off):
    typ = data[off:off+4].decode('latin1')
    dataSize, flags, formID, ts, formVer, unk = struct.unpack_from('<IIIIHH', data, off+4)
    return typ, dataSize, flags, formID, formVer

def read_grup_header(off):
    # GRUP: type[4], groupSize[4] (includes 24 header), label[4], groupType[4], ts[2], unk[2], formVer[2], unk[2]
    typ = data[off:off+4].decode('latin1')
    groupSize, = struct.unpack_from('<I', data, off+4)
    label = data[off+8:off+12]
    groupType, = struct.unpack_from('<i', data, off+12)
    return typ, groupSize, label, groupType

def iter_subrecords(rec_data):
    """Yield (type, payload) from a record's data block. Handles XXXX big-size."""
    off = 0
    big = None
    while off + 6 <= len(rec_data):
        styp = rec_data[off:off+4].decode('latin1')
        ssize, = struct.unpack_from('<H', rec_data, off+4)
        off += 6
        if styp == 'XXXX':
            big, = struct.unpack_from('<I', rec_data, off)
            off += ssize
            continue
        if big is not None:
            ssize = big
            big = None
        payload = rec_data[off:off+ssize]
        off += ssize
        yield styp, payload

# ---- TES4 header ----
assert data[0:4] == b'TES4', data[0:4]
typ, dsz, flags, formID, formVer = read_rec_header(0)
print("\n=== TES4 header ===")
print("record flags: 0x%08X" % flags)
print("  ESM flag (0x1):", bool(flags & 0x1))
print("  ESL/light flag (0x200):", bool(flags & 0x200))
print("form version:", formVer)
hdr_data = data[24:24+dsz]
masters = []
for styp, payload in iter_subrecords(hdr_data):
    if styp == 'HEDR':
        ver, numrec, nextobj = struct.unpack_from('<fII', payload, 0)
        print("HEDR version: %.3f  numRecords: %d  nextObjectID: 0x%X" % (ver, numrec, nextobj))
    elif styp == 'MAST':
        masters.append(payload.split(b'\x00')[0].decode('latin1'))
    elif styp == 'CNAM':
        print("author (CNAM):", payload.split(b'\x00')[0].decode('latin1', 'replace'))
    elif styp == 'SNAM':
        print("desc (SNAM):", payload.split(b'\x00')[0].decode('latin1', 'replace'))
print("MASTERS (%d):" % len(masters))
for m in masters:
    print("   -", m)

# ---- walk top-level groups ----
print("\n=== top-level GRUP census ===")
off = 24 + dsz
census = collections.Counter()
top_groups = []
while off < len(data):
    if data[off:off+4] == b'GRUP':
        gtyp, gsize, label, gtype = read_grup_header(off)
        # label for top-level = record type signature
        sig = label.decode('latin1')
        top_groups.append((sig, off, gsize, gtype))
        off += gsize
    else:
        typ, dsz2, fl, fid, fv = read_rec_header(off)
        census[typ] += 1
        off += 24 + dsz2

for sig, o, gsz, gt in top_groups:
    print("  GRUP %r  type=%d  size=%d  @0x%X" % (sig, gt, gsz, o))

# ---- recursively census all records ----
print("\n=== full record census ===")
def walk(off, end):
    while off < end:
        sig4 = data[off:off+4]
        if sig4 == b'GRUP':
            gtyp, gsize, label, gtype = read_grup_header(off)
            walk(off+24, off+gsize)
            off += gsize
        else:
            typ, dsz2, fl, fid, fv = read_rec_header(off)
            census[typ] += 1
            off += 24 + dsz2
census.clear()
walk(24+dsz, len(data))
for t, c in sorted(census.items(), key=lambda x:-x[1]):
    print("  %-6s %d" % (t, c))

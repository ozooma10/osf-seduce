import struct, collections

PATH = r"C:\Modding\Starfield\OSF Seduce\OSFSeduce.esp"
data = open(PATH, "rb").read()

def read_rec_header(off):
    typ = data[off:off+4].decode('latin1')
    dataSize, flags, formID, ts, formVer, unk = struct.unpack_from('<IIIIHH', data, off+4)
    return typ, dataSize, flags, formID, formVer

def read_grup_header(off):
    typ = data[off:off+4].decode('latin1')
    groupSize, = struct.unpack_from('<I', data, off+4)
    label = data[off+8:off+12]
    groupType, = struct.unpack_from('<i', data, off+12)
    return typ, groupSize, label, groupType

def iter_subrecords(rec_data):
    off = 0; big=None
    while off + 6 <= len(rec_data):
        styp = rec_data[off:off+4].decode('latin1')
        ssize, = struct.unpack_from('<H', rec_data, off+4)
        off += 6
        if styp == 'XXXX':
            big, = struct.unpack_from('<I', rec_data, off); off += ssize; continue
        if big is not None:
            ssize = big; big=None
        yield styp, rec_data[off:off+ssize]
        off += ssize

records = []  # (typ, formID, formVer, data, parent_grup_label, grouptype)
def walk(off, end, parent=None, gt=None):
    while off < end:
        if data[off:off+4] == b'GRUP':
            _, gsize, label, gtype = read_grup_header(off)
            walk(off+24, off+gsize, label, gtype)
            off += gsize
        else:
            typ, dsz, fl, fid, fv = read_rec_header(off)
            rd = data[off+24:off+24+dsz]
            records.append((typ, fid, fv, rd, parent, gt))
            off += 24 + dsz

typ0, dsz0, *_ = read_rec_header(0)
walk(24+dsz0, len(data))

def cstr(b):
    return b.split(b'\x00')[0].decode('latin1','replace')

# ---- QUSTs ----
print("=== QUST records ===")
qust_by_fid = {}
for typ, fid, fv, rd, parent, gt in records:
    if typ != 'QUST': continue
    edid=None; dnam=None; full=None; vmad=False; scripts=[]
    for styp, p in iter_subrecords(rd):
        if styp=='EDID': edid=cstr(p)
        elif styp=='FULL': full=cstr(p)
        elif styp=='DNAM': dnam=p
        elif styp=='VMAD':
            vmad=True
            # parse VMAD script names (best effort)
            try:
                ver, objf, sccount = struct.unpack_from('<hhH', p, 0)
                o=6
                for _ in range(scount):
                    nlen,=struct.unpack_from('<H',p,o); o+=2
                    sname=p[o:o+nlen].decode('latin1','replace'); o+=nlen
                    scripts.append(sname)
                    # skip status(1)+propcount(2) then bail (props vary)
                    break
            except Exception as e:
                scripts.append("<parse-err:%s>"%e)
    qust_by_fid[fid]=edid
    print("\nQUST 0x%08X  EDID=%r  FULL=%r" % (fid, edid, full))
    if dnam is not None and len(dnam)>=4:
        flags, = struct.unpack_from('<H', dnam, 0)
        print("   DNAM flags=0x%04X  StartGameEnabled(0x01)=%s  RunOnce(0x04)=%s  wildcard(0x80?)=%s"
              % (flags, bool(flags&0x01), bool(flags&0x04), bool(flags&0x80)))
        print("   DNAM raw:", dnam.hex())
    else:
        print("   (no DNAM / short)")
    print("   has VMAD script:", vmad, scripts)

# ---- DIAL census: count INFOs per DIAL, and conditions on INFO ----
print("\n=== INFO fragment script name check (sample) ===")
# Each INFO has VMAD whose fragment script name should match a TIF_*.pex
info_scripts = []
for typ, fid, fv, rd, parent, gt in records:
    if typ != 'INFO': continue
    for styp, p in iter_subrecords(rd):
        if styp=='VMAD':
            # try to find readable TIF_ name
            idx = p.find(b'TIF_')
            if idx>=0:
                end=idx
                while end<len(p) and 32<=p[end]<127: end+=1
                info_scripts.append((fid, p[idx:end].decode('latin1','replace')))
            break
print("INFOs with TIF fragment ref: %d / 120" % len(info_scripts))
for fid, name in info_scripts[:25]:
    print("   INFO 0x%08X -> %s" % (fid, name))

# ---- DIAL records: subtype / player-dialogue flag ----
print("\n=== DIAL summary ===")
dial_count=0; dial_with_full=0
for typ, fid, fv, rd, parent, gt in records:
    if typ!='DIAL': continue
    dial_count+=1
    for styp,p in iter_subrecords(rd):
        if styp=='FULL': dial_with_full+=1
print("DIAL total: %d, with FULL (prompt text): %d" % (dial_count, dial_with_full))

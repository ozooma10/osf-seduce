import struct, collections
PATH = r"C:\Users\NICKLEBACK\Downloads\SAF_Seduce_1_3_espversion (1)\SAF_Seduce_1_3_espversion\Data\NAFSeduce.esp"
data = open(PATH, "rb").read()
print("file size:", len(data))
def rh(off):
    typ=data[off:off+4].decode('latin1'); ds,fl,fid,ts,fv,unk=struct.unpack_from('<IIIIHH',data,off+4); return typ,ds,fl,fid,fv
def gh(off):
    typ=data[off:off+4].decode('latin1'); gs,=struct.unpack_from('<I',data,off+4); lbl=data[off+8:off+12]; gt,=struct.unpack_from('<i',data,off+12); return typ,gs,lbl,gt
def subs(rd):
    off=0; big=None
    while off+6<=len(rd):
        st=rd[off:off+4].decode('latin1'); sz,=struct.unpack_from('<H',rd,off+4); off+=6
        if st=='XXXX': big,=struct.unpack_from('<I',rd,off); off+=sz; continue
        if big is not None: sz=big; big=None
        yield st, rd[off:off+sz]; off+=sz
def cstr(b): return b.split(b'\x00')[0].decode('latin1','replace')
def ascii_runs(rd, minlen=4):
    runs=[]; cur=b''
    for b in rd:
        if 32<=b<127: cur+=bytes([b])
        else:
            if len(cur)>=minlen: runs.append(cur.decode('latin1'))
            cur=b''
    if len(cur)>=minlen: runs.append(cur.decode('latin1'))
    return runs

flat=[]
def walk(off,end,pd=None):
    while off<end:
        if data[off:off+4]==b'GRUP':
            _,gs,lbl,gt=gh(off); npd=pd
            if gt==7: npd,=struct.unpack_from('<I',lbl,0)
            walk(off+24,off+gs,npd); off+=gs
        else:
            typ,ds,fl,fid,fv=rh(off); flat.append((typ,fid,data[off+24:off+24+ds],pd)); off+=24+ds
# TES4 header
assert data[0:4]==b'TES4'
t0,d0,fl0,fid0,fv0=rh(0)
masters=[];
for st,p in subs(data[24:24+d0]):
    if st=='MAST': masters.append(cstr(p))
print("ESM flag:", bool(fl0&0x1), " masters:", masters)
walk(24+d0,len(data))

census=collections.Counter(t for t,_,_,_ in flat)
print("\ncensus:", dict(census))

# ALCH (the pheromone) + MGEF + PERK + SPEL + scripts
for want in ('ALCH','MGEF','PERK','SPEL','WEAP'):
    for typ,fid,rd,pd in flat:
        if typ!=want: continue
        edid=None
        for st,p in subs(rd):
            if st=='EDID': edid=cstr(p)
        runs=[r for r in ascii_runs(rd) if not r.startswith('OSF/')]
        print("\n%s 0x%08X edid=%r" % (typ,fid,edid))
        print("   fields:", dict(collections.Counter(st for st,_ in subs(rd))))
        print("   ascii:", runs[:18])

# QUST: aliases + alias fill + scripts
print("\n=== QUSTs (aliases/fill/scripts) ===")
for typ,fid,rd,pd in flat:
    if typ!='QUST': continue
    edid=None
    flds=collections.Counter(st for st,_ in subs(rd))
    for st,p in subs(rd):
        if st=='EDID': edid=cstr(p)
    runs=[r for r in ascii_runs(rd) if not r.startswith('OSF/') and ('Script' in r or 'Alias' in r or 'Scene' in r or 'Quest' in r or 'Seduce' in r)]
    print("  QUST 0x%08X %r flds=%s" % (fid,edid,dict(flds)))
    print("     ascii:", runs[:20])

# SCEN: how started? print quest + actions ascii
print("\n=== SCEN ===")
for typ,fid,rd,pd in flat:
    if typ!='SCEN': continue
    edid=None; quest=None
    for st,p in subs(rd):
        if st=='EDID': edid=cstr(p)
        elif st=='PNAM' and len(p)>=4: quest,=struct.unpack_from('<I',p,0)
    print("  SCEN 0x%08X %r quest=0x%08X" % (fid,edid,quest or 0))

# PACK (packages - force greet?) and any FormID referencing dialogue
print("\n=== PACK / DLBR / refs of interest ===")
print("PACK count:", census.get('PACK',0), "DLBR:", census.get('DLBR',0), "DIAL:", census.get('DIAL',0), "INFO:", census.get('INFO',0))

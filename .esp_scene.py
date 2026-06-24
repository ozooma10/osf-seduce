import struct, collections
PATH = r"C:\Modding\Starfield\OSF Seduce\OSFSeduce.esp"
data = open(PATH, "rb").read()
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
flat=[]
def walk(off,end,pd=None):
    while off<end:
        if data[off:off+4]==b'GRUP':
            _,gs,lbl,gt=gh(off); npd=pd
            if gt==7: npd,=struct.unpack_from('<I',lbl,0)
            walk(off+24,off+gs,npd); off+=gs
        else:
            typ,ds,fl,fid,fv=rh(off); flat.append((typ,fid,data[off+24:off+24+ds],pd)); off+=24+ds
t0,d0,*_=rh(0); walk(24+d0,len(data))

# DIAL subtype + category histogram (DATA: subtype category, etc.)
dial={}
for typ,fid,rd,pd in flat:
    if typ!='DIAL': continue
    sub=None; full=None; edid=None
    for st,p in subs(rd):
        if st=='SNAM': sub=cstr(p)
        elif st=='FULL': full=cstr(p)
        elif st=='EDID': edid=cstr(p)
    dial[fid]={'sub':sub,'full':full,'edid':edid}
print("=== DIAL subtype histogram (all 120) ===")
for k,v in collections.Counter(d['sub'] for d in dial.values()).most_common():
    print("   %r : %d" % (k,v))

# INFO: list any with RNAM (player prompt) -> these are selectable choices
print("\n=== INFOs with RNAM prompt (player-selectable text) ===")
cnt=0
for typ,fid,rd,pd in flat:
    if typ!='INFO': continue
    rnam=None
    for st,p in subs(rd):
        if st=='RNAM': rnam=cstr(p)
    if rnam:
        cnt+=1
        print("   INFO 0x%08X prompt=%r (DIAL sub=%r)" % (fid, rnam, dial.get(pd,{}).get('sub')))
print("TOTAL INFOs with a player prompt (RNAM):", cnt)

# All 19 fragment INFO subtypes
print("\n=== subtype of the 19 fragment INFOs' parent DIALs ===")
subc=collections.Counter()
for typ,fid,rd,pd in flat:
    if typ!='INFO': continue
    isf=any(st=='VMAD' and b'TIF_' in p for st,p in subs(rd))
    if isf: subc[dial.get(pd,{}).get('sub')]+=1
print("  ", dict(subc))

# SCEN records: phases, actors, start conditions
print("\n=== SCEN records ===")
for typ,fid,rd,pd in flat:
    if typ!='SCEN': continue
    edid=None; quest=None; phases=0; actions=0; flags=None
    fields=collections.Counter()
    for st,p in subs(rd):
        fields[st]+=1
        if st=='EDID': edid=cstr(p)
        elif st=='PNAM' and len(p)>=4: quest,=struct.unpack_from('<I',p,0)
        elif st=='HNAM': phases+=1
    print("  SCEN 0x%08X edid=%r quest=0x%08X fields=%s" % (fid, edid, quest or 0, dict(fields)))

# QUST aliases: do any aliases exist that would attach dialogue to NPCs? + quest DATA/ANAM
print("\n=== QUST alias / structure ===")
for typ,fid,rd,pd in flat:
    if typ!='QUST': continue
    edid=None; aliases=0; fields=collections.Counter()
    for st,p in subs(rd):
        fields[st]+=1
        if st=='EDID': edid=cstr(p)
        elif st=='ALST' or st=='ALLS': aliases+=1
    print("  QUST 0x%08X %r aliases(ALST/ALLS)=%d  fieldtypes=%s" % (fid, edid, aliases, dict(fields)))

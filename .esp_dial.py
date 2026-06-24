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
    label = data[off+8:off+12]; groupType, = struct.unpack_from('<i', data, off+12)
    return typ, groupSize, label, groupType
def iter_subrecords(rd):
    off=0; big=None
    while off+6<=len(rd):
        styp=rd[off:off+4].decode('latin1'); ssize,=struct.unpack_from('<H',rd,off+4); off+=6
        if styp=='XXXX':
            big,=struct.unpack_from('<I',rd,off); off+=ssize; continue
        if big is not None: ssize=big; big=None
        yield styp, rd[off:off+ssize]; off+=ssize
def cstr(b): return b.split(b'\x00')[0].decode('latin1','replace')

# Build a tree honoring GRUP nesting so we know each INFO's parent DIAL (GRUP type 7 label=DIAL formID)
flat=[]  # (typ, fid, rd, parent_dial_fid, grouptype, group_label_fid)
def walk(off,end,parent_dial=None):
    while off<end:
        if data[off:off+4]==b'GRUP':
            _,gsize,label,gtype=read_grup_header(off)
            pd=parent_dial
            if gtype==7:  # Topic children -> label is DIAL formID
                pd,=struct.unpack_from('<I',label,0)
            walk(off+24, off+gsize, pd)
            off+=gsize
        else:
            typ,dsz,fl,fid,fv=read_rec_header(off)
            rd=data[off+24:off+24+dsz]
            flat.append((typ,fid,rd,parent_dial))
            off+=24+dsz
typ0,dsz0,*_=read_rec_header(0)
walk(24+dsz0,len(data))

# Map DIAL -> info, and DIAL metadata
dials={}
for typ,fid,rd,pd in flat:
    if typ!='DIAL': continue
    edid=None; full=None; quest=None; subtype=None; dat=None
    for styp,p in iter_subrecords(rd):
        if styp=='EDID': edid=cstr(p)
        elif styp=='FULL': full=cstr(p)
        elif styp=='QNAM' and len(p)>=4: quest,=struct.unpack_from('<I',p,0)
        elif styp=='DATA': dat=p
        elif styp=='SNAM': subtype=cstr(p)
    dials[fid]={'edid':edid,'full':full,'quest':quest,'subtype':subtype,'data':dat,'infos':[]}

# INFO analysis
COND_FUNC={ # a few common Starfield/FO4 condition function indices
}
infos=[]
for typ,fid,rd,pd in flat:
    if typ!='INFO': continue
    conds=[]; flags=None; has_frag=False; prompt=None; resp=0
    for styp,p in iter_subrecords(rd):
        if styp=='CTDA':
            # CTDA: operator/flags(1), unk(3), comp value(4 float or formid), function index(2), padding(2), param1(4), param2(4)...
            op=p[0]; func,=struct.unpack_from('<H',p,8)
            conds.append((op,func))
        elif styp=='ENAM': flags=p
        elif styp=='VMAD':
            if b'TIF_' in p: has_frag=True
        elif styp=='RNAM': prompt=cstr(p)  # prompt text (player choice label)
        elif styp=='TRDT': resp+=1
    if pd in dials: dials[pd]['infos'].append(fid)
    infos.append({'fid':fid,'dial':pd,'nconds':len(conds),'conds':conds,'flags':flags,'frag':has_frag,'prompt':prompt,'responses':resp})

# Report: which quest owns each DIAL
print("=== DIAL -> quest ownership ===")
qcount=collections.Counter()
for fid,d in dials.items():
    qcount[d['quest']]+=1
for q,c in qcount.items():
    print("  quest 0x%08X owns %d DIAL topics" % (q if q else 0, c))

print("\n=== INFO condition stats ===")
nocond=sum(1 for i in infos if i['nconds']==0)
print("INFOs total:", len(infos))
print("INFOs with ZERO conditions:", nocond)
print("INFOs with >=1 condition:", len(infos)-nocond)
fdist=collections.Counter()
for i in infos:
    fdist[i['nconds']]+=1
print("condition-count distribution:", dict(sorted(fdist.items())))

# function index histogram
funcs=collections.Counter()
for i in infos:
    for op,fn in i['conds']:
        funcs[fn]+=1
print("\ncondition function-index histogram (top):")
for fn,c in funcs.most_common(15):
    print("   func %d : %d uses" % (fn,c))

# Show the DIALs that have prompts/full and their info conditions (player-facing choices)
print("\n=== Player-facing topics (DIAL has FULL) with their INFO conditions ===")
shown=0
for fid,d in dials.items():
    if not d['full']: continue
    if shown>=30: break
    shown+=1
    infoconds=[next((ii for ii in infos if ii['fid']==inf), None) for inf in d['infos']]
    cc=[ (ii['nconds'] if ii else '?') for ii in infoconds]
    print("  DIAL 0x%08X q=0x%08X subtype=%r FULL=%r  infos=%d condcounts=%s frags=%s"
          % (fid, d['quest'] or 0, d['subtype'], d['full'][:40], len(d['infos']), cc,
             [ (ii['frag'] if ii else '?') for ii in infoconds]))

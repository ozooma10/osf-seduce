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

byfid={fid:(typ,rd,pd) for typ,fid,rd,pd in flat}

# DIAL details
dial={}
for typ,fid,rd,pd in flat:
    if typ!='DIAL': continue
    info={'edid':None,'full':None,'sub':None,'branch':None,'data':None,'tifl':None,'prio':None}
    for st,p in subs(rd):
        if st=='EDID': info['edid']=cstr(p)
        elif st=='FULL': info['full']=cstr(p)
        elif st=='SNAM': info['sub']=cstr(p)
        elif st=='BNAM' and len(p)>=4: info['branch'],=struct.unpack_from('<I',p,0)
        elif st=='PNAM' and len(p)>=4: info['prio'],=struct.unpack_from('<f',p,0)
        elif st=='DATA': info['data']=p
    dial[fid]=info

# DLBR (branches)
print("=== DLBR (dialogue branches) ===")
for typ,fid,rd,pd in flat:
    if typ!='DLBR': continue
    edid=None;quest=None;flags=None;start=None
    for st,p in subs(rd):
        if st=='EDID': edid=cstr(p)
        elif st=='QNAM' and len(p)>=4: quest,=struct.unpack_from('<I',p,0)
        elif st=='DNAM' and len(p)>=4: flags,=struct.unpack_from('<I',p,0)
        elif st=='TNAM' and len(p)>=4: start,=struct.unpack_from('<I',p,0)
    fl = flags or 0
    typ_branch = {0:'Player',1:'Blocking',2:'Top-Level',4:'??'}
    print("  DLBR 0x%08X edid=%r quest=0x%08X flags=0x%X (TopLevel=%s Blocking=%s) startDIAL=0x%08X"
          % (fid, edid, quest or 0, fl, bool(fl&0x2), bool(fl&0x1), start or 0))

# The 19 fragment INFOs
print("\n=== The 19 TIF-fragment INFO topics (the interactive ones) ===")
frag_fids=[]
for typ,fid,rd,pd in flat:
    if typ!='INFO': continue
    isfrag=False; prompt=None; rnam=None; nconds=0; resp_text=[]
    for st,p in subs(rd):
        if st=='VMAD' and b'TIF_' in p: isfrag=True
        elif st=='RNAM': rnam=cstr(p)
        elif st=='CTDA': nconds+=1
        elif st=='NAM1': resp_text.append(cstr(p))
    if isfrag:
        frag_fids.append(fid)
        d=dial.get(pd,{})
        print("  INFO 0x%08X  in DIAL 0x%08X (full=%r sub=%r branch=0x%08X prio=%s)  conds=%d  RNAM=%r resp=%r"
              % (fid, pd or 0, d.get('full'), d.get('sub'), d.get('branch') or 0, d.get('prio'), nconds, rnam, resp_text[:1]))

# DIAL subtype histogram
print("\n=== DIAL subtype histogram ===")
sh=collections.Counter(d['sub'] for d in dial.values())
for k,v in sh.items(): print("   %r : %d" % (k,v))

# Branch usage by DIAL
print("\n=== DIALs that point to a branch (BNAM) ===")
withbranch=[ (fid,d) for fid,d in dial.items() if d['branch'] ]
print("DIALs with branch:", len(withbranch), "of", len(dial))
for fid,d in withbranch[:25]:
    print("   DIAL 0x%08X full=%r sub=%r -> branch 0x%08X" % (fid,d['full'],d['sub'],d['branch']))

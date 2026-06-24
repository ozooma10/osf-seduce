import struct
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

def parse_vmad_scriptnames(p):
    # VMAD: version(h), objFormat(h), scriptCount(H), then scripts
    names=[]
    try:
        ver,objf,sc=struct.unpack_from('<hhH',p,0); o=6
        for _ in range(sc):
            nlen,=struct.unpack_from('<H',p,o); o+=2
            nm=p[o:o+nlen].decode('latin1','replace'); o+=nlen
            names.append(nm)
            status,=struct.unpack_from('<B',p,o); o+=1
            pcount,=struct.unpack_from('<H',p,o); o+=2
            # skip properties
            for _ in range(pcount):
                pl,=struct.unpack_from('<H',p,o); o+=2
                o+=pl
                ptype,=struct.unpack_from('<B',p,o); o+=1
                o=skip_prop(p,o,ptype)
    except Exception as e:
        names.append("<err %s>"%e)
    return names
def skip_prop(p,o,t):
    if t==1: o+=4
    elif t==2: o+=4
    elif t==3: o+=4
    elif t==4: o+=4
    elif t==5: o+=1
    elif t in (11,):
        n,=struct.unpack_from('<I',p,o); o+=4
        for _ in range(n): o=skip_prop(p,o,1)
    else:
        # fallback: bail
        raise ValueError("unknown prop type %d"%t)
    return o

print("=== QUST VMAD scripts ===")
for typ,fid,rd,pd in flat:
    if typ!='QUST': continue
    edid=None
    for st,p in subs(rd):
        if st=='EDID': edid=cstr(p)
    for st,p in subs(rd):
        if st=='VMAD':
            # crude: scan for ascii script-name-ish tokens
            toks=[]
            idx=0
            raw=p
            # find printable runs >=4
            cur=b''
            runs=[]
            for b in raw:
                if 32<=b<127: cur+=bytes([b])
                else:
                    if len(cur)>=4: runs.append(cur.decode('latin1'))
                    cur=b''
            if len(cur)>=4: runs.append(cur.decode('latin1'))
            print("  QUST %r VMAD ascii-runs: %s" % (edid, runs[:12]))

print("\n=== SCEN ascii runs (script refs / actions) ===")
for typ,fid,rd,pd in flat:
    if typ!='SCEN': continue
    edid=None
    for st,p in subs(rd):
        if st=='EDID': edid=cstr(p)
    # gather VMAD-ish names across whole record
    runs=[]; cur=b''
    for b in rd:
        if 32<=b<127: cur+=bytes([b])
        else:
            if len(cur)>=5: runs.append(cur.decode('latin1'))
            cur=b''
    print("  SCEN %r runs: %s" % (edid, [r for r in runs if not r.startswith('OSF/')][:20]))

# Scene01 greet conditions raw
print("\n=== Scene01_Greet CTDA raw ===")
for typ,fid,rd,pd in flat:
    if typ!='SCEN' or fid!=0x01000823: continue
    for st,p in subs(rd):
        if st=='CTDA':
            op=p[0]; func,=struct.unpack_from('<H',p,8)
            print("   CTDA op=0x%02X func=%d raw=%s" % (op,func,p.hex()))

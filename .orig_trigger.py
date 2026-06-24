import struct, collections
PATH = r"C:\Users\NICKLEBACK\Downloads\SAF_Seduce_1_3_espversion (1)\SAF_Seduce_1_3_espversion\Data\NAFSeduce.esp"
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
byfid={fid:(typ,rd) for typ,fid,rd,pd in flat}
def name(fid):
    if fid in byfid:
        for st,p in subs(byfid[fid][1]):
            if st=='EDID': return "%s:%s"%(byfid[fid][0],cstr(p))
        return byfid[fid][0]
    if fid and (fid>>24)==0: return "Starfield:0x%06X"%fid
    return "0x%08X"%fid

# ---- MGEF DATA decode ----
print("=== MGEF DATA ===")
for typ,fid,rd,pd in flat:
    if typ!='MGEF': continue
    for st,p in subs(rd):
        if st=='DATA':
            print("  DATA len=%d" % len(p))
            flags,=struct.unpack_from('<I',p,0)
            print("  flags=0x%08X" % flags)
            # scan DATA for plausible formIDs (0x01xxxxxx this mod, or Starfield refs)
            fids=set()
            for o in range(0,len(p)-3,4):
                v,=struct.unpack_from('<I',p,o)
                if (v>>24)==1 and (v&0xFFFFFF)!=0xFFFFFF:
                    fids.add((o,v))
            for o,v in sorted(fids):
                print("    @+%d formID 0x%08X -> %s" % (o,v,name(v)))
            print("  hex:", p.hex())

# ---- SeduceMainQuest: alias detail + scene start + dialogue conditions count ----
print("\n=== SeduceMainQuest alias + structure ===")
for typ,fid,rd,pd in flat:
    if typ!='QUST' or fid!=0x01000819: continue
    for st,p in subs(rd):
        if st in ('ALST','ALID','FNAM','ALFG','ALFR','ALUA','ALEQ','ALCO','ALCA','ALFE','ALFD','VTCK','ALED'):
            extra=''
            if st=='ALID': extra=cstr(p)
            elif len(p)==4:
                v,=struct.unpack_from('<I',p,0); extra="0x%08X %s"%(v, name(v) if (v>>24)==1 else '')
            print("   %s (%d) %s" % (st, len(p), extra))

# ---- SCEN Scene01 full: phases, actions, conditions, what it does ----
print("\n=== SCEN Scene01_Greet detail ===")
for typ,fid,rd,pd in flat:
    if typ!='SCEN' or fid!=0x01000823: continue
    order=[]
    for st,p in subs(rd):
        order.append(st)
        if st=='CTDA':
            op=p[0]; func,=struct.unpack_from('<H',p,8); comp,=struct.unpack_from('<f',p,4)
            # param1 at offset 12
            param1,=struct.unpack_from('<I',p,12)
            print("   CTDA op=0x%02X func=%d comp=%s param1=0x%08X(%s)" % (op,func,comp,param1, name(param1) if (param1>>24)==1 else ''))
        elif st=='ALID':
            v,=struct.unpack_from('<I',p,0); print("   scene ALID alias-index=%d"%v)
        elif st in ('NAM0','PNAM','DNAM','WNAM','LNAM','ANAM','INAM','HTID','DTGT'):
            if len(p)==4:
                v,=struct.unpack_from('<I',p,0)
                if (v>>24)==1: print("   %s -> %s" % (st, name(v)))
    print("   field order:", order)

# ---- which records reference the ALCH/MGEF? (find triggers) ----
print("\n=== who references MGEF 0x0100081A or ALCH 0x0100081B ? ===")
targets={0x0100081A:'MGEF',0x0100081B:'ALCH'}
for typ,fid,rd,pd in flat:
    for o in range(0,len(rd)-3):
        v,=struct.unpack_from('<I',rd,o)
        if v in targets:
            print("   %s 0x%08X (%s) references %s" % (typ,fid,name(fid),targets[v]))
            break

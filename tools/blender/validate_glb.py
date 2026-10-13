import json,struct,sys
buf=open(sys.argv[1],"rb").read()
assert buf[:4]==b"glTF"
version,total=struct.unpack_from("<II",buf,4)
assert version==2 and total==len(buf)
length,fmt=struct.unpack_from("<I4s",buf,12)
assert fmt==b"JSON"
data=json.loads(buf[20:20+length].decode("utf-8").strip())
targets=max((len(p.get("targets",[])) for m in data.get("meshes",[]) for p in m.get("primitives",[])),default=0)
assert targets>=7, f"Missing morph targets: {targets}"
assert len(data.get("materials",[]))>=6
print(f"PASS glb: {len(buf)} bytes, {targets} morph targets")

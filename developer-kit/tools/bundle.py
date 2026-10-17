#!/usr/bin/env python3
"""Build an explicit SDK source ZIP, never a workspace/card/firmware copy."""
from pathlib import Path
import argparse,hashlib,json,zipfile
from uncle import KIT,need

VERSION='0.1.0'
ROOT_FILES=['AGENTS.md','README.md','COMPATIBILITY.md','LICENSE.txt','NOTICES.md','VALIDATION.md']
DIRECTORIES=['api','docs','tools','tests','templates','examples','resources']
ALLOWED={'.md','.txt','.json','.lua','.py','.bvp','.rgb565','.wav'}

def build(output):
    files=[]
    for name in ROOT_FILES:
        p=KIT/name;need(p.is_file(),'Missing kit root document: '+name);files.append(p)
    for name in DIRECTORIES:
        folder=KIT/name;need(folder.is_dir(),'Missing SDK directory: '+name)
        for p in folder.rglob('*'):
            need(not p.is_symlink() and not (hasattr(p,'is_junction') and p.is_junction()),'SDK links/junctions forbidden')
            if '__pycache__' in p.parts or p.suffix=='.pyc':continue
            if p.is_file():
                need(p.suffix in ALLOWED,'Unreviewed SDK type: '+p.name)
                need(p.name.lower() not in {'save.dat','progress.log','nvs.bin'},'Private state forbidden')
                files.append(p)
    target=Path(output);target.parent.mkdir(parents=True,exist_ok=True)
    inventory=[]
    with zipfile.ZipFile(target,'x',compression=zipfile.ZIP_DEFLATED) as z:
        for p in sorted(files):
            name=p.relative_to(KIT).as_posix();data=p.read_bytes()
            inventory.append(dict(path=name,bytes=len(data),sha256=hashlib.sha256(data).hexdigest()))
            info=zipfile.ZipInfo('uncle-s3-lua-kit-'+VERSION+'/'+name,(2026,10,18,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED;info.external_attr=0o644<<16
            z.writestr(info,data)
        info=zipfile.ZipInfo('uncle-s3-lua-kit-'+VERSION+'/INVENTORY.json',(2026,10,18,0,0,0));info.compress_type=zipfile.ZIP_DEFLATED
        z.writestr(info,json.dumps(dict(version=VERSION,kind='source-developer-kit-no-firmware',files=inventory),indent=2)+'\n')
    return dict(file=target.name,bytes=target.stat().st_size,sha256=hashlib.sha256(target.read_bytes()).hexdigest(),files=len(inventory))

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',required=True);a=p.parse_args()
    try:print(json.dumps(build(a.output),indent=2))
    except (ValueError,OSError) as e:p.exit(1,'ERROR: '+str(e)+'\n')

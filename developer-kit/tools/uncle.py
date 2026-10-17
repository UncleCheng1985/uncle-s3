#!/usr/bin/env python3
"""UNCLE S3 project checks/archives. Python 3.10+ standard library only; no device writes."""
from __future__ import annotations
import argparse
import hashlib
import json
from pathlib import Path, PurePosixPath
import re
import shutil
import struct
import subprocess
import sys
import wave
import zipfile
import zlib

KIT = Path(__file__).resolve().parents[1]
ID = re.compile(r'[a-z0-9-]{1,32}\Z')
ASSET_NAME = re.compile(r'[a-z0-9_-]{1,23}\Z')
HEADER = struct.Struct('<4sHHIIII8s')
ENTRY = struct.Struct('<24sBBHHHHIIIH')
RESERVED = {'beatvocab-study', 'beatvocab-snake', 'neon-snake', 'neon-dodge',
            'clockwork-descent', 'olympus-weave', 'blockfall', 'stick-lab',
            'sdk-starter', 'coin-dash', 'pocket-counter'}
SAVE_NAMES = {'save.dat', 'save.tmp', 'save.bak', 'progress.log', 'progress.bak',
              'progress.tmp', 'nvs.bin'}
EXTENSIONS = {'.lua', '.json', '.txt', '.md', '.bvp', '.bvc', '.wav', '.bin'}


def need(condition, message):
    if not condition:
        raise ValueError(message)


def pairs_unique(pairs):
    result = {}
    for key, value in pairs:
        need(key not in result, 'Duplicate JSON key: '+key)
        result[key] = value
    return result


def read_json(path):
    return json.loads(path.read_text(encoding='utf-8'), object_pairs_hook=pairs_unique)


def relative(name, limit=32):
    need(isinstance(name, str) and 1 <= len(name.encode('utf-8')) <= limit,
         f'Path must have 1..{limit} UTF-8 bytes: {name!r}')
    # Deliberately stricter than firmware for Windows portability.
    need(re.fullmatch(r'[A-Za-z0-9_.\-/]+', name) is not None, 'Use portable ASCII path: '+name)
    need(not name.startswith('/') and all(p not in ('', '.', '..') for p in name.split('/')),
         'Unsafe relative path: '+name)
    for segment in name.split('/'):
        need(not segment.endswith(('.', ' ')) and segment.split('.')[0].upper() not in
             {'CON','PRN','AUX','NUL',*(f'COM{i}' for i in range(1,10)),*(f'LPT{i}' for i in range(1,10))},
             'Windows-reserved path: '+name)
    return name


def local_file(root, name):
    relative(name)
    path = root
    for segment in name.split('/'):
        path = path/segment
        need(not path.is_symlink() and not (hasattr(path, 'is_junction') and path.is_junction()),
             'Links/junctions are not package content: '+name)
    need(path.is_file() and path.resolve().is_relative_to(root.resolve()), 'Missing/escaped file: '+name)
    return path


def fnv(data):
    value = 2166136261
    for byte in data:
        value = ((value ^ byte)*16777619) & 0xffffffff
    return value


def cover(path):
    data = path.read_bytes()
    need(len(data) == 20+198*198*2, 'BVC1 size mismatch')
    magic,w,h,size,digest,reserved = struct.unpack_from('<4sHHIII',data)
    need((magic,w,h,size,reserved)==(b'BVC1',198,198,198*198*2,0), 'Invalid BVC1 header')
    need(fnv(data[20:])==digest, 'BVC1 checksum mismatch')


def pack_entries(path):
    data = path.read_bytes()
    need(32 <= len(data) <= 4*1024*1024, 'BVP1 must be 32 bytes..4MiB')
    magic,version,count,index,start,total,index_crc,_ = HEADER.unpack_from(data)
    need(magic==b'BVP1' and version==1 and 1<=count<=128, 'Invalid BVP1 version/count')
    need(32<=index and index+count*48<=start<=total==len(data), 'Invalid BVP1 offsets/size')
    need(zlib.crc32(data[index:index+count*48])==index_crc, 'BVP1 index CRC mismatch')
    entries = {}
    for i in range(count):
        raw,fmt,_,w,h,fw,fh,offset,size,crc,_ = ENTRY.unpack_from(data,index+i*48)
        name=raw.split(b'\0',1)[0].decode('ascii')
        need(ASSET_NAME.fullmatch(name) and name not in entries, 'Invalid/duplicate BVP1 asset name')
        need(start<=offset and offset+size<=total, 'BVP1 asset outside file')
        payload=data[offset:offset+size]
        need(zlib.crc32(payload)==crc, 'BVP1 asset CRC mismatch: '+name)
        if fmt in (1,2,3):
            pixels=w*h
            expected=pixels*2+(0 if fmt==1 else (pixels+7)//8 if fmt==2 else (pixels+1)//2)
            need(1<=w<=960 and 1<=h<=960 and 1<=fw<=w and 1<=fh<=h and w%fw==0 and h%fh==0 and size==expected,
                 'Invalid BVP1 image geometry: '+name)
        elif fmt in (4,5):
            need((h,fw,fh)==(1,1,1), 'Invalid PCM shape')
            need((fmt==4 and w==48000 and 2<=size<=192000 and size%2==0) or
                 (fmt==5 and w==12000 and 1<=size<=120000), 'Invalid PCM rate/length')
        else:
            raise ValueError('Unknown BVP1 format')
        entries[name]=fmt
    return entries


def wav_file(path):
    need(path.stat().st_size<=256*1024, 'audio.play_file WAV exceeds 256KiB')
    with wave.open(str(path),'rb') as f:
        need(f.getnchannels()==1 and f.getcomptype()=='NONE' and
             (f.getframerate(),f.getsampwidth()) in ((12000,1),(48000,2)),
             'audio.play_file needs mono PCM8/12kHz or PCM16/48kHz WAV')
        frames=f.getnframes()
        need(0<frames<=f.getframerate()*2.5, 'audio.play_file max duration is 2.5s')
        need(len(f.readframes(frames))==frames*f.getsampwidth(), 'Truncated WAV')


def strip_lua(text):
    # Small lexer for direct-call lint only. NOT a Lua parser or syntax check.
    token=re.compile(r'--\[(=*)\[.*?\]\1\]|--[^\n]*|\[(=*)\[.*?\]\2\]|"(?:\\.|[^"\\])*"|\'(?:\\.|[^\'\\])*\'',re.S)
    return token.sub(lambda m:' '*(len(m[0])-m[0].count('\n'))+'\n'*m[0].count('\n'),text)


def check(project, luac=None):
    root=Path(project).resolve()
    need(root.is_dir(), 'Project directory missing')
    manifest_path=local_file(root,'game.json')
    raw=manifest_path.read_bytes()
    need(0<len(raw)<=2048 and not raw.startswith(b'\xef\xbb\xbf'), 'game.json: 1..2048 UTF-8 bytes, no BOM')
    need(re.search(rb'\\u[0-9a-fA-F]{4}',raw) is None, 'Manifest uses raw UTF-8, not JSON unicode escapes')
    m=read_json(manifest_path)
    need(isinstance(m,dict), 'Manifest must be a flat object')
    need(set(m)<= {'id','title','api','orientation','entry','icon','assets'}, 'SDK policy: unknown manifest keys rejected')
    need(isinstance(m.get('id'),str) and ID.fullmatch(m['id']) and root.name==m['id'], 'ID must match folder: 1..32 lowercase ASCII letters/digits/hyphens')
    need(m['id']!='beatvocab-study', 'Reserved hidden system project ID')
    title=m.get('title')
    need(isinstance(title,str) and 1<=len(title.encode('utf-8'))<=63 and not any(ord(c)<32 for c in title), 'Title: 1..63 UTF-8 bytes, no controls')
    need(type(m.get('api')) is int and m['api']==1, 'api must be integer 1')
    need(m.get('orientation') in ('landscape','portrait'), 'orientation: landscape or portrait')
    entry=relative(m.get('entry'))
    need(entry.endswith('.lua'), 'SDK requires .lua entry suffix (firmware only checks substring)')
    need(0<local_file(root,entry).stat().st_size<=65536, 'Entry must be 1..65536 bytes')
    plan=read_json(local_file(root,'project.json'))
    need(isinstance(plan,dict) and plan.get('schema')==1 and isinstance(plan.get('files'),list), 'project.json needs schema=1 and files array')
    files=plan['files']
    need(1<=len(files)<=128 and len(files)==len(set(files)), 'files allowlist: 1..128 unique strings')
    need({'game.json',entry,'LICENSE.txt'}<=set(files), 'Allowlist must include game.json, entry and LICENSE.txt')
    need(len({n.lower() for n in files})==len(files), 'Case-insensitive filename collision')
    for name in files:
        path=local_file(root,name)
        need(path.name.lower() not in SAVE_NAMES and not path.name.startswith('.'), 'Never package saves/hidden files: '+name)
        need(path.suffix.lower() in EXTENSIONS, 'Not a reviewed runtime/content extension: '+name)
        need(path.stat().st_size<=4*1024*1024, 'SDK per-file limit: 4MiB')
    entries={}
    if m.get('assets'):
        need(m['assets'] in files, 'assets pack must be in files allowlist')
        entries=pack_entries(local_file(root,m['assets']))
    if m.get('icon'):
        need(m['icon'] in files, 'SDK requires declared icon present (device can fall back)')
        cover(local_file(root,m['icon']))
    for name in files:
        if name.startswith('audio/') and name.endswith('.wav'): wav_file(local_file(root,name))
    api=read_json(KIT/'api/api.json')
    valid={r['name'] for r in api['functions']}
    namespaces={n.split('.')[0] for n in valid if '.' in n}
    warnings=[]
    for name in files:
        if not name.endswith('.lua'):continue
        text=local_file(root,name).read_text(encoding='utf-8')
        need(not text.startswith('\ufeff') and '\0' not in text, 'Lua source: UTF-8 without BOM/NUL')
        clean=strip_lua(text)
        for blocked in ('require','dofile','loadfile','load','collectgarbage'):
            need(not re.search(r'\b'+blocked+r'\s*\(',clean), 'Unavailable Lua function: '+blocked)
        need(not re.search(r'\b(io|os|debug|package|coroutine|love|socket|wifi|gpio)\s*[.:]',clean), 'Unavailable desktop/firmware namespace')
        for namespace, method in re.findall(r'\b([A-Za-z_]\w*)\s*\.\s*([A-Za-z_]\w*)\s*\(',clean):
            if namespace in namespaces:
                need(namespace+'.'+method in valid, 'Unknown device API: '+namespace+'.'+method)
                need(namespace!='vocab', 'vocab is reserved; not available to international user projects')
        # Direct literal references: computed names must be declared in project.json.
        for kind,asset_name in re.findall(r'asset\.(image|sound)\s*\(\s*["\']([^"\']+)["\']',text):
            need(asset_name in entries and (entries[asset_name] in (1,2,3))==(kind=='image'), 'Missing/wrong packed asset: '+asset_name)
        for file_name in re.findall(r'(?:data\.(?:size|read)|audio\.play_file)\s*\(\s*["\']([^"\']+)["\']',text):
            need(file_name in files, 'Referenced runtime file not allowlisted: '+file_name)
        if name==entry:
            need(re.search(r'\bfunction\s+init\s*\(',clean) and re.search(r'\bfunction\s+update\s*\(',clean),
                 'SDK style requires global function init() and function update(dt)')
        if luac:
            version=subprocess.run([luac,'-v'],capture_output=True,text=True)
            need('Lua 5.4' in version.stdout+version.stderr, 'Use Lua 5.4 luac; not 5.1/5.3/LuaJIT')
            run=subprocess.run([luac,'-p',str(local_file(root,name))],capture_output=True,text=True)
            need(run.returncode==0,'Lua syntax: '+run.stdout+run.stderr)
    warnings.append('Structural/direct-call checks only; dynamic Lua behavior, timing, memory, visual/audio output and device success are NOT certified.')
    if not luac:warnings.append('Lua syntax was NOT parsed. Optional: --luac path-to-Lua-5.4-luac for syntax checking.')
    return m,files,warnings


def new_project(template, dest, title=None):
    src=Path(template).resolve();dest=Path(dest).absolute()
    need(not dest.exists(), 'Destination already exists; no overwrite')
    need(ID.fullmatch(dest.name) and dest.name not in RESERVED, 'Choose a unique non-reserved lowercase project ID')
    _,files,_=check(src)
    dest.mkdir(parents=True,exist_ok=False)
    for name in files+['project.json']:
        target=dest/name;target.parent.mkdir(parents=True,exist_ok=True)
        shutil.copyfile(local_file(src,name),target)
    m=read_json(dest/'game.json');m['id']=dest.name;m['title']=title or dest.name.replace('-',' ').title()
    (dest/'game.json').write_text(json.dumps(m,ensure_ascii=False,indent=2)+'\n',encoding='utf-8')
    check(dest)
    return dest


def package(project, output, luac=None):
    root=Path(project).resolve();m,files,warnings=check(root,luac)
    target=Path(output).resolve()
    need(not target.is_relative_to(root), 'Archive output must be outside the project')
    inventory=[]
    target.parent.mkdir(parents=True,exist_ok=True)
    with zipfile.ZipFile(target,'x',compression=zipfile.ZIP_DEFLATED) as z:
        for name in sorted(files):
            data=local_file(root,name).read_bytes();arc='Games/'+m['id']+'/'+name
            z.writestr(arc,data)
            inventory.append(dict(path=arc,bytes=len(data),sha256=hashlib.sha256(data).hexdigest()))
        z.writestr('UNCLE-PACKAGE.json',json.dumps(dict(api=1,files=inventory,warnings=warnings),indent=2)+'\n')
    return inventory,warnings


def main():
    parser=argparse.ArgumentParser(description=__doc__)
    sub=parser.add_subparsers(dest='action',required=True)
    n=sub.add_parser('new');n.add_argument('destination');n.add_argument('--template',default=str(KIT/'templates/sdk-starter'));n.add_argument('--title')
    c=sub.add_parser('check');c.add_argument('project');c.add_argument('--luac')
    p=sub.add_parser('package');p.add_argument('project');p.add_argument('--output',required=True);p.add_argument('--luac')
    args=parser.parse_args()
    try:
        if args.action=='new':print('CREATED',new_project(args.template,args.destination,args.title))
        elif args.action=='check':
            m,files,warnings=check(args.project,args.luac);print('STRUCTURE PASS',m['id'],len(files),'runtime files')
            for w in warnings:print('NOTE:',w)
        else:
            inventory,warnings=package(args.project,args.output,args.luac);print('PREPARED',args.output,len(inventory),'files; extract Games/ to card root while device is off')
            for w in warnings:print('NOTE:',w)
    except (ValueError,OSError,TypeError,KeyError,UnicodeError,struct.error,zipfile.BadZipFile,wave.Error) as e:
        print('ERROR:',e,file=sys.stderr);return 1
    return 0


if __name__=='__main__':sys.exit(main())

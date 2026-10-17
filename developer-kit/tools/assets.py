#!/usr/bin/env python3
"""Create BVP1 from explicit raw RGB565 or compatible WAV; Python standard library only."""
from pathlib import Path
import argparse,json,struct,wave,zlib
from uncle import ASSET_NAME,HEADER,ENTRY,need,pack_entries

def build(config_path,output):
    config_path=Path(config_path).resolve();config=json.loads(config_path.read_text(encoding='utf-8'))
    definitions=config['assets'];need(1<=len(definitions)<=128,'Use 1..128 assets')
    payload=bytearray();index=bytearray();start=(32+48*len(definitions)+3)&~3;names=set()
    for d in definitions:
        name=d['name'];need(ASSET_NAME.fullmatch(name) and name not in names,'Invalid/duplicate asset name');names.add(name)
        source=(config_path.parent/d['path']).resolve()
        need(source.is_relative_to(config_path.parent),'Asset source must stay beside/under config')
        if d['format']=='rgb565':
            fmt=1;w=d['width'];h=d['height'];fw=d.get('frame_width',w);fh=d.get('frame_height',h);data=source.read_bytes()
            need(1<=w<=960 and 1<=h<=960 and 1<=fw<=w and 1<=fh<=h and w%fw==h%fh==0 and len(data)==w*h*2,'Invalid raw RGB565 shape')
        elif d['format'] in ('pcm_s16_mono_48k','pcm_u8_mono_12k'):
            fmt=4 if d['format']=='pcm_s16_mono_48k' else 5;w=48000 if fmt==4 else 12000;h=fw=fh=1
            with wave.open(str(source),'rb') as f:
                need((f.getnchannels(),f.getframerate(),f.getsampwidth(),f.getcomptype())==(1,w,2 if fmt==4 else 1,'NONE'),'Wrong WAV format')
                frames=f.getnframes();need(1<=frames<=(96000 if fmt==4 else 120000),'WAV exceeds packed duration limit')
                data=f.readframes(frames);need(len(data)==frames*(2 if fmt==4 else 1),'Truncated WAV')
        else:raise ValueError('Builder supports rgb565 and two PCM formats; alpha formats may be authored to documented binary format')
        while (start+len(payload))%4:payload.append(0)
        offset=start+len(payload);payload.extend(data)
        index.extend(ENTRY.pack(name.encode()+b'\0'*(24-len(name)),fmt,0,w,h,fw,fh,offset,len(data),zlib.crc32(data),0))
    header=HEADER.pack(b'BVP1',1,len(definitions),32,start,start+len(payload),zlib.crc32(index),bytes(8))
    blob=header+index+bytes(start-32-len(index))+payload;need(len(blob)<=4*1024*1024,'BVP exceeds4MiB')
    output=Path(output);output.parent.mkdir(parents=True,exist_ok=True)
    with output.open('xb') as f:f.write(blob)
    pack_entries(output)
    return output

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('config');p.add_argument('--output',required=True);a=p.parse_args()
    try:print('CREATED',build(a.config,a.output))
    except (ValueError,OSError,KeyError,TypeError,wave.Error) as e:p.exit(1,'ERROR: '+str(e)+'\n')

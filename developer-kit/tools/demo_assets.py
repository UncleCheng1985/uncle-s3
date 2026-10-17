#!/usr/bin/env python3
"""Recreate original Coin Dash inputs. Standard library only; no downloaded media."""
import argparse,json,math,struct,wave
from pathlib import Path

def generate(output):
    p=Path(output);p.mkdir(parents=True,exist_ok=False)
    pixels=[]
    for y in range(16):
        for x in range(16):
            c=0xFFD34E if (x-7.5)**2+(y-7.5)**2<49 else 0x111827
            pixels.append(((c>>19)&31)<<11|((c>>10)&63)<<5|((c>>3)&31))
    (p/'coin.rgb565').write_bytes(struct.pack('<256H',*pixels))
    with wave.open(str(p/'collect.wav'),'wb') as f:
        f.setparams((1,1,12000,960,'NONE','not compressed'))
        f.writeframes(bytes(max(0,min(255,128+int(38*(1-i/960)*math.sin(2*math.pi*(720+360*i/960)*i/12000)))) for i in range(960)))
    (p/'pack.json').write_text(json.dumps({'assets':[
        dict(name='coin',format='rgb565',path='coin.rgb565',width=16,height=16),
        dict(name='collect',format='pcm_u8_mono_12k',path='collect.wav')]},indent=2)+'\n',encoding='utf-8')
    return p

if __name__=='__main__':
    p=argparse.ArgumentParser(description=__doc__);p.add_argument('--output',required=True);a=p.parse_args()
    try:print('CREATED',generate(a.output))
    except OSError as e:p.exit(1,'ERROR: '+str(e)+'\n')

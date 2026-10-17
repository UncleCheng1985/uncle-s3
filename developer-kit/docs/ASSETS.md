# Assets: exact device formats and a small reproducible example

[API](API.md) · [runtime](RUNTIME.md)

Start with gfx primitives and compiled device fonts: no image/font download is
needed. PNG/JPEG/MP3 files are **not** directly supported by asset.image/sound.
The built-in fonts remain firmware-provided; no font file is redistributed here.

## Included resource example

Coin Dash includes `assets.bvp` with a16×16 opaque coin and an80ms original
PCM8/12kHz mono collect tone. Build inputs and [source generator](../tools/demo_assets.py)
are included. Rebuild to a NEW output, then compare before intentionally replacing
your project's file:

```powershell
python tools/demo_assets.py --output dist/demo-assets-source
python tools/assets.py dist/demo-assets-source/pack.json --output dist/demo-assets.bvp
```

`demo_assets.py` creates its output directory exclusively. `assets.py` refuses an
existing destination. No downloads, external media or optional Pillow needed.
All included source bytes are MIT original program-generated art/audio.

## Building your own pack (standard library)

Give tools/assets.py a UTF-8 JSON config with paths relative to that config:

```json
{"assets":[
  {"name":"coin","format":"rgb565","path":"coin.rgb565","width":16,"height":16},
  {"name":"collect","format":"pcm_u8_mono_12k","path":"collect.wav"}
]}
```

Raw RGB565: little-endian 16-bit per pixel, row-major, exactly width*height*2 bytes.
RGB bits5/6/5; builder supports1..960 in each dimension. Optional frame_width/
frame_height divide the full image exactly. Default frame is the whole image.
WAV: uncompressed mono, either signed PCM16LE/48000Hz(max2s) or unsigned PCM8/
12000Hz(max10s) for BVP. No conversion/resampling is hidden in this builder.
Choose a file you own or are permitted to distribute. Use audio.play/loop with the
loaded sound handle. audio.play_file has a DIFFERENT max2.5s and256KiB limit.

## BVP1 binary specification

All fields little-endian. File <=4MiB. Header32 bytes:

| Offset | Type | Meaning |
| --- | --- | --- |
| 0 | char[4] | BVP1 |
| 4 | u16 | version1 |
| 6 | u16 | count1..128 |
| 8 | u32 | index offset, >=32 |
| 12 | u32 | payload start, >=index+count*48 |
| 16 | u32 | total file bytes, must equal file length |
| 20 | u32 | IEEE CRC32 of index bytes |
| 24 | byte[8] | builder writes zero |

Each index entry48 bytes:

| Offset | Type | Meaning |
| --- | --- | --- |
| 0 | char[24] | NUL-terminated unique name,1..23 [a-z0-9_-] |
| 24 | u8 | format1 RGB565 /2 RGB565+A1 /3 RGB565+A4 /4 PCM16mono48k /5 PCM8mono12k |
| 25 | u8 | builder writes zero |
| 26,28 | u16,u16 | width,height (PCM: sampleRate,1) |
| 30,32 | u16,u16 | frameWidth,frameHeight (PCM:1,1) |
| 34,38,42 | u32,u32,u32 | absolute payload offset,byte length,payload IEEE CRC32 |
| 46 | u16 | builder writes zero |

Image1 payload=RGB565 bytes. Image2 adds ceil(pixels/8) mask bytes, LSB first,
1=opaque. Image3 adds ceil(pixels/2) alpha bytes, even pixel low nibble,0transparent
to15opaque; RGB565 channels blended. Frames index row-major, zero-based. CRCs and
shape validated before use; image data checked at load. Runtime raw PCM4 requires
2..192000 even bytes, PCM5 requires1..120000 bytes. Builder implements opaque and
both PCM formats; validator also checks alpha formats. No compressed textures.

32 loaded slots shared;1.5MiB total cache, sound portion512KiB. Repeated image load
increments refs, asset.release decrements; sounds stay pinned until project exit.
Load once, not each frame. Work in bounded strips/updates for large images. Do not
free/reload sounds to try to bypass the sound-cache limit.

## Optional Games cover BVC1

This is separate from BVP. `/Games/<id>/cover.bvc`, manifest `"icon":"cover.bvc"`.
Header20 bytes: ASCII BVC1; u16 width198; u16 height198; u32 pixelBytes78408;
u32 FNV1a of pixel bytes; u32 reserved0. Exactly78408 RGB565LE bytes follow.
Missing/invalid cover falls back to default. SDK checker requires a valid declared
cover so mistakes are found before installation. Runtime doesn't load PNG/JPEG covers.

## Small read-only data

data.size/read operates under the project only; paths <=32 bytes. data.read is
0..512 bytes with zero-based byte offset, not Lua1-based indexing. Declare files
in project.json, including computed names. There is no directory enumeration,
arbitrary write or JSON decoder built into Lua. For simple tables, embed Lua data
in main.lua; for small text, read bounded chunks. Do not ship saves as resources.

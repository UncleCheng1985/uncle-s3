# Complete Lua API reference

Applies to the exact international preview.9 runtime identified in [COMPATIBILITY](../COMPATIBILITY.md).
Read [runtime and manifest](RUNTIME.md) first. There are **44 bound functions** below,
including 9 reserved vocabulary bindings; listing them does not make them usable
by public projects. JSON contract: [api.json](../api/api.json). Editor declarations:
[uncle.lua](../api/uncle.lua), annotation-only, **never load/copy as runtime code**.

All numeric arguments shown as integer must be actual integers (use math.floor
for motion positions). Invalid types normally raise Lua errors. A listed empty
return list means no return values, not false. Limits count UTF-8 bytes.
No implicit screen units, desktop files, hardware pins or network calls exist.
Each snippet assumes execution inside init/update. Resource snippets require
matching handles/files/manifest pack; they are not standalone full projects.


## `gfx.clear(color)`

**Status:** public. **Returns:** none.

Fills the entire persistent canvas and marks it dirty. Expensive every frame; prefer local redraws.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `color` | `integer` | RGB 0xRRGGBB, use 0..0xFFFFFF; low 24 bits are used. |

```lua
gfx.clear(0x101828)
```

## `gfx.rect(x, y, w, h, color)`

**Status:** public. **Returns:** none.

Filled rectangle; clips to canvas. Keep coordinate arithmetic within signed 32-bit; dimensions near screen size.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `x` | `integer` | Top-left x; integer logical pixel, clipped to canvas. |
| `y` | `integer` | Top-left y; integer logical pixel, clipped to canvas. |
| `w` | `integer` | Width in pixels; <=0 draws nothing. |
| `h` | `integer` | Height in pixels; <=0 draws nothing. |
| `color` | `integer` | RGB 0xRRGGBB, use 0..0xFFFFFF; low 24 bits are used. |

```lua
gfx.rect(20, 80, 32, 32, 0x36D6A0)
```

## `gfx.round_rect(x, y, w, h, radius, color)`

**Status:** public. **Returns:** none.

Filled rounded rectangle. Invalid radius raises an error.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `x` | `integer` | Top-left x; integer logical pixel, clipped to canvas. |
| `y` | `integer` | Top-left y; integer logical pixel, clipped to canvas. |
| `w` | `integer` | Width in pixels; <=0 draws nothing. |
| `h` | `integer` | Height in pixels; <=0 draws nothing. |
| `radius` | `integer` | 0..64; further clamped to half the smaller dimension. |
| `color` | `integer` | RGB 0xRRGGBB, use 0..0xFFFFFF; low 24 bits are used. |

```lua
gfx.round_rect(20, 80, 80, 48, 8, 0x36D6A0)
```

## `gfx.text(text, x, y, color)`

**Status:** public. **Returns:** none.

Fixed 5x7 glyphs drawn at 2x, 12px advance and 14px height. Only ASCII letters/digits/space; lowercase becomes uppercase; other glyphs show a question mark. No wrapping, scaling parameter, font loading or newline layout.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `text` | `string` | At most 80 UTF-8 BYTES (not characters); avoid NUL and newlines. |
| `x` | `integer` | Top-left x; integer logical pixel, clipped to canvas. |
| `y` | `integer` | Top-left y; integer logical pixel, clipped to canvas. |
| `color` | `integer` | RGB 0xRRGGBB, use 0..0xFFFFFF; low 24 bits are used. |

```lua
gfx.text("Hello", 20, 20, 0xFFFFFF)
```

## `gfx.text_utf8(text, x, y, color)`

**Status:** public. **Returns:** none.

Existing 16px bitmap font. No wrapping, scaling parameter, font loading or newline layout. UTF-8 decoding does not imply all-language font coverage; missing compiled glyphs are skipped with spacing.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `text` | `string` | At most 192 UTF-8 BYTES (not characters); avoid NUL and newlines. |
| `x` | `integer` | Top-left x; integer logical pixel, clipped to canvas. |
| `y` | `integer` | Top-left y; integer logical pixel, clipped to canvas. |
| `color` | `integer` | RGB 0xRRGGBB, use 0..0xFFFFFF; low 24 bits are used. |

```lua
gfx.text_utf8("Hello", 20, 20, 0xFFFFFF)
```

## `gfx.text_medium(text, x, y, color)`

**Status:** public. **Returns:** none.

Existing 24px bitmap font. No wrapping, scaling parameter, font loading or newline layout. UTF-8 decoding does not imply all-language font coverage; missing compiled glyphs are skipped with spacing.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `text` | `string` | At most 192 UTF-8 BYTES (not characters); avoid NUL and newlines. |
| `x` | `integer` | Top-left x; integer logical pixel, clipped to canvas. |
| `y` | `integer` | Top-left y; integer logical pixel, clipped to canvas. |
| `color` | `integer` | RGB 0xRRGGBB, use 0..0xFFFFFF; low 24 bits are used. |

```lua
gfx.text_medium("Hello", 20, 20, 0xFFFFFF)
```

## `gfx.text_big(text, x, y, color)`

**Status:** public. **Returns:** none.

Existing 24px bitmap font at 2x (48px). No wrapping, scaling parameter, font loading or newline layout. UTF-8 decoding does not imply all-language font coverage; missing compiled glyphs are skipped with spacing.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `text` | `string` | At most 96 UTF-8 BYTES (not characters); avoid NUL and newlines. |
| `x` | `integer` | Top-left x; integer logical pixel, clipped to canvas. |
| `y` | `integer` | Top-left y; integer logical pixel, clipped to canvas. |
| `color` | `integer` | RGB 0xRRGGBB, use 0..0xFFFFFF; low 24 bits are used. |

```lua
gfx.text_big("Hello", 20, 20, 0xFFFFFF)
```

## `gfx.text_width(text, size)`

**Status:** public. **Returns:** `integer`.

Returns the width using matching built-in UTF-8 font advances; not the fixed gfx.text font. Use it to wrap/truncate in Lua.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `text` | `string` | At most 192 UTF-8 bytes. |
| `size` | `integer` | Exactly 16, 24 or 48. |

```lua
local w = gfx.text_width("Hello", 24)
```

## `gfx.blit(handle, x, y)`

**Status:** public. **Returns:** none.

Draws frame ZERO of an image at native frame dimensions, not necessarily the full sprite sheet; clips; uses alpha if packed. Wrong handle/error raises.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `handle` | `integer` | Opaque live handle returned by asset.image or asset.sound; never invent a number. |
| `x` | `integer` | Top-left x; integer logical pixel, clipped to canvas. |
| `y` | `integer` | Top-left y; integer logical pixel, clipped to canvas. |

```lua
local image = asset.image("coin"); gfx.blit(image, 20, 80)
```

## `gfx.blit_clean(handle, x, y)`

**Status:** public. **Returns:** none.

Same frame-zero drawing but does NOT invalidate. Call gfx.invalidate for the affected region before presentation. Advanced batching only.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `handle` | `integer` | Opaque live handle returned by asset.image or asset.sound; never invent a number. |
| `x` | `integer` | Top-left x; integer logical pixel, clipped to canvas. |
| `y` | `integer` | Top-left y; integer logical pixel, clipped to canvas. |

```lua
gfx.blit_clean(image, 20, 80); gfx.invalidate(20, 80, 16, 16)
```

## `gfx.blit_frame(handle, frame, x, y)`

**Status:** public. **Returns:** none.

Uses packed frameWidth/frameHeight. No runtime resizing/rotation. Invalid frame raises.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `handle` | `integer` | Opaque live handle returned by asset.image or asset.sound; never invent a number. |
| `frame` | `integer` | Zero-based 0..frameCount-1, also <=65535; row-major across sheet. |
| `x` | `integer` | Top-left x; integer logical pixel, clipped to canvas. |
| `y` | `integer` | Top-left y; integer logical pixel, clipped to canvas. |

```lua
gfx.blit_frame(image, 0, 20, 80)
```

## `gfx.invalidate(x, y, w, h)`

**Status:** public. **Returns:** none.

Marks modified canvas region for next normal presentation; drawing is not performed. Dirty regions may merge or fall back to full canvas.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `x` | `integer` | Top-left x; integer logical pixel, clipped to canvas. |
| `y` | `integer` | Top-left y; integer logical pixel, clipped to canvas. |
| `w` | `integer` | Width in pixels; <=0 draws nothing. |
| `h` | `integer` | Height in pixels; <=0 draws nothing. |

```lua
gfx.invalidate(20, 80, 16, 16)
```

## `gfx.hold_present(hold)`

**Status:** public. **Returns:** none.

Lua updates and drawing continue while held; remember to release. This is not sleep, threading or a pause API.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `hold` | `boolean` | true to suppress normal end-of-update presentation; false to resume. |

```lua
gfx.hold_present(false)
```

## `gfx.restore(handle, x, y, w, h)`

**Status:** public. **Returns:** none.

Copies the same x/y region from a full opaque RGB565 background image, not a sprite placed at x/y. Positive w/h required; clips to image/canvas. Other formats raise.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `handle` | `integer` | Opaque live handle returned by asset.image or asset.sound; never invent a number. |
| `x` | `integer` | Top-left x; integer logical pixel, clipped to canvas. |
| `y` | `integer` | Top-left y; integer logical pixel, clipped to canvas. |
| `w` | `integer` | Positive width; zero/negative raises. |
| `h` | `integer` | Positive height; zero/negative raises. |

```lua
gfx.restore(background, 20, 80, 32, 32)
```

## `data.size(path)`

**Status:** public. **Returns:** `integer|nil`.

File length in bytes; nil on absent/unreadable/directory/unsafe path. No file handle returned.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `path` | `string` | Game-relative UTF-8 path 1..32 bytes; no leading slash, backslash, controls, empty/./.. segments. Read-only under /Games/<id>/. SDK uses stricter portable ASCII. |

```lua
local size = data.size("data/message.txt")
```

## `data.read(path, offset, count)`

**Status:** public. **Returns:** `string|nil`.

Binary-safe exact string; missing/unsafe path => nil; out-of-range/seek/read failure raises. Not an unbounded file reader; avoid reading entire assets into Lua.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `path` | `string` | Game-relative UTF-8 path 1..32 bytes; no leading slash, backslash, controls, empty/./.. segments. Read-only under /Games/<id>/. SDK uses stricter portable ASCII. |
| `offset` | `integer` | Zero-based nonnegative byte offset; representable on device (signed int32). |
| `count` | `integer` | 0..512; offset+count must be <= file size. |

```lua
local text = data.read("data/message.txt", 0, 5)
```

## `asset.image(name)`

**Status:** public. **Returns:** `integer`.

Loads/checks image payload and returns opaque handle; missing/wrong type/cache/CRC failure raises. Images are reference-counted; sounds pinned until exit. Cache shared: 32 slots / 1.5MiB; sound subset <=512KiB.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `name` | `string` | 1..23 ASCII characters [a-z0-9_-], matching an entry in the manifest assets BVP1. |

```lua
local image = asset.image("coin")
```

## `asset.sound(name)`

**Status:** public. **Returns:** `integer`.

Loads/checks sound payload and returns opaque handle; missing/wrong type/cache/CRC failure raises. Images are reference-counted; sounds pinned until exit. Cache shared: 32 slots / 1.5MiB; sound subset <=512KiB.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `name` | `string` | 1..23 ASCII characters [a-z0-9_-], matching an entry in the manifest assets BVP1. |

```lua
local sound = asset.sound("collect")
```

## `asset.release(handle)`

**Status:** public. **Returns:** `boolean`.

False for invalid/stale handle. Images decrement refs/free on last release. Sounds return true but remain pinned until game exit to protect mixer memory. Do not retain/reuse a released image handle.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `handle` | `integer` | Opaque live handle returned by asset.image or asset.sound; never invent a number. |

```lua
local released = asset.release(image)
```

## `asset.info(handle)`

**Status:** public. **Returns:** `integer`, `integer`, `integer`, `integer`.

Image handles ONLY: returns full image width, height, frame width, frame height (in that order); sound handle raises.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `handle` | `integer` | Opaque live handle returned by asset.image or asset.sound; never invent a number. |

```lua
local w, h, fw, fh = asset.info(image)
```

## `audio.play(handle, volume)`

**Status:** public. **Returns:** `boolean`.

One-shot. Sound handle required; false if mixer unavailable/paused/unhealthy. Four voices; full mixer steals oldest non-loop voice, or slot zero if every voice loops. No individual voice ID/status. Pack containing sounds starts mixer at game load. No MP3 decoding API.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `handle` | `integer` | Opaque live handle returned by asset.image or asset.sound; never invent a number. |
| `volume` | `integer?` | Optional 0..100, default 100; relative gain also follows system volume. |

```lua
local accepted = audio.play(sound, 60)
```

## `audio.loop(handle, volume)`

**Status:** public. **Returns:** `boolean`.

Loop. Sound handle required; false if mixer unavailable/paused/unhealthy. Four voices; full mixer steals oldest non-loop voice, or slot zero if every voice loops. No individual voice ID/status. Pack containing sounds starts mixer at game load. No MP3 decoding API.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `handle` | `integer` | Opaque live handle returned by asset.image or asset.sound; never invent a number. |
| `volume` | `integer?` | Optional 0..100, default 100; relative gain also follows system volume. |

```lua
local accepted = audio.loop(sound, 60)
```

## `audio.play_file(path, volume)`

**Status:** public. **Returns:** `boolean`.

Returns true when QUEUED, not when playback succeeds. One pending path (later call wins), processed after update/presentation/save. WAV <=256KiB, mono PCM8 unsigned/12kHz OR PCM16 signed LE/48kHz, <=2.5 seconds. Failure is logged [WORD_AUDIO]; prior file-backed sound replaced after successful load. Cannot stream music/MP3.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `path` | `string` | Exactly game-relative audio/<name>.wav; lowercase prefix/suffix, 11..32 bytes and safe relative path. |
| `volume` | `integer?` | Optional 0..100, default 100. |

```lua
local queued = audio.play_file("audio/click.wav", 50)
```

## `audio.stop_all()`

**Status:** public. **Returns:** none.

Stops active mixer voices, does not free asset handles. Does not cancel a play_file request still queued earlier in the same update.

```lua
audio.stop_all()
```

## `input.direction()`

**Status:** public. **Returns:** `"left"|"right"|"up"|"down"|nil`.

Current held digital direction or nil when neutral; no analog axes, diagonals or confirm state. Portrait is already remapped; do not rotate directions again.

```lua
local held = input.direction()
```

## `input.pressed()`

**Status:** public. **Returns:** `"left"|"right"|"up"|"down"|"confirm"|nil`.

Consumes ONE queued edge per call, not a state. Queue length four; directions use newest final slot on overflow; confirm drops when full. No release events or auto-repeat for held direction. Drain with a bounded loop (max four). Startup/resume waits for neutral.

```lua
local edge = input.pressed()
```

## `input.serial()`

**Status:** public. **Returns:** `integer`.

Input change counter for direction transitions and accepted confirm; not serial-port data. Changes may exceed queue entries. Reset at game start, wraps; not a high-precision timer.

```lua
local change = input.serial()
```

## `system.time_ms()`

**Status:** public. **Returns:** `integer`.

Device uptime from millis(), includes POWER pause time; underlying uint32 wraps ~49.7 days, returned through signed 32-bit Lua integer (~24.9 day sign boundary). Use update dt for gameplay; short deltas with wrap arithmetic only. Not Unix time.

```lua
local uptime = system.time_ms()
```

## `system.day()`

**Status:** public. **Returns:** `integer`.

0 before valid clock (Unix timestamp <2024-01-01); otherwise floor((unixSeconds+8*3600)/86400), fixed UTC+8 day number. Not locale-aware or guaranteed available. No set/sync API.

```lua
local day = system.day(); if day == 0 then print("No date") end
```

## `system.exit()`

**Status:** public. **Returns:** none.

Requests clean exit handled by host after update; it does not abort the current Lua function. Return immediately. No shutdown/menu/settings APIs.

```lua
system.exit(); return
```

## `storage.get(key, default)`

**Status:** public. **Returns:** `integer`.

Per-project integer store, cached in memory, 16 keys total. Missing key returns default. Invalid key raises.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `key` | `string` | 1..24 ASCII letters/digits/_/-. |
| `default` | `integer?` | Fallback integer, default 0. |

```lua
local best = storage.get("best", 0)
```

## `storage.set(key, value)`

**Status:** public. **Returns:** none.

Queue/update key; 17th key raises. Writes coalesced about every 2s and on normal pause/exit; no immediate durable-success return. [GAME_SAVE] okay=0 reports failure. No key deletion. Never save every frame. ID determines /Games/<id>/save.dat; preserve on updates.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `key` | `string` | 1..24 ASCII letters/digits/_/-. |
| `value` | `integer` | Signed int32 -2147483648..2147483647. |

```lua
storage.set("best", 12)
```

## `storage.word_get(id)`

**Status:** advanced. **Returns:** `integer`.

Advanced per-project hashed progress.log store: missing =>0, values positive int32. Not cross-project shared. Allocates memory proportional to entries, up to32768; avoid for ordinary games. Log limit4MiB, no deletion API.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `id` | `string` | 2..48 lowercase ASCII letters/digits/hyphens. |

```lua
local value = storage.word_get("item-01")
```

## `storage.word_set(id, value)`

**Status:** advanced. **Returns:** none.

Advanced append queue: max32 distinct pending IDs per update, flushed after update/on pause/exit. Memory/write failures may terminate game. Use storage.set for small scores. No included vocabulary content.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `id` | `string` | 2..48 lowercase ASCII letters/digits/hyphens. |
| `value` | `integer` | 1..2147483647 (zero/negative rejected). |

```lua
storage.word_set("item-01", 1)
```

## `vocab.open(path, cursor)`

**Status:** reserved. **Returns:** `integer|nil`.

RESERVED: requires attached internal BVW3 cache owned by beatvocab-study, hidden by international catalog. Do NOT use or adopt that ID in public projects; no word data/authorization supplied. init/top-level opens synchronously and returns count; during update queues open and returns nil; later tick opens/primes, failure stops script.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `path` | `string` | Game-relative UTF-8 path 1..32 bytes; no leading slash, backslash, controls, empty/./.. segments. Read-only under /Games/<id>/. SDK uses stricter portable ASCII. |
| `cursor` | `integer?` | Optional zero-based cursor, default0; 0..9999 and <pack count. |

```lua
-- Reserved only: local count = vocab.open("index.bvw", 0)
```

## `vocab.state(index)`

**Status:** reserved. **Returns:** `integer`.

RESERVED: requires attached internal BVW3 cache owned by beatvocab-study, hidden by international catalog. Do NOT use or adopt that ID in public projects; no word data/authorization supplied. Returns cached packed int32 state (0 unseen). Invalid/unattached index raises.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `index` | `integer` | Zero-based 0..count-1. |

```lua
-- Reserved only: local value = vocab.state(0)
```

## `vocab.set(index, value)`

**Status:** reserved. **Returns:** none.

RESERVED: requires attached internal BVW3 cache owned by beatvocab-study, hidden by international catalog. Do NOT use or adopt that ID in public projects; no word data/authorization supplied. Appends progress synchronously before cached update; failure raises. Learning encoding uses 1+round*8+level with round1..1000000 and level0..5.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `index` | `integer` | Zero-based 0..count-1. |
| `value` | `integer` | Positive int32 encoded state. |

```lua
-- Reserved only: vocab.set(0, 9)
```

## `vocab.read(index)`

**Status:** reserved. **Returns:** `string`.

RESERVED: requires attached internal BVW3 cache owned by beatvocab-study, hidden by international catalog. Do NOT use or adopt that ID in public projects; no word data/authorization supplied. Raw indexed record bytes in a string (bounded record buffer2048); no parsed table; read failure raises.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `index` | `integer` | Zero-based 0..count-1. |

```lua
-- Reserved only: local record = vocab.read(0)
```

## `vocab.info()`

**Status:** reserved. **Returns:** `integer`, `integer`, `integer`, `integer`, `integer`.

RESERVED: requires attached internal BVW3 cache owned by beatvocab-study, hidden by international catalog. Do NOT use or adopt that ID in public projects; no word data/authorization supplied. Returns count, windowFirst, windowAfter(exclusive), loadedBytes, windowBytes. Unattached raises.

```lua
-- Reserved only: local n, first, after, loaded, size = vocab.info()
```

## `vocab.ready()`

**Status:** reserved. **Returns:** `integer|nil`.

RESERVED: requires attached internal BVW3 cache owned by beatvocab-study, hidden by international catalog. Do NOT use or adopt that ID in public projects; no word data/authorization supplied. Pack count when async selection is ready and attached, otherwise nil.

```lua
-- Reserved only: local n = vocab.ready()
```

## `vocab.learned(blockedBits)`

**Status:** reserved. **Returns:** `integer`.

RESERVED: requires attached internal BVW3 cache owned by beatvocab-study, hidden by international catalog. Do NOT use or adopt that ID in public projects; no word data/authorization supplied. Count valid learned encoded states excluding bitmap entries.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `blockedBits` | `string` | Empty string or binary bitmap exactly ceil(count/8) bytes; bit i%8 set excludes zero-based entry i (LSB first). |

```lua
-- Reserved only: local n = vocab.learned("")
```

## `vocab.stats(blockedBits, round)`

**Status:** reserved. **Returns:** `integer`, `integer`, `integer`, `integer`, `integer`.

RESERVED: requires attached internal BVW3 cache owned by beatvocab-study, hidden by international catalog. Do NOT use or adopt that ID in public projects; no word data/authorization supplied. Returns learned,due,weak,mastered,firstNew. firstNew is ONE-based or0; state/read indices are zero-based. Due<=round, weak level<=1, mastered level>=4.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `blockedBits` | `string` | Empty string or binary bitmap exactly ceil(count/8) bytes; bit i%8 set excludes zero-based entry i (LSB first). |
| `round` | `integer` | 1..1000000, learning round, not current clock time. |

```lua
-- Reserved only: local learned, due, weak, mastered, first = vocab.stats("", 1)
```

## `vocab.review(blockedBits, round, dueOnly, weakOnly)`

**Status:** reserved. **Returns:** `integer[]`.

RESERVED: requires attached internal BVW3 cache owned by beatvocab-study, hidden by international catalog. Do NOT use or adopt that ID in public projects; no word data/authorization supplied. Returns up to20 ONE-based entry positions in pack order, excluding blocked/unlearned/invalid states. Subtract1 before state/read.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `blockedBits` | `string` | Empty string or binary bitmap exactly ceil(count/8) bytes; bit i%8 set excludes zero-based entry i (LSB first). |
| `round` | `integer` | 1..1000000, learning round, not current clock time. |
| `dueOnly` | `boolean` | Boolean filter: only due states. |
| `weakOnly` | `boolean` | Boolean filter: only levels0..1. |

```lua
-- Reserved only: local positions = vocab.review("", 1, true, false)
```

## `print(...)`

**Status:** public. **Returns:** none.

USB debug [GAME_LOG] line, not screen text. No raw UART API. Avoid per-frame spam.

| Parameter | Type | Range / meaning |
| --- | --- | --- |
| `...` | `any` | Up to first four values; each converted to string and truncated to80 bytes. |

```lua
print("Started", GAME_API_VERSION)
```

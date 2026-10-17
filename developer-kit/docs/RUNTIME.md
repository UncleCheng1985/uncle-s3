# Runtime, project structure and limits

[Kit home](../README.md) · [API](API.md) · [asset formats](ASSETS.md)

## Lua and globals

Lua5.4.9, signed int32 / float32. Use source UTF-8 without BOM, not bytecode; entry
size1..65536 bytes. Positive hex RGB values fit int32, but hashes/large milliseconds
may appear signed. Floats lose unit precision beyond ~16.7million. Use small scores,
short elapsed intervals and dt. `string.pack/unpack` are Lua standard string functions;
native numeric formats differ from desktop. Use explicit endianness and sizes for data.

Opened libraries: base `_G`, `table`, `string`, `math`, `utf8`. Normal base helpers
like pairs/ipairs/type/pcall/assert/tonumber and math/string/table/utf8 operations are
present. `_VERSION` is Lua5.4. No coroutine library is opened. `dofile`, `loadfile`,
`load`, `collectgarbage`, `require`, `package`, `io`, `os`, `debug` are set to nil.
No sockets, HTTP, desktop filesystem, threads, FFI, Love2D or Python binding.
Automatic garbage collection remains; there is no manual collectgarbage API.

Device globals: `GAME_API_VERSION=1`, `SCREEN_WIDTH`, `SCREEN_HEIGHT`, the eight
namespace tables gfx/data/asset/audio/input/system/storage/vocab, and custom `print`.
They are provided by firmware. Do not replace them or run editor declaration stubs.
Lua supports normal functions, closures, tables and metatables within the budgets.

## Lifecycle

Host loads one entry chunk in text-only mode, executes it, then calls global
`init()` once; `update(dt)` repeatedly while active/unpaused. Both required.
No draw/keypressed/onPause/onExit callbacks, event loop or project module loader.
Put helper functions in the entry. Extra .lua files are not automatically executed.

Target ~24 updates/sec (not guaranteed). dt is seconds of elapsed monotonic time
clamped to0.1. POWER pauses updates/audio and clears pending input; resume resets
tick timing, so paused duration does not get added to dt. Use dt for gameplay, not
system.time_ms wall-clock subtraction. There is no user Lua pause callback.
Normal exit flushes dirty saves and releases Lua/canvas/resources/audio. system.exit
requests this; finish the current function promptly. State is recreated on next run.

The framebuffer persists. Draw title once when entering title, then only erase/redraw
changed regions. Integer coordinates start at(0,0), x right, y down; no offscreen
surfaces/scaling/rotation/camera primitives. Colors are 0xRRGGBB integers, stored
RGB565 internally. Text has byte limits, no wrap/newline layout, limited compiled
glyph coverage. `gfx.blit` draws frame0, not the whole sheet if frames are smaller.

## Manifest: `/Games/<id>/game.json`

```json
{"id":"my-square","title":"My Square","api":1,"orientation":"landscape","entry":"main.lua"}
```

| Field | Runtime requirement |
| --- | --- |
| id | Required;1..32 ASCII lowercase a-z,0-9,hyphen; exactly directory name |
| title | Required;1..63 UTF-8 bytes, no control bytes; display name, not save identity |
| api | Required integer1 |
| orientation | Required `landscape` or `portrait`; logical canvas960×376 /376×960 |
| entry | Required safe relative path<=32 bytes containing `.lua`; SDK requires suffix `.lua` |
| assets | Optional safe relative BVP1 path; if declared, failure to open prevents start |
| icon | Optional safe relative BVC1 path; missing/invalid cover falls back in firmware; SDK requires valid declared file |

Manifest1..2048 bytes, no BOM. Parser accepts flat fields, strings/unsigned numbers/
bool/null for unknown scalars, **not arrays/objects**, not `\uXXXX` escapes; raw UTF-8
works. SDK rejects unknown fields/duplicate keys and uses standard JSON for clarity.
Safe paths: relative,1..32 UTF-8 bytes, no leading slash/backslash/control/empty/./..
segments. Firmware applies additional card-path validation; SDK uses portable ASCII
and rejects Windows-reserved filenames. Keep exact case across files/references.

ID controls save ownership. Changing title does not reset saves. Copying a game
requires new folder AND new id; use `uncle.py new`, which refuses reserved sample/
system IDs and existing targets. Keep ID stable when updating the same game.
International catalog hides beatvocab-study; do not repurpose internal IDs.

Games scans at most32 directory entries, accepts at most16 projects, and sorts by
manifest title. Too many invalid folders can consume the scan window. Remove your
unused projects from /Games after backing them up; don't delete unknown user data.

## Development-only allowlist

`project.json` is read by SDK tools, **not firmware**:

```json
{"schema":1,"files":["game.json","main.lua","README.md","LICENSE.txt"]}
```

List every deployed file (including computed paths), <=128 SDK files, <=4MiB each.
Checker verifies literal asset/file references but cannot prove dynamically built
paths. Add a project's usage/license notes. Never include saves, credentials, NVS,
private recordings or author machine paths. Packaging reads only these files,
refuses symlinks/junctions, never modifies a card, and never overwrites a ZIP.
There is no automatic adoption of arbitrary files in a project directory.

## Input and saved state

- `input.direction()` is current held digital direction or nil; no analog values,
  diagonals or held L3 state. Portrait directions already mapped by firmware.
- `input.pressed()` consumes one edge (left/right/up/down/confirm) from a four-slot
  queue. Call at most four times per update to drain; no release event. Held motion
  is your dt-driven logic, not repeated edge events. New direction replaces newest
  queued direction when full; a new confirm can be dropped when full.
- Release to neutral after entry/resume. Gate play after title/retry so start press
  cannot trigger a play action in the same update. POWER/VOL are not Lua buttons.
- storage.get/set:16 keys, key1..24 [A-Za-z0-9_-], int32 values; deferred ~2s and
  normal pause/exit flush to /Games/<id>/save.dat. No arbitrary write or deletion,
  no immediate durable ACK; inspect GAME_SAVE errors. Don't write every frame.
- storage.word_* also exposed: advanced hashed progress store <=32768 items/4MiB
  log/32 pending IDs, memory proportional to entries. Not needed for small apps.
- vocab.* listed for completeness only, unavailable to public international
  projects; requires reserved internal ID/cache/data. Do not ship Chinese assets.

## Resource limits (not performance promises)

| Resource | Audited limit |
| --- | --- |
| Lua allocations | 320KiB including VM/tables/strings, separate from native caches |
| init/top-level call | 1.5s /500000 instructions; hook checks each1000 instructions |
| update call | 120ms /120000 instructions; aim under41.7ms; C work also consumes time |
| dt | capped0.1s; slow frames can slow simulation |
| Dirty rectangles | up to24, merging/full fallback; large area>55% can become full redraw |
| BVP1 | <=4MiB,1..128 entries; loaded slots<=32, image+sound cache1.5MiB |
| Sound subset | <=512KiB; four mixing voices; sounds pinned until exit |
| Text | gfx.text80 bytes; UTF-8/medium/width192; big96 |
| data.read | <=512 bytes/call, within one project file |
| File WAV API | <=256KiB, mono8bit12kHz or16bit48kHz, <=2.5s |
| Raw PCM in BVP | PCM16/48kHz<=2s or PCM8/12kHz<=10s per asset |

Split expensive initialization/drawing across updates; do not weaken budgets or
spin in busy loops. Memory/cache availability may be lower under real conditions.
Script errors stop the project and show an error; POWER remains the system exit path.

## Lua content vs firmware work

Possible: original arcade/puzzle games, scoreboards, counters, quizzes with your
own permitted data, small local interactive tools using the APIs above.

Requires firmware changes: new native home app/OS setting, microphone recording
API, Music MP3 controller, Wi-Fi/BLE/network requests, direct USB/UART access,
GPIO/I2C/ADC, charger or power control, new font loader/codec/engine, changing
input calibration or runtime limits. Ask for a separate firmware task; do not
invent a Lua method, flash firmware or install a desktop engine for a content request.

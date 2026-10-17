---@meta
-- SPDX-License-Identifier: MIT
-- EDITOR DECLARATIONS ONLY. NOT an implementation. Never require or run this file.
-- Read docs/API.md and api.json for full limits, errors and parameter semantics.
---@type integer
GAME_API_VERSION = 1
---@type integer
SCREEN_WIDTH = 960
---@type integer
SCREEN_HEIGHT = 376
gfx = {}
data = {}
asset = {}
audio = {}
input = {}
system = {}
storage = {}
vocab = {}

-- PUBLIC: Fills the entire persistent canvas and marks it dirty. Expensive every frame; prefer local redraws.
---@param color integer RGB 0xRRGGBB, use 0..0xFFFFFF; low 24 bits are used.
function gfx.clear(color) end

-- PUBLIC: Filled rectangle; clips to canvas. Keep coordinate arithmetic within signed 32-bit; dimensions near screen size.
---@param x integer Top-left x; integer logical pixel, clipped to canvas.
---@param y integer Top-left y; integer logical pixel, clipped to canvas.
---@param w integer Width in pixels; <=0 draws nothing.
---@param h integer Height in pixels; <=0 draws nothing.
---@param color integer RGB 0xRRGGBB, use 0..0xFFFFFF; low 24 bits are used.
function gfx.rect(x, y, w, h, color) end

-- PUBLIC: Filled rounded rectangle. Invalid radius raises an error.
---@param x integer Top-left x; integer logical pixel, clipped to canvas.
---@param y integer Top-left y; integer logical pixel, clipped to canvas.
---@param w integer Width in pixels; <=0 draws nothing.
---@param h integer Height in pixels; <=0 draws nothing.
---@param radius integer 0..64; further clamped to half the smaller dimension.
---@param color integer RGB 0xRRGGBB, use 0..0xFFFFFF; low 24 bits are used.
function gfx.round_rect(x, y, w, h, radius, color) end

-- PUBLIC: Fixed 5x7 glyphs drawn at 2x, 12px advance and 14px height. Only ASCII letters/digits/space; lowercase becomes uppercase; other glyphs show a question mark. No wrapping, scaling parameter, font loading or newline layout.
---@param text string At most 80 UTF-8 BYTES (not characters); avoid NUL and newlines.
---@param x integer Top-left x; integer logical pixel, clipped to canvas.
---@param y integer Top-left y; integer logical pixel, clipped to canvas.
---@param color integer RGB 0xRRGGBB, use 0..0xFFFFFF; low 24 bits are used.
function gfx.text(text, x, y, color) end

-- PUBLIC: Existing 16px bitmap font. No wrapping, scaling parameter, font loading or newline layout. UTF-8 decoding does not imply all-language font coverage; missing compiled glyphs are skipped with spacing.
---@param text string At most 192 UTF-8 BYTES (not characters); avoid NUL and newlines.
---@param x integer Top-left x; integer logical pixel, clipped to canvas.
---@param y integer Top-left y; integer logical pixel, clipped to canvas.
---@param color integer RGB 0xRRGGBB, use 0..0xFFFFFF; low 24 bits are used.
function gfx.text_utf8(text, x, y, color) end

-- PUBLIC: Existing 24px bitmap font. No wrapping, scaling parameter, font loading or newline layout. UTF-8 decoding does not imply all-language font coverage; missing compiled glyphs are skipped with spacing.
---@param text string At most 192 UTF-8 BYTES (not characters); avoid NUL and newlines.
---@param x integer Top-left x; integer logical pixel, clipped to canvas.
---@param y integer Top-left y; integer logical pixel, clipped to canvas.
---@param color integer RGB 0xRRGGBB, use 0..0xFFFFFF; low 24 bits are used.
function gfx.text_medium(text, x, y, color) end

-- PUBLIC: Existing 24px bitmap font at 2x (48px). No wrapping, scaling parameter, font loading or newline layout. UTF-8 decoding does not imply all-language font coverage; missing compiled glyphs are skipped with spacing.
---@param text string At most 96 UTF-8 BYTES (not characters); avoid NUL and newlines.
---@param x integer Top-left x; integer logical pixel, clipped to canvas.
---@param y integer Top-left y; integer logical pixel, clipped to canvas.
---@param color integer RGB 0xRRGGBB, use 0..0xFFFFFF; low 24 bits are used.
function gfx.text_big(text, x, y, color) end

-- PUBLIC: Returns the width using matching built-in UTF-8 font advances; not the fixed gfx.text font. Use it to wrap/truncate in Lua.
---@param text string At most 192 UTF-8 bytes.
---@param size integer Exactly 16, 24 or 48.
---@return integer
function gfx.text_width(text, size) end

-- PUBLIC: Draws frame ZERO of an image at native frame dimensions, not necessarily the full sprite sheet; clips; uses alpha if packed. Wrong handle/error raises.
---@param handle integer Opaque live handle returned by asset.image or asset.sound; never invent a number.
---@param x integer Top-left x; integer logical pixel, clipped to canvas.
---@param y integer Top-left y; integer logical pixel, clipped to canvas.
function gfx.blit(handle, x, y) end

-- PUBLIC: Same frame-zero drawing but does NOT invalidate. Call gfx.invalidate for the affected region before presentation. Advanced batching only.
---@param handle integer Opaque live handle returned by asset.image or asset.sound; never invent a number.
---@param x integer Top-left x; integer logical pixel, clipped to canvas.
---@param y integer Top-left y; integer logical pixel, clipped to canvas.
function gfx.blit_clean(handle, x, y) end

-- PUBLIC: Uses packed frameWidth/frameHeight. No runtime resizing/rotation. Invalid frame raises.
---@param handle integer Opaque live handle returned by asset.image or asset.sound; never invent a number.
---@param frame integer Zero-based 0..frameCount-1, also <=65535; row-major across sheet.
---@param x integer Top-left x; integer logical pixel, clipped to canvas.
---@param y integer Top-left y; integer logical pixel, clipped to canvas.
function gfx.blit_frame(handle, frame, x, y) end

-- PUBLIC: Marks modified canvas region for next normal presentation; drawing is not performed. Dirty regions may merge or fall back to full canvas.
---@param x integer Top-left x; integer logical pixel, clipped to canvas.
---@param y integer Top-left y; integer logical pixel, clipped to canvas.
---@param w integer Width in pixels; <=0 draws nothing.
---@param h integer Height in pixels; <=0 draws nothing.
function gfx.invalidate(x, y, w, h) end

-- PUBLIC: Lua updates and drawing continue while held; remember to release. This is not sleep, threading or a pause API.
---@param hold boolean true to suppress normal end-of-update presentation; false to resume.
function gfx.hold_present(hold) end

-- PUBLIC: Copies the same x/y region from a full opaque RGB565 background image, not a sprite placed at x/y. Positive w/h required; clips to image/canvas. Other formats raise.
---@param handle integer Opaque live handle returned by asset.image or asset.sound; never invent a number.
---@param x integer Top-left x; integer logical pixel, clipped to canvas.
---@param y integer Top-left y; integer logical pixel, clipped to canvas.
---@param w integer Positive width; zero/negative raises.
---@param h integer Positive height; zero/negative raises.
function gfx.restore(handle, x, y, w, h) end

-- PUBLIC: File length in bytes; nil on absent/unreadable/directory/unsafe path. No file handle returned.
---@param path string Game-relative UTF-8 path 1..32 bytes; no leading slash, backslash, controls, empty/./.. segments. Read-only under /Games/<id>/. SDK uses stricter portable ASCII.
---@return integer|nil
function data.size(path) end

-- PUBLIC: Binary-safe exact string; missing/unsafe path => nil; out-of-range/seek/read failure raises. Not an unbounded file reader; avoid reading entire assets into Lua.
---@param path string Game-relative UTF-8 path 1..32 bytes; no leading slash, backslash, controls, empty/./.. segments. Read-only under /Games/<id>/. SDK uses stricter portable ASCII.
---@param offset integer Zero-based nonnegative byte offset; representable on device (signed int32).
---@param count integer 0..512; offset+count must be <= file size.
---@return string|nil
function data.read(path, offset, count) end

-- PUBLIC: Loads/checks image payload and returns opaque handle; missing/wrong type/cache/CRC failure raises. Images are reference-counted; sounds pinned until exit. Cache shared: 32 slots / 1.5MiB; sound subset <=512KiB.
---@param name string 1..23 ASCII characters [a-z0-9_-], matching an entry in the manifest assets BVP1.
---@return integer
function asset.image(name) end

-- PUBLIC: Loads/checks sound payload and returns opaque handle; missing/wrong type/cache/CRC failure raises. Images are reference-counted; sounds pinned until exit. Cache shared: 32 slots / 1.5MiB; sound subset <=512KiB.
---@param name string 1..23 ASCII characters [a-z0-9_-], matching an entry in the manifest assets BVP1.
---@return integer
function asset.sound(name) end

-- PUBLIC: False for invalid/stale handle. Images decrement refs/free on last release. Sounds return true but remain pinned until game exit to protect mixer memory. Do not retain/reuse a released image handle.
---@param handle integer Opaque live handle returned by asset.image or asset.sound; never invent a number.
---@return boolean
function asset.release(handle) end

-- PUBLIC: Image handles ONLY: returns full image width, height, frame width, frame height (in that order); sound handle raises.
---@param handle integer Opaque live handle returned by asset.image or asset.sound; never invent a number.
---@return integer
---@return integer
---@return integer
---@return integer
function asset.info(handle) end

-- PUBLIC: One-shot. Sound handle required; false if mixer unavailable/paused/unhealthy. Four voices; full mixer steals oldest non-loop voice, or slot zero if every voice loops. No individual voice ID/status. Pack containing sounds starts mixer at game load. No MP3 decoding API.
---@param handle integer Opaque live handle returned by asset.image or asset.sound; never invent a number.
---@param volume integer? Optional 0..100, default 100; relative gain also follows system volume.
---@return boolean
function audio.play(handle, volume) end

-- PUBLIC: Loop. Sound handle required; false if mixer unavailable/paused/unhealthy. Four voices; full mixer steals oldest non-loop voice, or slot zero if every voice loops. No individual voice ID/status. Pack containing sounds starts mixer at game load. No MP3 decoding API.
---@param handle integer Opaque live handle returned by asset.image or asset.sound; never invent a number.
---@param volume integer? Optional 0..100, default 100; relative gain also follows system volume.
---@return boolean
function audio.loop(handle, volume) end

-- PUBLIC: Returns true when QUEUED, not when playback succeeds. One pending path (later call wins), processed after update/presentation/save. WAV <=256KiB, mono PCM8 unsigned/12kHz OR PCM16 signed LE/48kHz, <=2.5 seconds. Failure is logged [WORD_AUDIO]; prior file-backed sound replaced after successful load. Cannot stream music/MP3.
---@param path string Exactly game-relative audio/<name>.wav; lowercase prefix/suffix, 11..32 bytes and safe relative path.
---@param volume integer? Optional 0..100, default 100.
---@return boolean
function audio.play_file(path, volume) end

-- PUBLIC: Stops active mixer voices, does not free asset handles. Does not cancel a play_file request still queued earlier in the same update.
function audio.stop_all() end

-- PUBLIC: Current held digital direction or nil when neutral; no analog axes, diagonals or confirm state. Portrait is already remapped; do not rotate directions again.
---@return "left"|"right"|"up"|"down"|nil
function input.direction() end

-- PUBLIC: Consumes ONE queued edge per call, not a state. Queue length four; directions use newest final slot on overflow; confirm drops when full. No release events or auto-repeat for held direction. Drain with a bounded loop (max four). Startup/resume waits for neutral.
---@return "left"|"right"|"up"|"down"|"confirm"|nil
function input.pressed() end

-- PUBLIC: Input change counter for direction transitions and accepted confirm; not serial-port data. Changes may exceed queue entries. Reset at game start, wraps; not a high-precision timer.
---@return integer
function input.serial() end

-- PUBLIC: Device uptime from millis(), includes POWER pause time; underlying uint32 wraps ~49.7 days, returned through signed 32-bit Lua integer (~24.9 day sign boundary). Use update dt for gameplay; short deltas with wrap arithmetic only. Not Unix time.
---@return integer
function system.time_ms() end

-- PUBLIC: 0 before valid clock (Unix timestamp <2024-01-01); otherwise floor((unixSeconds+8*3600)/86400), fixed UTC+8 day number. Not locale-aware or guaranteed available. No set/sync API.
---@return integer
function system.day() end

-- PUBLIC: Requests clean exit handled by host after update; it does not abort the current Lua function. Return immediately. No shutdown/menu/settings APIs.
function system.exit() end

-- PUBLIC: Per-project integer store, cached in memory, 16 keys total. Missing key returns default. Invalid key raises.
---@param key string 1..24 ASCII letters/digits/_/-.
---@param default integer? Fallback integer, default 0.
---@return integer
function storage.get(key, default) end

-- PUBLIC: Queue/update key; 17th key raises. Writes coalesced about every 2s and on normal pause/exit; no immediate durable-success return. [GAME_SAVE] okay=0 reports failure. No key deletion. Never save every frame. ID determines /Games/<id>/save.dat; preserve on updates.
---@param key string 1..24 ASCII letters/digits/_/-.
---@param value integer Signed int32 -2147483648..2147483647.
function storage.set(key, value) end

-- ADVANCED: Advanced per-project hashed progress.log store: missing =>0, values positive int32. Not cross-project shared. Allocates memory proportional to entries, up to32768; avoid for ordinary games. Log limit4MiB, no deletion API.
---@param id string 2..48 lowercase ASCII letters/digits/hyphens.
---@return integer
function storage.word_get(id) end

-- ADVANCED: Advanced append queue: max32 distinct pending IDs per update, flushed after update/on pause/exit. Memory/write failures may terminate game. Use storage.set for small scores. No included vocabulary content.
---@param id string 2..48 lowercase ASCII letters/digits/hyphens.
---@param value integer 1..2147483647 (zero/negative rejected).
function storage.word_set(id, value) end

-- RESERVED: RESERVED: requires attached internal BVW3 cache owned by beatvocab-study, hidden by international catalog. Do NOT use or adopt that ID in public projects; no word data/authorization supplied. init/top-level opens synchronously and returns count; during update queues open and returns nil; later tick opens/primes, failure stops script.
---@param path string Game-relative UTF-8 path 1..32 bytes; no leading slash, backslash, controls, empty/./.. segments. Read-only under /Games/<id>/. SDK uses stricter portable ASCII.
---@param cursor integer? Optional zero-based cursor, default0; 0..9999 and <pack count.
---@return integer|nil
function vocab.open(path, cursor) end

-- RESERVED: RESERVED: requires attached internal BVW3 cache owned by beatvocab-study, hidden by international catalog. Do NOT use or adopt that ID in public projects; no word data/authorization supplied. Returns cached packed int32 state (0 unseen). Invalid/unattached index raises.
---@param index integer Zero-based 0..count-1.
---@return integer
function vocab.state(index) end

-- RESERVED: RESERVED: requires attached internal BVW3 cache owned by beatvocab-study, hidden by international catalog. Do NOT use or adopt that ID in public projects; no word data/authorization supplied. Appends progress synchronously before cached update; failure raises. Learning encoding uses 1+round*8+level with round1..1000000 and level0..5.
---@param index integer Zero-based 0..count-1.
---@param value integer Positive int32 encoded state.
function vocab.set(index, value) end

-- RESERVED: RESERVED: requires attached internal BVW3 cache owned by beatvocab-study, hidden by international catalog. Do NOT use or adopt that ID in public projects; no word data/authorization supplied. Raw indexed record bytes in a string (bounded record buffer2048); no parsed table; read failure raises.
---@param index integer Zero-based 0..count-1.
---@return string
function vocab.read(index) end

-- RESERVED: RESERVED: requires attached internal BVW3 cache owned by beatvocab-study, hidden by international catalog. Do NOT use or adopt that ID in public projects; no word data/authorization supplied. Returns count, windowFirst, windowAfter(exclusive), loadedBytes, windowBytes. Unattached raises.
---@return integer
---@return integer
---@return integer
---@return integer
---@return integer
function vocab.info() end

-- RESERVED: RESERVED: requires attached internal BVW3 cache owned by beatvocab-study, hidden by international catalog. Do NOT use or adopt that ID in public projects; no word data/authorization supplied. Pack count when async selection is ready and attached, otherwise nil.
---@return integer|nil
function vocab.ready() end

-- RESERVED: RESERVED: requires attached internal BVW3 cache owned by beatvocab-study, hidden by international catalog. Do NOT use or adopt that ID in public projects; no word data/authorization supplied. Count valid learned encoded states excluding bitmap entries.
---@param blockedBits string Empty string or binary bitmap exactly ceil(count/8) bytes; bit i%8 set excludes zero-based entry i (LSB first).
---@return integer
function vocab.learned(blockedBits) end

-- RESERVED: RESERVED: requires attached internal BVW3 cache owned by beatvocab-study, hidden by international catalog. Do NOT use or adopt that ID in public projects; no word data/authorization supplied. Returns learned,due,weak,mastered,firstNew. firstNew is ONE-based or0; state/read indices are zero-based. Due<=round, weak level<=1, mastered level>=4.
---@param blockedBits string Empty string or binary bitmap exactly ceil(count/8) bytes; bit i%8 set excludes zero-based entry i (LSB first).
---@param round integer 1..1000000, learning round, not current clock time.
---@return integer
---@return integer
---@return integer
---@return integer
---@return integer
function vocab.stats(blockedBits, round) end

-- RESERVED: RESERVED: requires attached internal BVW3 cache owned by beatvocab-study, hidden by international catalog. Do NOT use or adopt that ID in public projects; no word data/authorization supplied. Returns up to20 ONE-based entry positions in pack order, excluding blocked/unlearned/invalid states. Subtract1 before state/read.
---@param blockedBits string Empty string or binary bitmap exactly ceil(count/8) bytes; bit i%8 set excludes zero-based entry i (LSB first).
---@param round integer 1..1000000, learning round, not current clock time.
---@param dueOnly boolean Boolean filter: only due states.
---@param weakOnly boolean Boolean filter: only levels0..1.
---@return integer[]
function vocab.review(blockedBits, round, dueOnly, weakOnly) end

-- PUBLIC: USB debug [GAME_LOG] line, not screen text. No raw UART API. Avoid per-frame spam.
---@param ... any Up to first four values; each converted to string and truncated to80 bytes.
function print(...) end

# Debugging and iteration

1. Note Settings → About version, board v0.2, project ID/package version.
2. Copy the exact displayed error, including entry/line if shown. Photograph the
   screen if easier; don't paraphrase away function names.
3. Exit via POWER. Compare with an unmodified compatible example. Do not erase or
   reflash firmware as a first response to a script/resource error.
4. Run check and optional Lua5.4 luac syntax parsing. Share manifest, allowlist,
   entry and relevant asset hashes/bytes with your AI using [the repair prompt](PROMPTS.md).
5. Package to a new name and follow the full stop/shutdown/disconnect/card-reader
   procedure. Keep old source/package and all saves; no live hot reload.

| Symptom | Likely checks |
| --- | --- |
| Project not listed | Exact /Games/id/game.json path, folder=id, api1, orientation, UTF-8 no BOM/Unicode escapes, flat manifest; scan32 entries/game16 cap; reserved hidden ID |
| Cannot read entry script | Entry exists/case/path<=32 bytes,1..65536 source bytes; not bytecode or nested extraction folder |
| Missing init()/update(dt) | Must be global functions in entry; extra module isn't automatically loaded |
| attempt to call nil | Wrong/misspelled/invented API, blocked require/io/os, editor declarations loaded as implementation, old incompatible firmware |
| number has no integer representation | math.floor motion positions before drawing; APIs use luaL_checkinteger |
| script frame budget exceeded | Bound loops; local dirty redraws; split large loads/paints across update; no sleep/busy wait; do not increase firmware watchdog |
| not enough Lua memory | 320KiB includes VM and tables; no full-resolution Lua pixel arrays, huge data reads or per-frame table churn |
| missing/wrong image/sound/cache | Pack declared/copied, correct type/name<=23, CRC, maxslots32/cache1.5MiB/sounds512KiB; load once |
| Only top-left portion of image | blit draws frame0; check actual frame dimensions, not only full sheet dimensions |
| No sound | System volume, valid sound/mixer, play returns bool; play_file true is only queued; check exact mono WAV/rate/duration |
| Confirm lost/double-action | Consume up to4 edges; wait neutral on transitions; don't treat Down as L3; no release/held-confirm API |
| No persistent score | Same ID, <=16 keys/int32, event saves, normal pause/exit and allow flush; no save file overwritten by package |

## Optional read-only USB logs

If you already use a serial monitor, the board's USB CDC debug output is115200bps.
Select its actual port, use one monitor only, and **send no characters or commands**.
Opening a monitor can reset some USB configurations; stop writing files first.
Capture a short interval around the launch/error. Relevant log prefixes include
GAME_REJECT, GAME_START, GAME_ERROR, GAME_STOP, GAME_LOG, GAME_SAVE, GAME_ASSETS,
GAME_AUDIO and WORD_AUDIO. print emits up to4 values/80bytes each. Don't log every
frame. No serial monitor or serial dependency is required to use the SDK tools.

Do not share full device Flash/NVS, Wi-Fi passwords, personal audio or unrelated
logs. A screenshot/error text plus project files is usually enough. The public
kit does not expose internal USB maintenance/flashing as a beginner API.

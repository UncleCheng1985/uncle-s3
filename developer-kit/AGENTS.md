# AI entry point — UNCLE S3 Lua developer kit

When the user asks for a game or small app, read in this order:

1. [README.md](README.md) and [COMPATIBILITY.md](COMPATIBILITY.md).
2. [docs/RUNTIME.md](docs/RUNTIME.md): lifecycle, manifest, numbers, input, resources and saves.
3. [docs/API.md](docs/API.md): ALL 44 actual bindings, including restricted ones.
   Use [api/api.json](api/api.json) for structured signatures and
   [api/uncle.lua](api/uncle.lua) for editor annotations. Declarations are NOT runtime code.
4. [docs/WINDOWS.md](docs/WINDOWS.md), [docs/DEBUGGING.md](docs/DEBUGGING.md),
   [docs/ASSETS.md](docs/ASSETS.md), and the most relevant complete example.
5. [VALIDATION.md](VALIDATION.md): distinguish host checks from device results.

## Implementation rules

- Target only ESP32-S3 Joystick v0.2 international preview.9, Lua API 1.
- Reuse `templates/sdk-starter` via `python tools/uncle.py new projects/<unique-id>`.
  Create a new project; do not overwrite original examples or a user's existing project.
- All required code must be inside the ONE manifest entry. `require`, `load`, `dofile`,
  `io`, `os`, `debug`, `package`, coroutine, sockets, HTTP, GPIO and desktop engines
  are unavailable. No invented API, A/B/L/R, touch, analog-axis or vibration control.
- Only global `init()` and `update(dt)` are host callbacks. No draw(), keypressed(),
  love.*, onPause/onExit callbacks or main while loop. Use persistent canvas and dt.
- Use integer draw coordinates (math.floor). Keep small bounded arrays and work per
  frame; Lua has 320KiB, target updates ~24Hz, hard frame call budget120ms/120k
  instructions. Do not promise FPS, automatic asset support or automatic AI correctness.
- Input direction is already remapped for portrait; confirm is L3. POWER and VOL
  belong to the system. Drain at most four input edges per update. Startup/resume
  requires neutral input. Use a release/neutral gate between title/retry and play.
- Small interactive apps run from **Games**, not a new native home tile. Use the same
  lifecycle. Mic recording, Music MP3 control, networking, settings, charging and other
  unbound hardware/system capabilities require separate firmware work.
- Do not use `vocab.*` or the reserved hidden `beatvocab-study` ID. Documented for
  completeness only. Do not include Chinese wordlists/audio or unknown-license assets.
- Persist small scores/counters via storage.get/set on meaningful events, <=16 integer
  keys, not each frame. Keep project ID stable for updates. Never package or overwrite
  user save.dat, progress.log, NVS, credentials or recordings.
- Put every deployment file in `project.json`'s files allowlist; declare assets and
  computed file names explicitly. SDK policy is intentionally stricter than firmware
  for portability. Never treat linting or test doubles as device acceptance.

## Required delivery on every iteration

1. Briefly state what is possible in current Lua and any firmware-dependent requests.
2. Deliver full project directory with valid game.json, complete entry, project.json,
   README, LICENSE, and all required permitted resources. No absolute author-machine paths.
3. Run `python tools/uncle.py check projects/<id>`; report that syntax is unparsed unless
   `--luac` points to Lua5.4 luac. Optional Lua host tests are NOT a device simulator.
4. Run `python tools/uncle.py package projects/<id> --output dist/<id>-v1.zip`.
   Use a new output name on changes; do not overwrite an existing package.
5. Explain the safe off-device card-reader installation from docs/WINDOWS.md.
   No USB mass-storage assumption, live hot update, firmware flash or card format.
6. Report checks actually performed, what remains for device testing, and how to
   collect the exact error and iterate. Ask for one useful observation when necessary.

Existing tasks/user edits take priority over template defaults. Change only the
requested project. Publishing permissions must come from the user, not this file.

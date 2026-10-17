# Validation status — developer kit0.1.0

Scope: ESP32-S3 Joystick v0.2 international preview.9 / API1, audited2026-10-18.
This file distinguishes actual checks from pending physical-device results.

## Implementation audit

- Reviewed current binding registration and all44 C++ binding implementations,
  manifest/catalog/loader, input, rendering, audio/asset formats, saves and limits.
- Full API JSON, markdown and annotation-only declarations enumerate exactly those
  44 names, including nine reserved vocab bindings that public projects must not use.
- Source fingerprints and audited application hash: api/runtime-audit.json.
- No firmware, charging, pin map, calibration or device state modified for this kit.

## Public-kit host checks

Passed on Windows with Python3.12; tools require Python3.10+:

1. All **11 standard-library tests**: manifests/bounds, duplicate keys, blocked/
   unknown direct API calls, ID collisions, missing resources, save exclusion,
   ZIP layout/hashes/no overwrite, asset rebuild/CRC rejection, document links,
   exact44 JSON/markdown/declaration/audit names and all supplied projects.
2. All six `.lua` sources (declarations, template, three examples, host test) parsed
   successfully by a Lua5.4 host parser via Lupa's lua54 engine. Lupa is a local QA
   aid, **not an SDK runtime dependency** or bundled interpreter. The base Python
   checker still explicitly reports "syntax not parsed" unless given real luac5.4.
3. Included `tests/test_examples.lua` passed using explicit API test doubles:
   starter movement/reset, Stick Lab reset save, counter +/-/reset, Coin Dash title,
   start, all five actual movement/collision collections, win, best-score retention,
   retry and timeout. Doubles do not render/emulate native audio/caches/budgets.
4. From a **freshly extracted standalone ZIP**, read ordered AI entry documents,
   created `projects/my-first-game`, changed speed160→240/color to0xFFCC33, ran
   check/package and produced correctly rooted `Games/my-first-game/...` ZIP.
   Packaged all three complete examples too; all deployment-file hashes matched.
   Re-ran all11 tests using only that extracted kit's code/data.
5. Reviewed public content, relative links, source/ZIP inventory and license scope.
   Source fingerprints remained identical to the audited firmware; the firmware
   was not changed to make this developer kit work.

The provided commands/test doubles make the checks repeatable. These host results
do not certify real ESP32 timing,32-bit numeric equivalence, memory limits,
graphics/audio output, physical inputs, card hot-swap or deployed firmware identity.

## Device boundary

No serial device was detected on the computer during this public-kit task. The
new Starter, Coin Dash and Pocket Counter copies are **pending actual device
installation/play testing**. Stick Lab's original script had earlier v0.2 native
launch/input/pause/exit/save checks; this kit reuses that script byte-for-byte,
but those historical results do not certify all new SDK examples.

This task prepares complete card deployment archives with hashes; no device
installation or firmware flashing is claimed. The repository does not publish a
firmware binary or device backup. Use the compatible firmware already supplied
with the device; seller verification/recovery is separate if it is missing.

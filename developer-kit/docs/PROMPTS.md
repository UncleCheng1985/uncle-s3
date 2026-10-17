# Copyable AI prompts

## Create a first project

> Read this UNCLE S3 developer kit's AGENTS.md first, then COMPATIBILITY.md, docs/RUNTIME.md and docs/API.md. I want: [describe my game/app]. Explain which parts fit the real Lua API. Create a new unique project from the template under projects/, keeping original examples intact. Use only real bindings and physical stick/L3 controls; POWER/VOL remain system keys. Deliver every required file, project.json allowlist and license/source notes. Run the structural check and package tools, tell me whether Lua syntax was parsed, and give Windows card-reader installation steps. Do not change/flash firmware or claim hardware success without a device test.

## Modify a project

> Read AGENTS.md and the current API contract before editing projects/[id]. My requested change is: [change]. Inspect existing files and saves policy; keep this project's ID and storage keys unless a migration is necessary and explained. Preserve the original examples and unrelated code. Deliver complete updated runtime files and a new package name, run checks, list exact changes and results, and explain how to update only runtime files while keeping save.dat/progress.log. No running hot update, USB disk assumption or new hardware controls.

## Repair an error

> Read AGENTS.md, docs/DEBUGGING.md and the exact API reference. Board: ESP32-S3 Joystick v0.2. Firmware: [Settings/About version]. Project ID/version: [id/version]. Exact on-screen/USB error: [copy text]. Steps: [minimal reproduction]. Attached: [game.json, project.json, main.lua and resource inventory]. Diagnose against the actual runtime and supplied files; don't invent APIs or weaken firmware limits. Make the smallest complete fix, run structural/syntax/logic checks that are available, package to a new filename, and explain safe reinstall and one clear device check. Do not upload credentials, private recordings or device backups.

## Ask for an interactive application

> Read AGENTS.md and show whether my idea fits the existing Lua API: [idea]. If it does, build a small interactive app launched under Games, with clear stick/L3 actions, sensible local integer saves and a POWER exit. If it needs microphone, native Music control, Wi-Fi, GPIO or OS changes, identify that limitation instead of fabricating a method. Start with Pocket Counter if relevant and deliver the full checked/packageable project.

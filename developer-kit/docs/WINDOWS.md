# First run on Windows: download, ask AI, package, install, improve

[Kit home](../README.md) · [AI prompts](PROMPTS.md)

## 1. What you need

- UNCLE S3 **Joystick v0.2** with the [compatible international firmware](../COMPATIBILITY.md)
  already installed, matching display/stick and a working supported microSD card.
- Windows computer, a card reader, text editor, and an AI coding assistant that can
  read your chosen folder. No paid assistant/vendor or special IDE is required.
- Python3.10 or newer for project creation/check/package (standard library only).
  Check `py -3 --version` or `python --version`. If absent, install Python from
  python.org and reopen the terminal. The device does not run this Python code.
- Optional **Lua5.4 luac** for real syntax parsing and Lua5.4 interpreter for host
  example logic tests. Not required to run the supplied device examples. Use a
  trusted Lua distribution, check `luac -v` reports5.4; do not use LuaJIT or5.1/5.3.
  No interpreter binary is bundled. Base structural check explicitly says when
  syntax has NOT been checked. There is no invented simulator.

## 2. Download and extract

Use the repository's versioned developer-kit ZIP link. In Explorer choose Extract
All, open `uncle-s3-lua-kit-0.1.0`, and check **AGENTS.md, README.md, tools/** are
directly inside. Do not work inside Explorer's compressed-folder view. Open a
terminal in that folder. Commands below assume that working directory. Use
`py -3` instead of `python` throughout if that is your installed launcher.

## 3. Give your AI the whole folder

Open the extracted folder in your coding assistant/editor. Say:

> First read AGENTS.md in this UNCLE S3 developer kit. Create a simple game where I move a square and collect coins. Use only the documented APIs and deliver the full project, checks, package and installation steps. Do not modify system firmware.

The AI should read compatibility, runtime, API and template before coding. If it
cannot read local files, provide those documents and the relevant complete example
through that assistant's file workflow. Do not supply Wi-Fi credentials or backups.

## 4. Create your own project and change one thing

```powershell
python tools/uncle.py new projects/my-first-game --title "My First Game"
```

This copies the complete template, changes folder/manifest ID and title, and
refuses an existing/reserved target. Open `projects/my-first-game/main.lua`.
Change `SPEED = 160` to240, or change COLOR to0xFFCC33. Save UTF-8 without BOM.
Keep helpers inside the entry; editor declarations must not be loaded on device.

To start from the complete game instead:

```powershell
python tools/uncle.py new projects/my-coins --template examples/coin-dash --title "My Coins"
```

Original templates/examples stay intact. New IDs have independent save files.

## 5. Check and package

```powershell
python tools/uncle.py check projects/my-first-game
python tools/uncle.py package projects/my-first-game --output dist/my-first-game-v1.zip
```

Checks include manifest, ID/folder, byte limits, entry, explicit deployment allowlist,
safe paths, optional BVP/BVC/WAV formats/checksums and direct literal API/resource
references. Computed strings/aliases/actual Lua syntax/logic/time/memory cannot be
fully checked by the base tool. It is not a safety certification for arbitrary code.

If you have Lua5.4 luac, add `--luac "C:/Lua54/luac.exe"` (replace with its actual path)
to check or package. This validates syntax only, with desktop numeric/heap differences.

ZIP layout is `Games/my-first-game/...` plus `UNCLE-PACKAGE.json` with hashes. It
contains only allowlisted runtime/README/license files, not source tools or saves.
Existing ZIP names are refused; use `-v2.zip` after edits. Python never writes a card.

## 6. Safe card-reader installation

1. On the device, stop recording and wait for save completion. Stop music, exit your
   Lua game normally through POWER → Exit to home, allowing deferred saves to finish.
2. Use the normal software shutdown path. **Screen off alone is not power off.**
   Remove USB supply and ensure any battery supply is disconnected using the supported
   arrangement. Software shutdown is not a physical battery disconnect. If unsure how
   your battery is connected, ask the seller rather than pulling powered cables/FPCs.
3. Only when fully unpowered, remove microSD and put it in the computer's card reader.
   Back up your original card content. Do not format as an installation step.
4. Extract `my-first-game-v1.zip` on the computer. Copy its **Games** directory to the
   card root (merge the directory, not replace the whole card). Confirm that the final
   path is exactly `CARD:/Games/my-first-game/game.json`, not
   `CARD:/my-first-game-v1/Games/...` or `CARD:/Games/Games/...`.
5. For a new ID, stop if that exact project folder already exists; inspect/back it up.
   For an update to your same ID, replace only the package's known runtime files.
   Keep **save.dat, save.bak, progress.log, progress.bak** and any other user data.
   Never delete the target folder wholesale to update it.
6. Safely eject the card in Windows. Insert into the **unpowered** device, reconnect
   supply and boot. Games → My First Game → stick press starts it. Move to test;
   L3 resets. POWER opens pause/exit; VOL remains system volume.

There is **no USB disk drag-and-drop assumption**, no card hot-swap promise and no
running-script hot reload. Restart the project/device after the off-device file update.
Built-in developer USB commands are not the public beginner installation workflow.

## 7. Repeat with AI

Keep source in `projects/`. Describe one change, let AI read AGENTS/API again, run
check, produce a new ZIP, stop/power down and copy only changed runtime files while
preserving saves. Keep the original example and previous source/package to roll back.
Record the exact firmware version, project ID/version, error text and reproduction
steps. Use the [repair prompt](PROMPTS.md); consult [debugging](DEBUGGING.md).

## 8. Reproduce the published host checks

```powershell
python -m unittest discover -s tests -p "test_*.py" -v
```

Optional logic tests with an installed Lua5.4 interpreter, from kit root:

```powershell
lua tests/test_examples.lua .
```

Those use explicit API test doubles to verify example state changes. They do not
render the device screen, emulate native caches/audio, enforce ESP32 budgets or
prove physical button operation. See [exact validation results](../VALIDATION.md).

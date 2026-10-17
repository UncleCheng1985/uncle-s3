# UNCLE S3 Lua developer kit

**Let your AI read this kit, then describe a game or small interactive app for your real device.**

Start your AI assistant in this extracted directory and say:

> Read AGENTS.md in this developer kit first. Help me build a simple game for UNCLE S3 using only its real Lua APIs. Start from the template, check and package the complete project, then explain how to install it.

No paid AI provider or particular editor is required. Use your own coding assistant.
The assistant runs on your computer, not on the device. Generated code needs testing.

## Start here

- [Windows: download → AI → project → card → first run](docs/WINDOWS.md)
- [AI instructions](AGENTS.md) · [copyable prompts](docs/PROMPTS.md)
- [Full runtime/manifest rules](docs/RUNTIME.md) · [all 44 API functions](docs/API.md)
- [Editor declarations](api/uncle.lua) · [machine-readable contract](api/api.json)
- [Compatibility](COMPATIBILITY.md) · [validation and remaining checks](VALIDATION.md)
- [Resources and formats](docs/ASSETS.md) · [troubleshooting](docs/DEBUGGING.md)
- [License scope](LICENSE.txt) · [notices and provenance](NOTICES.md)

## Complete examples

| Project | Demonstrates | Dependency |
| --- | --- | --- |
| [Stick Lab](examples/stick-lab/README.md) | Existing minimal movement/confirm/integer save example | No external assets |
| [Coin Dash](examples/coin-dash/README.md) | Title, five-coin game, timer, scoring, game over, restart, best score, tiny sprite and sound | All generated resources included |
| [Pocket Counter](examples/pocket-counter/README.md) | Simple interactive app, stateful UI, save only on changes | No external assets |
| [Starter template](templates/sdk-starter/README.md) | Copyable project with clear editable constants | No external assets |

Small apps also launch under Games. They cannot add home tiles or call native
Recorder/Music/Wi-Fi functions through an API that does not exist.

## Quick commands

Run in this directory, using Python3.10+ (`py -3` on Windows if `python` is unavailable):

```powershell
python tools/uncle.py new projects/my-first-game --title "My First Game"
python tools/uncle.py check projects/my-first-game
python tools/uncle.py package projects/my-first-game --output dist/my-first-game-v1.zip
python -m unittest discover -s tests -p "test_*.py" -v
```

Check/package/test need Python standard library only. They do not install or flash
anything. Static checks are not a Lua parser or hardware test. Optional Lua5.4 syntax
check: add `--luac C:/path/to/luac.exe`; see docs/WINDOWS.md. Do not copy api/uncle.lua
to the card. Extract the package's **Games** directory to the card root using a card
reader while the device is fully off; preserve saves. See the full safe sequence.

Requires the compatible international firmware already on your device. No firmware
binary, device backup, desktop simulator or public firmware-source license is included.

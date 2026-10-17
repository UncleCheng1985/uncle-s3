# Modify and install a Lua game

[Back to UNCLE S3](README.md)

The kit runs a sandboxed device-specific Lua game API. The complete public
[developer kit](developer-kit/README.md) now includes **Stick Lab**, a template,
Coin Dash, Pocket Counter, all API bindings and check/package tools.
Use the [Windows first-run guide](developer-kit/docs/WINDOWS.md) for the full
download → AI → create → check → package → card-reader → iterate workflow.
Have your AI first read [developer-kit/AGENTS.md](developer-kit/AGENTS.md).

## Start with the working example

Copy the complete `stick-lab` directory to `/Games` on the card. At minimum, it contains `game.json`, `main.lua` and its license notice. Back up the card first.

The manifest uses API 1:

```json
{"id":"stick-lab","title":"Stick Lab","api":1,"orientation":"landscape","entry":"main.lua"}
```

Run Games → Stick Lab. Directions move a square; pressing the stick resets it and increments a saved counter. POWER → Exit to home leaves the game.

## Make one change

Exit the game and disconnect power before removing the card. Open `main.lua` in a text editor and find:

```lua
local SPEED = 160
local COLOR = 0x36D6A0
```

Try `SPEED = 240` or `COLOR = 0xFFCC33`. Save as UTF-8, safely eject the card from the computer, insert it into the unpowered kit and start again. No system-firmware rebuild is needed for this change.

To keep the original example, duplicate the folder as `my-square`, set its manifest `id` to `my-square` and `title` to `My Square`. Use a unique ID; do not overwrite another game's files or saves.

## APIs used by Stick Lab

| API | Purpose |
| --- | --- |
| `SCREEN_WIDTH`, `SCREEN_HEIGHT` | Logical canvas size; 960 × 376 for this landscape example. |
| `gfx.clear(rgb)` | Fill the canvas. |
| `gfx.rect(x,y,w,h,rgb)` | Draw a filled rectangle. |
| `gfx.text_medium(text,x,y,rgb)` | Draw text with the built-in medium font. |
| `input.direction()` | Current direction or nil when neutral. |
| `input.pressed()` | Consume one queued input edge, including `confirm` for the stick press. |
| `storage.get(key,default)` | Read an integer saved for this game. |
| `storage.set(key,value)` | Queue an integer save. |
| `system.exit()` | Request an exit to the game list. |

`init()` runs on startup and `update(dt)` runs repeatedly. `dt` is elapsed seconds, bounded by the runtime. Avoid busy loops and large allocations each frame. POWER and volume remain system controls.

Save changes on meaningful events. The existing store has a bounded 16-key integer budget, and writes are deferred; sudden power removal is not guaranteed to preserve pending data. Desktop filesystem/network Lua modules are not available.

AI coding tools can help edit a script on your computer, but the result still needs review and device testing. There is no onboard large language model or guarantee that generated code runs unchanged.

The example's adjacent license covers that example only. It does not grant rights to the firmware, fonts, downloaded music or other games/artwork.

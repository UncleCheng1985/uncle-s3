-- SPDX-License-Identifier: MIT
-- A tiny interactive app using the same Games launcher and Lua lifecycle.
local count, dirty = 0, true
local function draw()
  gfx.clear(0x182032)
  gfx.text_medium("Pocket Counter", 24, 24, 0xFFFFFF)
  gfx.text_big(tostring(count), 48, 116, 0x36D6A0)
  gfx.text_medium("Right/Up: +1 | Left/Down: -1", 24, 234, 0xFFFFFF)
  gfx.text_medium("Press: reset | POWER: menu / exit", 24, 284, 0xB8C4D9)
  dirty = false
end
function init()
  count = math.max(0, math.min(999999, storage.get("count", 0)))
  draw(); print("COUNTER_READY", count)
end
function update(dt)
  local before = count
  for _ = 1, 4 do
    local key = input.pressed()
    if not key then break end
    if key == "right" or key == "up" then count = math.min(999999, count + 1) end
    if key == "left" or key == "down" then count = math.max(0, count - 1) end
    if key == "confirm" then count = 0 end
  end
  if count ~= before then
    storage.set("count", count) -- event only; normal pause/exit flushes pending state.
    dirty = true; print("COUNTER_CHANGED", count)
  end
  if dirty then draw() end
end

-- SPDX-License-Identifier: MIT
-- Project-authored example: no external image, font or audio assets.
local SPEED = 160 -- pixels per second: try 240
local COLOR = 0x36D6A0 -- change the square color
local x, y, score = 460, 176, 0
local previous = ""
function init()
  score = storage.get("resets", 0)
end
function update(dt)
  local direction = input.direction()
  -- Holding the stick moves continuously; the same API also exposes edges.
  if direction == "left" then x = x - SPEED * dt end
  if direction == "right" then x = x + SPEED * dt end
  if direction == "up" then y = y - SPEED * dt end
  if direction == "down" then y = y + SPEED * dt end
  local key = input.pressed()
  -- L3 is a distinct press edge; directions never trigger confirmation.
  if key == "confirm" then
    x,y = 460,176
    score = score + 1
    storage.set("resets", score) -- event only, never written each frame
  end
  x = math.max(20, math.min(SCREEN_WIDTH - 52, x))
  y = math.max(80, math.min(SCREEN_HEIGHT - 65, y))
  gfx.clear(0x17152B)
  gfx.text_medium("Stick Lab", 24, 18, 0xFFFFFF)
  gfx.text_utf8("Move: stick | Press: reset | POWER: menu",24,52,0xB8C4D9)
  gfx.rect(math.floor(x),math.floor(y),32,32,COLOR)
  gfx.text_utf8("Resets: " .. score,24,340,0xFFFFFF)
end

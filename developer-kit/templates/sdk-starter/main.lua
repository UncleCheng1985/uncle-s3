-- SPDX-License-Identifier: MIT
-- EDIT THESE: speed in pixels/second and RGB colors. Keep helpers in this file.
local SPEED, COLOR, BG = 160, 0x36D6A0, 0x17152B
local x, y = 460, 176
function init()
  gfx.clear(BG)
  gfx.text_medium("My first UNCLE S3 project", 24, 18, 0xFFFFFF)
  gfx.text_utf8("Move: stick | Press: reset | POWER: menu", 24, 54, 0xB8C4D9)
  gfx.rect(x, y, 32, 32, COLOR)
  print("STARTER_READY", GAME_API_VERSION)
end
function update(dt)
  local old_x, old_y = math.floor(x), math.floor(y)
  local held = input.direction()
  if held == "left" then x = x - SPEED * dt end
  if held == "right" then x = x + SPEED * dt end
  if held == "up" then y = y - SPEED * dt end
  if held == "down" then y = y + SPEED * dt end
  for _ = 1, 4 do
    local key = input.pressed()
    if not key then break end
    if key == "confirm" then x, y = 460, 176 end
  end
  x = math.max(24, math.min(SCREEN_WIDTH - 56, x))
  y = math.max(94, math.min(SCREEN_HEIGHT - 56, y))
  local px, py = math.floor(x), math.floor(y)
  if px ~= old_x or py ~= old_y then
    gfx.rect(old_x, old_y, 32, 32, BG)
    gfx.rect(px, py, 32, 32, COLOR)
  end
end

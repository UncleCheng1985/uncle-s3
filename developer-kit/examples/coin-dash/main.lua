-- SPDX-License-Identifier: MIT
-- EDIT: speed, duration, colors and coin positions. All coordinates are logical pixels.
local SPEED, DURATION = 240, 18
local BG, FG, GREEN = 0x111827, 0xFFFFFF, 0x36D6A0
local points = {{180,170},{360,170},{540,170},{720,170},{840,250}}
local scene, ready, x, y, score, remaining, shown_seconds = "title", false, 48, 170, 0, DURATION, DURATION
local best, coin, sound = 0, nil, nil

local function label(text, px, py, color)
  gfx.text_medium(text, px, py, color or FG)
end

local function hud()
  gfx.rect(0, 0, SCREEN_WIDTH, 76, BG)
  label("Coin Dash", 24, 18)
  label("Coins: " .. score .. "/5", 340, 18)
  label("Time: " .. math.ceil(remaining), 660, 18)
end

local function target()
  if score < #points then
    local p = points[score + 1]
    gfx.blit(coin, p[1], p[2])
  end
end

local function finish(won)
  scene, ready = "over", false
  if score > best then best = score; storage.set("best", best) end
  audio.stop_all()
  gfx.clear(BG)
  label(won and "ALL FIVE COLLECTED" or "TIME UP", 260, 92)
  label("Score: " .. score .. "   Best: " .. best, 280, 152)
  label("Press to retry | POWER: exit", 260, 224)
  print("COIN_OVER", score, won)
end

local function start()
  scene, ready, x, y, score, remaining = "play", false, 48, 170, 0, DURATION
  shown_seconds = DURATION
  gfx.clear(BG); hud(); target(); gfx.rect(x, y, 24, 24, GREEN)
  print("COIN_PLAY")
end

function init()
  best = storage.get("best", 0)
  coin = asset.image("coin")
  sound = asset.sound("collect")
  gfx.clear(BG)
  label("COIN DASH", 340, 78)
  label("Move the green square. Collect five gold coins.", 160, 136)
  label("18 seconds | Press to start | POWER: exit", 180, 204)
  print("COIN_TITLE")
end

function update(dt)
  local key, held = nil, input.direction()
  for _ = 1, 4 do
    local edge = input.pressed()
    if not edge then break end
    if edge == "confirm" then key = edge end
  end
  -- A neutral update after each transition consumes the startup/retry press.
  if not ready then
    if held == nil and key == nil then ready = true end
    return
  end
  if scene == "title" or scene == "over" then
    if key == "confirm" then start() end
    return
  end
  local old_x, old_y = math.floor(x), math.floor(y)
  if held == "left" then x = x - SPEED * dt end
  if held == "right" then x = x + SPEED * dt end
  if held == "up" then y = y - SPEED * dt end
  if held == "down" then y = y + SPEED * dt end
  x = math.max(24, math.min(SCREEN_WIDTH - 48, x))
  y = math.max(94, math.min(SCREEN_HEIGHT - 58, y))
  local px, py = math.floor(x), math.floor(y)
  if px ~= old_x or py ~= old_y then gfx.rect(old_x, old_y, 24, 24, BG) end
  local p = points[score + 1]
  if px < p[1] + 16 and px + 24 > p[1] and py < p[2] + 16 and py + 24 > p[2] then
    gfx.rect(p[1], p[2], 16, 16, BG)
    score = score + 1
    audio.play(sound, 40) -- false means mixer unavailable; game remains playable.
    if score == #points then finish(true); return end
    hud(); target()
  else
    target() -- repair coin pixels if the player's old rectangle overlapped them.
  end
  gfx.rect(px, py, 24, 24, GREEN)
  remaining = math.max(0, remaining - dt)
  if math.ceil(remaining) ~= shown_seconds then
    shown_seconds = math.ceil(remaining); hud()
  end
  if remaining <= 0 then finish(false) end
end

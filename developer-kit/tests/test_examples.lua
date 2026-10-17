-- SPDX-License-Identifier: MIT
-- Plain Lua5.4 host logic checks using explicit test doubles, NOT an emulator.
local root = arg[1] or "."
local function project(folder)
  local state = {held=nil, edges={}, saved={}, logs={}, rects={}, sounds=0}
  local env = {SCREEN_WIDTH=960, SCREEN_HEIGHT=376, GAME_API_VERSION=1,
    math=math, string=string, table=table, utf8=utf8, pairs=pairs, ipairs=ipairs,
    tonumber=tonumber, tostring=tostring, type=type, assert=assert, error=error}
  local function integer(n) assert(type(n)=="number" and n%1==0, "noninteger draw coordinate") end
  env.gfx = {clear=function(c) integer(c) end,
    rect=function(x,y,w,h,c) integer(x);integer(y);integer(w);integer(h);integer(c);state.rects[#state.rects+1]={x,y,w,h,c} end,
    text_utf8=function(t,x,y,c) assert(#t<=192);integer(x);integer(y) end,
    text_medium=function(t,x,y,c) assert(#t<=192);integer(x);integer(y) end,
    text_big=function(t,x,y,c) assert(#t<=96);integer(x);integer(y) end,
    blit=function(handle,x,y) assert(handle==257);integer(x);integer(y) end}
  env.input={direction=function() return state.held end,
    pressed=function() return table.remove(state.edges,1) end}
  env.storage={get=function(k,d) return state.saved[k] or d or 0 end,
    set=function(k,v) assert(type(v)=="number" and v%1==0);state.saved[k]=v end}
  env.asset={image=function(name) assert(name=="coin");return 257 end,
    sound=function(name) assert(name=="collect");return 258 end}
  env.audio={play=function(handle,v) assert(handle==258 and v>=0 and v<=100);state.sounds=state.sounds+1;return true end,
    stop_all=function() end}
  env.print=function(...) local v={...};for i=1,#v do v[i]=tostring(v[i]) end;state.logs[#state.logs+1]=table.concat(v," ") end
  local fn=assert(loadfile(root.."/"..folder.."/main.lua","t",env));fn();env.init()
  function state.step(held,edge,dt) state.held=held;state.edges=edge and {edge} or {};env.update(dt or .05) end
  function state.has(token) for _,line in ipairs(state.logs) do if line:find(token,1,true) then return true end end return false end
  return state
end
local starter=project("templates/sdk-starter")
starter.step("right");local r=starter.rects[#starter.rects];assert(r[1]==468 and r[2]==176)
starter.step(nil,"confirm");r=starter.rects[#starter.rects];assert(r[1]==460)
local stick=project("examples/stick-lab");stick.step(nil,"confirm");assert(stick.saved.resets==1)
local counter=project("examples/pocket-counter");counter.step(nil,"right");counter.step(nil,"up");assert(counter.saved.count==2)
counter.step(nil,"left");assert(counter.saved.count==1);counter.step(nil,"confirm");assert(counter.saved.count==0)
local coin=project("examples/coin-dash");assert(coin.has("COIN_TITLE"))
coin.step(nil);coin.step(nil,"confirm");assert(coin.has("COIN_PLAY"));coin.step(nil)
for _=1,65 do coin.step("right") end
for _=1,6 do coin.step("down") end
assert(coin.has("COIN_OVER 5 true") and coin.saved.best==5 and coin.sounds==5)
coin.step(nil);coin.step(nil,"confirm");coin.step(nil)
for _=1,181 do coin.step(nil,nil,.1) end
assert(coin.has("COIN_OVER 0 false") and coin.saved.best==5)
print("PASS: starter move/reset; Stick Lab reset save; counter increment/decrement/reset; Coin Dash title/start/collect-five/win/retry/time-up/best")

-- tests/test_varyY_ranges.lua
-- Validates varyY() output stays within [-ymax, +ymax] for in-rim points
-- and remains unchanged when r >= Rim. Uses deterministic RNG for repeatability.

package.path = "./extensions/yvary/ui/addons/yvary/lua/?.lua;" .. package.path
local mod = assert(require("yvary"), "require('yvary') failed")

-- deterministic test RNG
math.randomseed(0xC0FFEE) -- hex literal is fine in Lua 5.3+

local function randf(a, b)
  return a + (b - a) * math.random()
end

local function assertf(cond, ...)
  if not cond then error(string.format(...), 2) end
end

local function run_sector_case(case_id)
  -- Randomize sector center and radius (no underscores in numbers)
  local cx = randf(-50000, 50000)
  local cz = randf(-50000, 50000)
  local R  = randf(5000, 120000)          -- base sector "radius" in plane
  local margin = 0.02
  local Rim = R * (1 + margin)
  local save_seed = math.floor(randf(1, 2147483647)) -- 2^31-1

  -- 10 points per sector
  for i=1,10 do
    -- 80%: inside R; 20%: slightly beyond Rim (should be unchanged)
    local beyond = (math.random() < 0.2)
    local rmin, rmax
    if beyond then
      rmin, rmax = Rim, Rim * 1.2
    else
      rmin, rmax = 0, R * 0.99
    end

    local theta = randf(0, 2*math.pi)
    local r     = randf(rmin, rmax)
    local x     = cx + r * math.cos(theta)
    local z     = cz + r * math.sin(theta)
    local y     = randf(-1000, 1000)      -- irrelevant when absolute=true

    local obj_key = math.floor(randf(1, 2147483647))
    local x2,y2,z2 = mod.varyY(x,y,z, cx,cz, R, save_seed, obj_key, { absolute = true, margin = margin, q = 0.1 })

    -- Basic numeric checks (not NaN/inf)
    assertf(x2 == x2 and y2 == y2 and z2 == z2, "NaN detected (case %d point %d)", case_id, i)

    -- Compute expected ymax at (x,z)
    local dx, dz = x - cx, z - cz
    local r_here = math.sqrt(dx*dx + dz*dz)
    local d = Rim*Rim - r_here*r_here
    if d < 0 then d = 0 end
    local ymax = math.sqrt(d)

    if r_here >= Rim - 1e-6 then
      -- Outside/at rim: function should return original pos unchanged (early exit)
      assertf(x2 == x and z2 == z and y2 == y, "Expected unchanged pos at/over rim (case %d point %d)", case_id, i)
    else
      -- Inside rim: |y2| must be <= ymax (+ tiny epsilon)
      local eps = 1e-6
      assertf(math.abs(y2) <= ymax + eps, "y2 out of range: |%.6f| > ymax=%.6f (case %d point %d)", y2, ymax, case_id, i)
      -- X/Z should remain identical to input
      assertf(x2 == x and z2 == z, "x/z changed unexpectedly (case %d point %d)", case_id, i)
    end
  end
end

-- Run 5 randomized sectors (with independent seeds)
for s=1,5 do
  run_sector_case(s)
end

print("[OK] test_varyY_ranges.lua")

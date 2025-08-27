-- tests/test_artifacts.lua
-- Sanity checks that the mod artifacts exist and the Lua module exposes varyY()

local function assertf(cond, ...)
  if not cond then error(string.format(...), 2) end
end

-- Assume tests are run from repo root; extend package.path to find the module.
package.path = "./extensions/yvary/ui/addons/yvary/lua/?.lua;" .. package.path

-- File existence checks
local function file_exists(path)
  local f = io.open(path, "r")
  if f then f:close(); return true end
  return false
end

local required = {
  "extensions/yvary/content.xml",
  "extensions/yvary/md/lib.yvary.xml",
  "extensions/yvary/ui/addons/yvary/lua/yvary.lua",
}

for _, p in ipairs(required) do
  assertf(file_exists(p), "Missing required file: %s", p)
end

-- Load the module
local ok, mod = pcall(require, "yvary")
assertf(ok, "require('yvary') failed: %s", tostring(mod))
assertf(type(mod) == "table", "Module did not return a table")
assertf(type(mod.varyY) == "function", "Module does not expose varyY()")

-- Minimal smoke call
local x,y,z = 0,0,0
local cx,cz = 0,0
local R = 1000
local save_seed = 123456789
local obj_key   = 42
local x2,y2,z2 = mod.varyY(x,y,z, cx,cz, R, save_seed, obj_key, { absolute = true, margin = 0.02, q = 0.1 })
assertf(type(x2)=="number" and type(y2)=="number" and type(z2)=="number", "varyY did not return numeric triplet")

print("[OK] test_artifacts.lua")

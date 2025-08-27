-- Higher Dimensional Space — core mapper (no global RNG usage)

local HDS_YVARY = {}

local function fract(x) return x - math.floor(x) end
local function rand01_hash(a, b, c)
  -- Stateless pseudo-random in [0,1), deterministic per (a,b,c)
  return fract(math.sin(a*12.9898 + b*78.233 + c*37.719) * 43758.5453)
end

-- varyY:
--   x,y,z        : world pos
--   cx,cz        : sector center in XZ plane
--   R            : sector plane radius (hypot(Rx,Rz))
--   save_seed    : integer-ish (game/save seed you read from save or config)
--   obj_key      : stable integer-ish per object (macro+owner hash etc.)
--   opts         : { absolute=true, margin=0.02, q=0.1 }
function HDS_YVARY.varyY(x,y,z, cx,cz, R, save_seed, obj_key, opts)
  opts = opts or {}
  local absolute = (opts.absolute ~= false)
  local margin   = opts.margin or 0.02
  local q        = opts.q or 0.1

  local dx, dz = x - cx, z - cz
  local r = math.sqrt(dx*dx + dz*dz)
  local Rim = R * (1 + margin)
  if r >= Rim then return x,y,z end

  local ymax = math.sqrt(Rim*Rim - r*r) -- sphere cap at this (x,z)
  local rho  = r / Rim                  -- 0 at center → 1 at rim
  local amp  = ymax * (1 - rho)         -- linear falloff; simple & smooth

  -- Quantize x/z so tiny edits don’t reshuffle randomness
  local kx = math.floor(x * q)
  local kz = math.floor(z * q)
  local s  = (save_seed or 0) + (obj_key or 0) * 0.61803398875

  -- Three independent uniforms
  local u1 = rand01_hash(kx,     kz,     s)
  local u2 = rand01_hash(kx+17,  kz-11,  s+29)
  local u3 = rand01_hash(kx-7,   kz+23,  s-41)

  -- Bias toward plane via product of uniforms (steeper near 0)
  local yabs = amp * (u1 * u2)
  local sign = (u3 < 0.5) and -1 or 1
  local newy = sign * yabs

  if absolute then
    return x, newy, z
  else
    if newy > 0 then
      return x, math.min(y + newy,  ymax), z
    else
      return x, math.max(y + newy, -ymax), z
    end
  end
end

return HDS_YVARY

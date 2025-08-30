# Higher Dimensional Space

**Version:** 0.1.0 **[BETA]** · **Author:** Reithan

Make X4's universe actually feel 3D. This mod **sphericalizes** GOD-driven placements at game start and during AI-driven builds by replacing vanilla “flat/polar” randomization with a **sector-centered spherical (or configurable ellipsoidal) distribution**.

---

## ✨ What it does

- **Gamestart spawns (GOD):** Listens to `event_god_created_factory` and `event_god_created_station` and repositions eligible creations using a Y‑up sphere/ellipsoid around the sector core. Uses safe placement (`<safepos includeplotbox="true">`).
- **AI economy & goals:** Patches vanilla MD (economy/goal/station finders) to use a **rand-in-sphere** helper instead of the stock polar RNG for many flows (build-in-sector, faction goals, core fallbacks).  
- **Respects mods/updates:** Classification is based on **runtime object props** (`isgodproductionentry`, `godentry`, `zone`, `position`), not hardcoded ID lists.
- **Configurable shape:** The helper library supports **radius** (`R`) and **vertical squash** (`squash`) so you can go from perfect spheres to gentle ellipsoids.

> Result: fewer “pancake layers”, more **vertical variety** for NPC construction while keeping vanilla logic intact.

---

## ⚙️ Configuration

Most tuning is done via **parameters** passed to the `HDS_RNG_Sphere_RandPoint` library:

- `center` (position): sector core (default in patches) or any point
- `R` (length): sphere radius — typically `SectorCoreSize` or `min(SectorCoreSize, 600km)`
- `squash` (float): `1.0 =` true sphere; `0.6` (default in many patches) = gentle vertical squash

To change defaults:
- Edit the `run_actions` calls in the patched MD files (e.g., `factionlogic_economy.xml`, `factiongoal_*`), or
- Wrap with your own MD that **diff-replaces** those params.

The standalone script `sphericalize_god_stations.xml` also contains a **vertical‑only lift** path if you prefer to keep vanilla X/Z and add Y variety.

---

## 🧰 Technical notes

- **Safe placement:** All moves use `<safepos includeplotbox="true">` to avoid plot boxes and collisions.  
- **Events:** `event_god_created_factory` / `event_god_created_station` gated by `isgamestartgodentry`.  
- **Classification:** Dynamic (factories) via `isgodproductionentry`; others inferred from runtime zone/position **without reading `god.xml`**.  
- **Operator tip:** MD supports exponent `^` per the current wiki. Using `sqrt()` and `a*a` for squared terms is also fine.

---

## ✅ Compatibility

This mod **diff‑patches** several vanilla MD libraries. It should co‑exist with mods that don’t touch the same `<library>` sections. It has been tested with a moderate variety of the most popular mods already, such as VRO. Potential conflicts if another mod also patches:

- `md/factionlogic_economy.xml`
- `md/factionlogic_stations.xml`
- `md/factiongoal_hold_space.xml`
- `md/factiongoal_invade_space.xml`
- `md/khaak_activity.xml`

---

## 🧪 Troubleshooting

- Enable the MD debug log and look for lines prefixed with `[HDS]` to verify event listeners and warps.
- To exclude specific entries/sectors, add small filters by `godentrytags`/macro in the listener (examples commented in code).

---

## 🖼️ Icon

An icon image (`hds_icon.png`) is provided in this download; you can also place it in the extension root as `icon.png` for Steam.

## 📜 License

© Reithan 2025. treat as “all rights reserved” except where Egosoft mod distribution allowances apply.

---

## ✍️ Changelog

- 0.1.0 — Initial beta release.

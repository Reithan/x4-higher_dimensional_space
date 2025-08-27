Here’s a lean, risk-down plan that stubs early, proves the hard parts first, then layers features.

1. Create a repo for the mod on GitHub
2. Scaffold the X4 extension: `extensions/yvar/` with `content.xml`, `md/` + `ui/` folders, CHANGELOG, LICENSE, CI draft
3. Add core library (`md/lib.yvary.xml`): stateless hash→rand mapper (`varyY()`), clamps, tunables (margin, absolute/nudge, quantization Q)
4. Add dev harness: cheat MD that spawns N test markers across (x,z), applies `varyY`, logs before/after; CSV debug export toggle
5. High-risk POC: intercept the placement flow **before** AI site scoring (wrapper/override on candidate generation); for now **log only** and return vanilla candidates to confirm hook stability
6. Implement apply-path #1 (new placements only): call `varyY()` on candidates, then forward to scoring; feature flag: `mode=preview|new_only|all` (default preview)
7. Filters v1: include NPC stations/plots; exclude gates/accelerators/highways/beacons/hazards/mission set-pieces/player assets; support macro/faction blacklist + `<tag name="no_y_vary"/>` opt-out
8. Determinism checks: same save seed/object key → identical results across reloads; sector-rim clamp tests; extreme sector sizes
9. Visualization: lightweight debug UI (Lua) showing ρ, amp, ymax for hovered candidate; toggle to draw vertical span at cursor
10. Settings UI: margin slider, absolute vs nudge, Q (coarse x/z), preview density, logging on/off
11. Apply-path #2 (runtime placements): extend hook to any NPC-initiated station/plot placement during play; add per-class enable switches
12. Compatibility layer: expose `varyY()` as a callable library for other mods; respect their opt-outs; verify load order; smoke-test with VRO/Reactive Docking (no edits to travel infra)
13. Safety & failure modes: hard guardrails (never move excluded classes), sector OOB checks, fallback to vanilla if any calc returns NaN/inf
14. Performance pass: micro-bench the hook under mass-spawn; ensure O(1) per candidate; trim logs in release mode
15. QA matrix: new-game starts in multiple factions; late-game saves; small/large sectors; confirm AI uses **transformed** candidates (placement quality unchanged)
16. Docs: README (what it moves/doesn’t), config reference, compatibility notes, troubleshooting, before/after screenshots, API snippet for modders
17. Versioning & packaging: bump v0.1.0, strip debug logs in release, pack extension zip, checksum
18. Closed beta: share build to a few testers; gather reports; adjust filters/tunables; finalize defaults (`mode=new_only`, absolute on)
19. Public release prep: Steam assets (icon, screenshots, short/long descriptions, tags), change notes, support link
    X) Publish the mod to Steam Workshop

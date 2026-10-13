# Squishy World — Production Roadmap (no disposable artwork)

## Basic rule
Small **finished permanent region** before a huge incomplete map. Technical R&D may be experimental on a feature branch; visible production art is held to release-level criteria. All stages have explicit visual + browser gates, not just passing scripts.

## Stage 0: creative lock and architecture
Approve Jelly Fantasy Art Bible, character reference, source asset format, orthographic camera, WebGL2-compatible material language. **Done on paper, browser feasibility pending.**

## Stage 1: final-intent hero Squishy
Design, sculpt and rig an original character in Blender. Integrate .glb with spring physics: movement, bounce, poke, drag and release; linked facial rig. **Gate:** high-quality at gameplay camera scale in Chrome; real tactile response; source/editability intact.

## Stage 2: production material + scene standards
WebGL2-safe soft-gel, sculpted terrain, organic flora, lagoon water, warm key light, shadow strategy, particle budget and camera. **Gate:** in-browser screenshots as convincing as approved concepts without unsupported effects.

## Stage 3: permanent Jelly Hollow
Build sculpted region: Prism Lagoon, Jelly Canopy, Softstone Arch, high-quality reusable plants/rocks, routes, three encounter clearings and one secret. **Gate:** no visible primitive placeholders; coherent authored quality across the complete first region.

## Stage 4: one-time overworld migration
Replace old `Node2D` overworld with tested `Node3D`, `CharacterBody3D` and 3D NPCs. Existing 2D Launcher/Merge, math generators, encounter signals, practice mode, grades and browser collection saves are retained. **Gate:** full encounter→win→recruit→save replayed on new terrain.

## Stage 5: polish & acceptance
Benchmark browser FPS and load time on actual PC; tune mesh complexity/materials; check collisions and occlusion, 100 drag interactions, replay mode, tab recovery, keyboard input. Aim for smooth ~60 FPS on agreed target hardware with scalable quality modes if required. **Not guaranteed until measured.**

## GitHub governance
Maintain the verified playable v0.3 on `main`; develop production art/3D engine under `feature/premium-3d-world` and stage previews. No direct destructive overwrite. Merge only after design + physics + web quality pass.

**First implementation ticket PREMIUM-001:** cloud Blender export and Godot WebGL2 material/rig validation; initial **user-visible** character render must already be a serious production-quality candidate, not a smiling colored sphere.

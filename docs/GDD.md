# Squishy World — Game Design Document v1.0

**Approved production direction 2026-10-13:** Jelly Fantasy, cartoon-premium tactile Squishies, Blender-authored **real 3D overworld with orthographic camera** and 2.5D-style gameplay. The Node2D/primitive landscape described later is a legacy v0.3 prototype, not final art. See production docs under docs/PREMIUM_*.md and docs/BLENDER_GODOT_CHARACTER_PIPELINE_V1.md.

## Game loop
Create a Squishy profile → roam colorful overworld → encounter wild Squishies → win a playful mathematical minigame → recruit a Squishy → update collection → keep exploring.

## Gameplay pillars
1. Soft, expressive, bouncy, immediately cute.
2. Explore a map rather than answer worksheets.
3. Real aiming/reflex/physics/puzzle skill as well as mathematics.
4. Collect five distinct wild Squishies in initial vertical slice.
5. Positive feedback, no penalties for mistakes, no manipulative streaks.

## Initial world
Jelly Meadow / Želé lúka, one seamless ~2048×1536 world, camera following player. Paths, pond, trees, rocks, flowers, five different creatures and future encounter hotspots. WASD/arrow keys on desktop browser.

## Initial minigames (later milestones)
**Jelly Merge:** physics-based falling blobs with number combinations, target-matching and chain reactions.
**Squishy Launcher:** aim and launch a squishy, math decisions confer bonuses/targets, skill determines trajectory.
Both must work at multiple math grade presets, with math and motor difficulty adjustable independently.

## Mathematics
Grades 1–4 as starting presets, based on the 2023 Slovak curricular standard and the gradual 2026 implementation. Skills separately indexed by concept and curriculum cycle. Problems are deterministically seeded, algorithmically validated, never solved through live AI requests.

## Saving
Multiple optional local child profiles, no login, no identifying details. IndexedDB/Userdata browser persistence with fallback and clear warning on unavailable storage.

## Assets
Use original artwork, procedural drawing or correctly licensed CC0/MIT sources. No copying recognizable characters, levels or graphics from commercial games.

## Current milestone
Exploration-only playable browser smoke test: movement, procedural pastel backdrop, five ambient creatures, visible HUD, basic collision. **No recruiting, collection, math quizzes, or minigames yet.**

See the development roadmap in docs/PROTOTYPE_PLAN.md.

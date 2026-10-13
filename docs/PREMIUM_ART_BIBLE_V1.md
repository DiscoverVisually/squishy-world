# Squishy World — Premium Art Bible v1.0

**Approved and locked 2026-10-13:** Visual direction **Jelly Fantasy**; Squishy tactile feel **cartoon-premium 2**; production workflow **Blender → glTF → Godot WebGL2**. The user explicitly requires **final-intent artwork from the first authored landscape**, not repeat throwaway scenery.

## Creative DNA

A sophisticated soft fantasy game, not a toddler cartoon: believable tactile jelly, bioluminescent flora, sculpted organic terrain, distinctive fungus canopies, refined materials and cinematic-but-playable lighting. The visual impression should be a premium indie game with original character design and readable gameplay at normal 1280×720 camera scale.

Do not produce final-content backgrounds from coloured discs, procedural primitive trees, toy-store rainbow patterns, generic low-poly packs, random scattering, plastic-like chrome, excessive neon bloom or unoptimized transparency.

**Starter palette:** deep lagoon `#267D83`; jade mint `#86D5B7`; velvet lilac `#9E84CE`; peach coral `#F1A78E`; warm cream `#F4E9D1`; midnight teal `#1F4056`; honey gold `#EFC87A`. Variations remain part of a unified material language. Rich muted mids, selective saturated focal accents.

## World and gameplay camera

The environment will be true authored 3D, projected via orthographic fixed-angle camera: design start yaw ~40–45°, downward pitch ~35–45°; to be validated in play. 2.5D/top-down controls remain. Walkable ground has organic elevation, soft ramps, sculpted transitions, visually legible routes, unobstructed encounter spaces. Camera framing, material response, NPC scale and props must look final quality on real browser screenshots.

## First permanent region: Jelly Hollow / Želé údolie

This is the first **permanent production-quality region**, not a replaceable greybox:
- **Prism Lagoon:** recognisable turquoise gel lake, sculpted shore, artisanal soft ripples and glints; no SSR dependency.
- **Jelly Canopy:** unique towering fungus-tree with flowing jelly cap, layered branch silhouette, responsive hanging tendrils.
- **Softstone Arch:** organic dark teal mineral landmark, integrated crystals, hidden collectible nook.
- Three uncluttered gameplay clearings, winding ivory routes, small ascent/lookout, one bounce prop, moss/mineral banks, carefully staged flora and lighting.
- Reusable original environment asset families: terrain chunks, 3 sculptural tree/fungus types, 4 groundcover variants, 3 jelly flora groups, organic rocks, path kit, lagoon shoreline modules. Re-use bespoke families, not primitive reskins.

## Material and lighting rules

Squishies look like soft massive gel with **simulated translucent depth**, gentle edge light, art-directed specular and coherent face deform. Mostly opaque shaders with selective alpha, because WebGL2 overdraw and refraction are costly. Flora has translucent-looking caps and subtle luminous veins. Rocks and paths are matte, textural, substantially weighted. Lagoon has stylized ripples without screen-space refraction. Warm key light and cool ambient, intentional shadow silhouettes, limited particles and varied wind movement.

Author the source material in Blender, but validate **Godot Compatibility WebGL2 rendering**. Blender Cycles cannot be the only proof of quality: expensive procedural nodes do not automatically survive glTF.

## Non-negotiable acceptance

1. Lock concept and normal camera view for character and environment before broad production.
2. Test final-intent gel and foliage/terrain materials in browser.
3. Build original high-quality rigged Squishy (poke, stretch, release, land, happy wobble).
4. Finish Jelly Hollow without user-visible placeholders and capture convincing in-game screenshots.
5. Maintain existing Launcher, Jelly Merge, grades, profile/data persistence and the complete capture flow.
6. Measure FPS, memory and loading on a representative Chrome/Edge workstation; target smooth 60 FPS where possible, not assumed.

Iterating polish is expected. Replacing the entire environment style, camera architecture or asset pipeline later is what we must prevent.

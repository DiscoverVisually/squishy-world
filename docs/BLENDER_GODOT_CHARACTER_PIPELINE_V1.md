# Squishy World — Hero Squishy, Blender and Physics v1.0

**Committed design:** final world in 3D Godot with elevated orthographic camera, player authored in Blender, runtime glTF 2.0 `.glb`, cloud export and testing. No installation of Blender or Godot on the user workstation.

## Character structure
```
SquishyCharacter (CharacterBody3D)
├── CollisionShape3D (stable simplified collider)
├── VisualPivot
│   └── hero_squishy.glb (Skeleton3D, MeshInstance3D, AnimationPlayer)
├── DragTarget
├── SquishyMotor (walk, impacts, bounce)
├── JellyDeformer (spring-driven rig motion)
└── FaceController (eyes, blink and mouth)
```
Player is 3D, with motion on X/Z; Godot Y is up. Existing 2D math minigames stay standalone and are displayed as CanvasLayer/SubViewport as needed; do not rewrite their internal physics/math logic. Save data and Squishy names remain compatible.

## Blender production contract

A distinctive asymmetric watertight gel mesh with 6–10 deformation bones/control points (revise through performance profiling). Shape key targets initially: `Squash`, `StretchUp`, `StretchLeft`, `StretchRight`, `Impact`, `PokeFront`, `Happy`, plus face/eye expressions. Correct scale and pivot. Face attachments must move coherently with every body stretch; preserve eye target and pupil. Export deforming bones only where blend shapes require it, using official Blender→glTF workflow. Texture/materials baked or reconstructed in Godot as compatible art-directed PBR with soft translucency illusion.

Editable master `art/source/characters/hero_squishy.blend`; runtime `game/assets/characters/hero_squishy.glb`; turnaround renders, animation and material manifest. Preserve source provenance and asset naming; heavy source files may need Git LFS or external versioned storage.

## Genuine spring-driven tactile play

**Not a canned squash animation.** Implement fixed-timestep spring/damper simulation driving local bones and morph targets: acceleration for a control coordinate = `(−k*(x−rest)−c*velocity+force)/mass`, with damping and maximum extension constraints. This is actual physically responsive rig behavior but **not general volumetric soft-body/FEM physics**. Collision stays stable and inexpensive; visible skin can squash/drag independently.

Acceptance interactions:
- Walk acceleration yields trailing jelly mass and settling on stopping.
- Bounce/landing compresses and bulges radially, then rebounds with damping.
- Mouse click raycasts the gel mesh for a playful poke/local indentation.
- Mouse drag holds and stretches a selected region; release springs back and wobbles.
- Strong diagonal dragging does not tear topology, detach eyes or clip across scene.
- Idle expression and blinks work at actual game distance; feedback is cute, not baby-like.
- Test 100 consecutive drags, long locomotion, state changes, collisions, browser tab switching and reloading.

## Web constraints and cloud pipeline

Godot 4.7.2, GDScript, **single-thread HTML5 Compatibility/WebGL2**. Avoid screen-space refraction/SSR, compute-based deformation, Forward+-only rendering, full volumetric soft-body and excessive transparency. Good art-directed shading can achieve premium gel look with mostly opaque surface + soft rim + specular/inner colour cues.

Pipeline: pinned Blender CLI runs on GitHub Actions cloud to export source .blend to .glb → Godot imports and validates skeleton/material references → headless tests → WebAssembly build → staging website → real browser preview and approval. **Successful export is not proof of visual quality**. The tested hero and materials become a permanent production library.

Work in `feature/premium-3d-world`; keep v0.3 main site working until the new hero and world meet browser quality and functional acceptance.

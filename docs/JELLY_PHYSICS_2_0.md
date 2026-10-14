# Squishy World — Jelly Physics 2.0

Status: staged physics architecture implemented; browser look, feel and performance await playtest. All tooling remains free and no workstation installation is needed.

## Architecture and constants
- 13 three-dimensional spring points: 3 rings of four controls plus a central anchor.
- Signed local displacements, velocities, neighbor coupling, 120 Hz internal substeps at physics ticks.
- Starting tuning: spring stiffness 64, coupling 23, damping 4.9, displacement cap 0.64 m, local mouse hold constraint 280.
- Godot Compatibility WebGL2 vertex shader shifts the original Blender mesh locally using Gaussian influence fields and approximates volume conservation.
- Blended global shape keys supply secondary expressions; face and appendages receive the same displacement field so they do not detach.
- Stable collider stays separate from deformable visible body. This is actual coupled spring physics, not volumetric FEM.

## First six core behaviors implemented
1. Stretch and release: click-hold any region, drag and let go. Spring energy transfers to surrounding points, overshoots, and dampens gradually.
2. Poke: short click injects localized inward impulse; the wobble propagates.
3. Squash: strongly activated on landing; more direct compression gestures are a later improvement.
4. Flick: last mouse-movement velocity is added upon release, yielding stronger recoil after a fast gesture.
5. Wobbly Walk: directional acceleration, braking and turning transfer impulses into upper-body jelly.
6. Landing: SPACE triggers a gravity-driven jump; landing injects spreading and compressing impulses.

## Required 24-behavior final catalogue
Direct manipulation: Stretch & Release, Pinch & Pull, Poke, Squash, Flick, Slap, Twist, Jiggle Loop.
Movement: Idle Breathing, Wobbly Walk, Acceleration Lag, Braking Wobble, Turning Jiggle, Jump Stretch, Landing Squash, Rolling & Recovery.
Environment: Wall Collision, Squishy Collision, Trampoline Bounce, Slope & Sliding, Water Buoyancy, Sticky Surface.
Material integrity: Secondary Ripple, Volume Preservation.

The last eighteen behaviors are not claimed finished. Several reuse the completed spring architecture but require environmental integration, animation, controls or fine-tuning.

## Test and approval gates
Automated: check signed reverse oscillation after drag release, ripple propagation to neighbors, bounded offsets, 100 repeated impacts and eventual settling. Confirm Blender source export, glTF load, Godot headless startup and WebAssembly export.
Manual: test soft and fast release, short poke, WASD acceleration and braking, SPACE landing, face attachment, frame stability, shader appearance and actual wobble duration in Chrome. Neither headless export nor mathematical test proves final visual quality.

## Related files
- scripts/premium/jelly_lattice.gd
- scripts/premium/squishy_morph_controller.gd
- shaders/premium/jelly_skin.gdshader
- scripts/premium/character_lab.gd
- tests/premium_lattice_smoke.gd
- docs/PREMIUM_ART_BIBLE_V1.md

All work remains on the dedicated feature branch; the live original math game and its saves remain unchanged.

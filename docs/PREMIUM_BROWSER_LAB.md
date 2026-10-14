# Premium hero interactive lab — staging only

This lab is a genuine Godot 4.7.2 Compatibility/WebGL2 3D scene. It loads Blender-exported .glb with shape keys, spring-driven deformation, and simple orbit/drag/jump interactions.

**The hero model is an internal visual candidate, NOT final art.** The goal of this test is the reusable Blender → glTF → Godot → browser physics and deformation chain without changing the live game.

Test: left-drag on creature to stretch, short click to poke, right-drag to orbit, scroll to zoom, SPACE to jump/impact. Facial elements will be moved by the FaceAnchor controller in sync with body morphs. Gameplay loop and overworld remain untouched on main.

The workflow produces a separate HTML5 export artifact, which can later be served at a dedicated staging route without replacing production site.

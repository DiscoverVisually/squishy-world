# Squishy World — AI coding and production rules

## LOCKED 2026-10-13 production direction
- Visual world: **Jelly Fantasy**, not preschool. Tactile **cartoon-premium** Squishies, **Blender-authored 3D**.
- Gameplay stays 2.5D/top-down, but the final overworld is a real **Godot Node3D / orthographic camera** environment. This supersedes the former prohibition on 3D.
- **No disposable user-facing art.** Produce one fully finished permanent zone before expanding. Improve lighting/shading/physics, never substitute a generic low-poly pack or primitive cylinders labeled final.
- Read: docs/PREMIUM_ART_BIBLE_V1.md, docs/BLENDER_GODOT_CHARACTER_PIPELINE_V1.md, docs/PREMIUM_PRODUCTION_ROADMAP_V1.md.
- Godot 4.7.2, GDScript, Compatibility WebGL2, single-thread Web export. Beauty only in Blender is insufficient; verify real Chrome browser visuals/performance.
- Use editable .blend masters and .glb runtime assets. Blender/Godot build tools run in GitHub cloud, no user workstation installation.
- Character gel motion must be spring-damper-driven; real tactile poking, holding, stretching and release. No expensive full volumetric soft-body mandated.
- Preserve the working v0.3 on main while creating a separate feature/premium-3d-world staging branch. Do not prematurely replace the map.
- Keep existing 2D minigames, encounter→reward loop, local collection saves, grade presets and practice mode across one-time world migration.
- Do not claim FPS, web visual quality or tactile quality tested unless actually reviewed in the browser.

## Engineering rules
- Prefer typed GDScript, modular scenes, and small changes.
- Deterministic locally verified mathematics; Slovak cycle/skill catalog plus grade presets.
- No ads, tracking, personal identifying data, payments or compulsory accounts.
- Audit licensing and preserve source assets.
- Run headless import, math tests, runtime smoke check and HTML5 export for code changes. Keep existing GitHub Pages live until production quality is approved.

## Budget and workstation constraints — locked 2026-10-14
- **100% free tooling only.** No paid services, 3D-generation subscriptions, licenses, APIs, premium assets, compute, credits, or unexpected billing. Do not recommend or connect paid providers without the user's explicit reversal of this decision.
- The user installs **nothing** locally: no Blender, Godot, Node.js, Python, or CLI. Run the art/rig/export/test pipeline in cloud GitHub Actions within its available free quotas.
- Prefer Blender (GPL), Godot (MIT), compatible open-source tools and permissively licensed/CC0 assets. Check each model's output/commercial-use license and provenance before using it. A nominally "free trial" with paid-only exports does not qualify.
- If a high-quality stage proves infeasible with free cloud resources, report the limitation transparently; do not silently degrade the locked art direction or substitute cheap-looking primitives.
- A successful Blender script or morph export is not proof of final visual quality. Final hero requires approved in-browser appearance, face-deformation coherence, and physically responsive dragging/bounce, without a shipping-placeholder pass.

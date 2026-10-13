# Squishy World — AI coding rules

- Read docs/GDD.md and docs/PROTOTYPE_PLAN.md before implementing new gameplay.
- Target Godot 4.7.2 stable, GDScript, Compatibility renderer, single-thread Web.
- This is a 2D game with 2.5D-looking procedural art; do not convert to 3D.
- Keep moving-player browser smoke test operational at every milestone.
- Prefer typed GDScript, small scenes, and explicit interfaces.
- The player uses CharacterBody2D and physics_process for movement; dynamic minigame objects should use appropriate physics objects.
- Keep mathematical answers deterministic and validated locally, never by an LLM at runtime.
- Separate motor difficulty from mathematical difficulty; support Slovak curricula as cycle-based skill catalog.
- No advertisements, analytics tracking, payments, child identifying data, or account registration.
- Document third-party assets and licenses.
- Run Godot headless import + Web export and report actual outcomes; do not claim unrun tests passed.
- Do not overwrite existing features or redesign unrelated systems without approval.

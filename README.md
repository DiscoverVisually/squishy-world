# Squishy World

Cute math-adventure project for children. Current version: **exploration-only prototype** (not yet complete minigame/collecting).

## Play

After the owner enables **Settings → Pages → Build and deployment → Source: GitHub Actions**, visit:

https://discovervisually.github.io/squishy-world/

Use **WASD or arrow keys** to walk. Look for five squishy creatures in the meadow. The collecting and math minigames will arrive in later milestones.

## No local installation

Godot 4.7.2 builds in GitHub Actions through barichello/godot-ci. All you need on your workstation is a browser.

## Files
- `project.godot` + `export_presets.cfg` — Godot 4.7.2 and Web export.
- `scenes/` and `scripts/` — illustrated meadow, player, creatures, HUD.
- `.github/workflows/web.yml` — automated WebGL2/WASM build and GitHub Pages deploy.
- `docs/GDD.md`, `docs/PROTOTYPE_PLAN.md` — project knowledge.
- `AGENTS.md` — coding conventions.

**Testing:** Source is ready for cloud checks. Do not regard a deployment or 60 FPS as verified until the Actions run completes and the game loads in a real browser.

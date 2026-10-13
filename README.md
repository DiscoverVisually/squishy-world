# Squishy World

Cute math-adventure project for children. Current version: **prototype 0.3** with Squishy Launcher and Jelly Merge.

## Play

After the owner enables **Settings → Pages → Build and deployment → Source: GitHub Actions**, visit:

https://discovervisually.github.io/squishy-world/

Use **WASD or arrow keys** to walk. Press **1–4** to select a Slovak math-grade starting level. Stand near a wild Squishy and press **E**, then choose **1** for Launcher or **2** for Jelly Merge. In Jelly Merge, click over the tank to drop a numbered jelly blob; equal-value blobs merge by addition until you reach the target. **R** restarts the merge game; **Escape** returns to the map. The original Launcher game remains available. Gravity affects the trajectory; a dotted preview shows the flight path. Hit the correct target to recruit the Squishy. Escape quits the encounter. Collection and grade are saved locally in the browser. The Jelly Merge minigame, character profiles, and richer collection view are later milestones.

## No local installation

Godot 4.7.2 builds in GitHub Actions through barichello/godot-ci. All you need on your workstation is a browser.

## Files
- `project.godot` + `export_presets.cfg` — Godot 4.7.2 and Web export.
- `scenes/` and `scripts/` — illustrated meadow, player, creatures, HUD.
- `.github/workflows/web.yml` — automated WebGL2/WASM build and GitHub Pages deploy.
- `docs/GDD.md`, `docs/PROTOTYPE_PLAN.md` — project knowledge.
- `AGENTS.md` — coding conventions.

**Testing:** Source is ready for cloud checks. Do not regard a deployment or 60 FPS as verified until the Actions run completes and the game loads in a real browser.

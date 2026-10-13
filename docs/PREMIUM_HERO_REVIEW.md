# First Premium Blender Squishy — staging only

Approved visual standard: Jelly Fantasy, premium lime-jade squishy with pear-shaped body, big layered eyes, crown sprouts, soft winglets, beautiful soft lighting.

## This branch
`feature/premium-3d-world` preserves the published v0.3. This cloud Blender workflow generates an **editable model source** `hero_squishy.blend`, morph-enabled runtime `hero_squishy.glb`, and an image preview from the same source. The files are available under the GitHub Actions artifacts for the branch workflow.

The first output is an **art-review candidate**, not production-approved art or real interactive physics yet. **Do not merge or show in the game until** facial features deform coherently, responsive springs control the shape keys, WebGL2 shaders meet the concept reference, and the model passes gameplay-distance visual review. This prevents disposable artwork entering the final landscape.

Morph target names: Squash, StretchUp, LeanLeft, LeanRight, Impact, PokeFront, HappyWiggle.

## Workflow
On push to this feature branch only, GitHub Actions runs Blender 4.5.14 in cloud. Absolutely no user workstation installs or changes to main.

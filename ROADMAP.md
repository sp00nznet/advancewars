# Roadmap

## Next

- **Title to menu.** With `tools/title.txt`, mGBA goes title, menu, Nell's
  "Welcome to Advance Wars!"; the recompiled build returns to the attract loop.
  Memory matches mGBA at frame 615 except the title's actor state machines
  (IWRAM `0x03000ED0`...), whose handlers share epilogues with their wrapper
  (`0x0801B888`). Start from `tools/oracle` dumps around the Start press.
- **Field Training and a full battle**, then the campaign.
- **Audio**, once the toolkit has a mixer.
- **Rendering**: blend fades (BLDCNT/BLDY), windows and the affine layers in the
  intro and title, from the toolkit's PPU work.
- **netlab recipe** (`projects/advancewars.env`) so builds and QA run on the
  farm, with `SHIP=lan`.
- **CI**: build the toolkit and this repo's scripts on push; conformance
  reports SKIP there (no ROM).

## Deferred

- Save states and the ImGui menu from the hybrid era: back once the game is
  playable on the static build.
- Advance Wars 2: Black Hole Rising.

## Out of scope

- Distributing the ROM, generated C, or builds made from them.

# Roadmap

## Next

- **Play Field Training out**: move units, attack, win; script it in
  `tools/` and compare with mGBA at each turn.
- **Campaign and save/load** through the in-game menus.
- **RAM overlays in the toolkit**, which would retire the two m4a entries in
  `entries.txt` and run the sound mixer natively.
- **Audio**, once the toolkit has a mixer.
- **Rendering**: windows (the screen-transition wipes), affine sprites, from the
  toolkit's PPU work.
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

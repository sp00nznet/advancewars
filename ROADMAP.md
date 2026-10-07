# Roadmap

## Next

- **Finish Field Training**: `tools/field_training_battle.txt` plays to the
  first battle on Day 2; carry it to the win, comparing with mGBA each turn.
- **Campaign and save/load** through the in-game menus.
- **RAM overlays in the toolkit**, which would retire the two m4a entries in
  `entries.txt` and run the sound mixer natively.
- **Audio**, once the toolkit has a mixer.
- **Rendering**: affine sprites and mosaic, from the toolkit's PPU work.
- **Frame timing**: the build runs a frame or two behind mGBA in places
  (approximate cycle counts), so text and slides land a frame later. Game
  state stays in step.
- **CI**: build the toolkit and this repo's scripts on push; conformance
  reports SKIP there (no ROM).

## Deferred

- Save states and the ImGui menu from the hybrid era: back once the game is
  playable on the static build.
- Advance Wars 2: Black Hole Rising.

## Out of scope

- Distributing the ROM, generated C, or builds made from them.

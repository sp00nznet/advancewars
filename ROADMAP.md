# Roadmap

## Next

- **Campaign and save/load**: script the next missions on from
  `tools/field_training_win.txt`, and load the save it writes.
- **RAM overlays in the toolkit**, which would retire the two m4a entries in
  `entries.txt` and run the sound mixer natively.
- **Audio**, once the toolkit has a mixer.
- **Rendering**: mosaic, from the toolkit's PPU work.
- **Frame timing**: cycle counts are approximate, so the build runs a frame
  or two behind mGBA in places, and about 60 frames ahead after heavy code
  such as the end of Field Training's last battle. Game state stays in step;
  scripts with a press every 90 frames still line up.
- **CI**: build the toolkit and this repo's scripts on push; conformance
  reports SKIP there (no ROM).

## Deferred

- Save states and the ImGui menu from the hybrid era: back once the game is
  playable on the static build.
- Advance Wars 2: Black Hole Rising.

## Out of scope

- Distributing the ROM, generated C, or builds made from them.

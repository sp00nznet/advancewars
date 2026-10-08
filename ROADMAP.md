# Roadmap

## Next

- **Campaign and save/load**: script the next missions on from
  `tools/field_training_win.txt`, and load the save it writes.
- **RAM overlays in the toolkit**, which would retire the two m4a entries in
  `entries.txt` and run the sound mixer natively.
- **Audio**, once the toolkit has a mixer.
- **Rendering**: mosaic, from the toolkit's PPU work.
- **Frame timing**: the toolkit times code as mGBA does (gbarecomp#21,
  #22). Boot matches mGBA to the frame and Field Training stays within 4
  frames, but it isn't cycle-exact: script presses must stay clear of the
  frames where a text box opens or finishes.
- **CI**: build the toolkit and this repo's scripts on push; conformance
  reports SKIP there (no ROM).

## Deferred

- Save states and the ImGui menu from the hybrid era: back once the game is
  playable on the static build.
- Advance Wars 2: Black Hole Rising.

## Out of scope

- Distributing the ROM, generated C, or builds made from them.

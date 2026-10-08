# Changelog

All notable changes to this project. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versions follow SemVer once the first one is tagged.

## [Unreleased]

### Added
- `tools/field_training_m2.txt`: Field Training's first two missions. The
  second (against Olaf) runs three days: Day 1's four attacks, Olaf's AI
  turns, Day 2's attacks, Day 3's save tutorial and the finish, then Victory
  (rank A) and the third mission's briefing, in step with mGBA. A presses
  are placed off text-box edges with mgba_oracle's flag watch
  (gbarecomp#26). `docs/screenshots/field_training_m2.png`.
- `tools/field_training_win.txt`: plays Field Training to the win. Day 1
  moves, Olaf's turns, Day 2's two attacks (one destroys an infantry), and
  Day 3's finish, then Victory, the results screen (rank A), the save and
  the next mission's briefing, in step with mGBA.
  `docs/screenshots/field_training.png`, `field_training_win.png`.
- `tools/field_training.txt`: button script from the intro through name entry
  and Nell's tutorial into the first Field Training battle.
- Two entry points in `entries.txt` that only m4a's RAM mixer calls.

- Root `CMakeLists.txt` and `tools/qa.cmd`; the generated C moves from
  `build/gen` to `gen/` so a build farm can build the checkout. recomp-netlab
  recipe `advancewars`: builds on the clang-cl builder in about 20 s
  (headless-only, gbarecomp#7), QA passes here and reports SKIP on the test VM.

### Changed
- gbarecomp pinned at main after #25-#27. #27 fixes the hang in the second
  mission's first enemy turn: the AI calls newlib's `setjmp`, whose
  conditional `MOVEQ pc, lr` return never returned, and its `longjmp` then
  unwound out of the game. #25 times VRAM waits and `CpuFastSet` as mGBA
  does; #26 adds the oracle's flag watch used to place the script's presses.
  Conformance stays at 165/165.
- gbarecomp pinned at main after #21-#23: timing follows mGBA's cycle model
  (#21), and flash takes time to program (#22). The build used to run 14
  frames fast at boot and 44 ahead by the end of Field Training; now boot
  matches mGBA to the frame and the mission stays within 4 frames.
  `tools/field_training_win.txt` drops a press that landed as Victory's
  text box opened (mGBA ate it, the build didn't) and shifts the rest 20
  frames later. Conformance baseline `165 165`: more functions run in the
  760-frame window.
- gbarecomp pinned at main after #17-#19. The results screen fell into the
  wrong code after a block split (gbarecomp#17): bars drawn from garbage,
  then a hang in the RAM sprite builder. Its "Victory!", labels and rank
  needed affine sprites (#19). The BIOS affine SWIs also had the scale
  inverted (#18).
- Conformance baseline `138 138`: tails split from shared blocks now run
  inline, so fewer separate functions are called in the 760-frame window.
- gbarecomp pinned at main after #9-#15. Field Training play found and
  fixed: Thumb LDRH/LDRSB swapped in the translator (the move range covered
  the whole map, gbarecomp#12), calls into code already analyzed as part of
  another function compiled to empty stubs (`_call_via_r3`, the map-icon
  loader; #13), HBlank/VCount IRQs raised without their DISPSTAT enables
  (junk at the bottom of the battle screen; #14), no nested interrupts (the
  top text box never appeared; #15), plus PPU windows (#9) and HBlank timing
  (#10).
- `build.cmd` writes `gen/` and builds `build/Release/AWRE.exe`.
- With gbarecomp#5 and #6 (sound driver, shared switch blocks, scanline
  renderer) the game gets past the title: menus, name entry, the tutorial
  and the first battle map, matching mGBA screen for screen.
- Conformance baseline `151 151` (the harness now counts failures).

### Added
- `Setup.cmd` quick start and `build.cmd`: tool checks, toolkit fetch, ROM
  discovery and verification, build, launcher.
- gbarecomp as a submodule at `ext/gbarecomp` (needs gbarecomp#1, #3, #4: license, Flash
  backup, control-flow recovery and tooling).
- `tools/title.txt` button script and `conformance_baseline.txt`.
- LICENSE (MIT), ROADMAP, `docs/architecture.md`, screenshots of the
  recompiled intro.

### Changed
- The build is fully static: the libmgba-backed hybrid (`build.sh`) is gone.
  The recompiled build plays the whole attract intro and reaches the title
  screen; menus aren't reached yet (see ROADMAP).
- `aw_config.txt` is now `entries.txt`, passed to the toolkit with `--entries`
  (the toolkit no longer hard-codes Advance Wars addresses).
- README rewritten to the current state.

### Removed
- `build.sh` (hybrid build) and the hybrid-era screenshots.

## 2026-03 (untagged)

- First boot of the recompiled code under a libmgba-backed runtime: title
  screen, intro, menus and training missions, with recompiled functions
  intercepted from mGBA's run loop.

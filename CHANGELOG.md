# Changelog

All notable changes to this project. Format: [Keep a Changelog](https://keepachangelog.com/en/1.1.0/);
versions follow SemVer once the first one is tagged.

## [Unreleased]

### Added
- `tools/field_training.txt`: button script from the intro through name entry
  and Nell's tutorial into the first Field Training battle.
- Two entry points in `entries.txt` that only m4a's RAM mixer calls.

- Root `CMakeLists.txt` and `tools/qa.cmd`; the generated C moves from
  `build/gen` to `gen/` so a build farm can build the checkout. recomp-netlab
  recipe `advancewars`: builds on the clang-cl builder in about 20 s
  (headless-only, gbarecomp#7), QA passes here and reports SKIP on the test VM.

### Changed
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

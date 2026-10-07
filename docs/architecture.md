# Architecture

## The build

```
game/aw.gba ──> ext/gbarecomp: gbarecomp translate --multi --entries entries.txt
                     │
                     ▼
               gen/   7384 recompiled functions as C, game_entry.c (dispatch
                     │      table, main), plus the toolkit runtime copied in
                     ▼
               build/Release/AWRE.exe   (CMakeLists.txt here builds gen/; SDL2 for
                                         the window, headless-only without it)
```

- **This repo** owns what is specific to Advance Wars: `entries.txt` (callback
  targets the analyzer can't find), the button scripts in `tools/`, the
  conformance baseline, and these notes.
- **[gbarecomp](https://github.com/sp00nznet/gbarecomp)** (submodule at
  `ext/gbarecomp`) owns everything general: analysis, translation, the runtime
  (memory map, timers, DMA, interrupts, BIOS calls, PPU, Flash save), the
  headless flags, the validator and the mGBA reference runner.
- **gen/** (the C) and **build/** are made from your ROM on your machine and
  never committed.

The executable runs the recompiled C directly. Code the game copies into RAM
(its interrupt handler, the m4a sound mixer, the Flash routines) runs in the
toolkit's interpreter; everything in ROM is native.

Before October 2026 this repo built a hybrid in which libmgba ran the CPU and
recompiled functions were intercepted from its run loop. That was retired: the
build is now fully static, with mGBA kept only as the reference
([ext/gbarecomp/docs/conformance.md](https://github.com/sp00nznet/gbarecomp/blob/main/docs/conformance.md)).

# Game notes

Discovered while recompiling. Partially confirmed by the
[ketsuban/advancewars](https://github.com/ketsuban/advancewars) decompilation project.

## Startup Sequence

```
crt0 (0x080000C0, ARM):
  1. Set IRQ mode (CPSR=0x12), SP = 0x03007F80
  2. Set System mode (CPSR=0x1F), SP = 0x03007C00
  3. BX to AgbMain (0x0807AD10, Thumb)
  4. On return: loop back to crt0

AgbMain (0x0807AD10, Thumb):
  1. PUSH {LR}
  2. BL sub_0807AD00  (quick init: disable interrupts, init priority queue)
  3. BL sub_080386E4  (main game function - never returns during normal play)
  4. POP {PC}
```

## Priority Queue Task System

The game uses a priority queue at IWRAM `0x03006560` to manage callbacks:

- **16 slots**, each 12 bytes (function pointer + priority + next pointer)
- Storage array at `0x03006570`
- Callbacks are `u32 (*)(void)` function pointers

### Task Dispatcher (sub_0807AD28)

The VBlank-aware task dispatcher:
1. Iterates callbacks in priority order while scanline <= 0x1D (during VDraw)
2. Waits for VBlank to start (polls DISPSTAT bit 0)
3. Waits for VBlank to end
4. Calls remaining callbacks during VBlank

This is why the game requires real VBlank timing - the task dispatcher
explicitly polls DISPSTAT hardware register.

## IWRAM Code

The game copies critical code to IWRAM and executes from there:

| Source (ROM) | Destination (IWRAM) | Size | Purpose |
|-------------|-------------------|------|---------|
| `0x0827D308` | `0x03006630` | 30 halfwords | Interrupt dispatch table |
| `intr_main` | `0x03000718` | 256 bytes | Interrupt handler |
| Various | `0x03007Axx-0x03007Bxx` | ~256 bytes | Init/decompression routines |

The interrupt handler at `0x03000718` is set as the BIOS ISR via
`[0x03007FFC] = 0x03000718`.

## BIOS Calls Used

| SWI | Name | Purpose |
|-----|------|---------|
| 0x06 | Div | Integer division |
| 0x08 | Sqrt | Square root |
| 0x0B | CpuSet | Memory copy/fill (halfword) |
| 0x0C | CpuFastSet | Memory copy/fill (word, fast) |
| 0x0E | BgAffineSet | BG affine transform setup |
| 0x11 | LZ77UnCompWram | LZ77 decompress to WRAM |
| 0x15 | RLUnCompVram | RLE decompress to VRAM |

## Display configuration

- Boot: DISPCNT = 0x0080 (forced blank while loading).
- Intro map and title: DISPCNT = 0x1C44 / 0x1F44, **mode 4** (bitmap BG2) plus OBJ.
- Intro scenes: DISPCNT = 0x3F40 / 0x7F60, mode 0, all four BGs plus OBJ, with
  brightness fades through BLDCNT/BLDY (0x009F, 0x00DF) driven from shadow
  registers in IWRAM (BLDY shadow at `0x03001D10`, copied to I/O by
  `0x08016Bxx`/`0x08016Cxx`).
- Palette fades are done in software by an ARM routine at `0x08000100`
  (reached through the Thumb veneer `0x080796A4`, `BX pc`): per-component
  running values with a signed step table at EWRAM `0x020104D4`.
- Interrupts: IE = 0x2001 (VBlank + Game Pak), IME = 1.

## Save

Flash, 64KB (`FLASH_V121`). At boot the game reads all 16 sectors into a 4KB
buffer at `0x0202F000` and records a per-sector status at `0x02012AA8` (0xFF on
blank flash). Sector 15 (`0xF000`) holds the header ("wars", then "Advance").
The read routines are copied to IWRAM (`0x03007A75`, `0x03007B01`, from ROM
`0x08079CE4`, `0x08079BB0`) and called through `_call_via_r4`.

## Key addresses

| Address | Description |
|---------|-------------|
| `0x080000C0` | crt0 entry (ARM) |
| `0x080001D0` / `0x080001E4` | `setjmp` / `longjmp` (ARM) |
| `0x0807AD10` | AgbMain (Thumb) |
| `0x0807AD00` | Quick init |
| `0x08038734` | Main game function; main loop at `0x0803880A` |
| `0x0807B44C`-`0x0807B486` | `_call_via_r0` ... `_call_via_lr` veneers |
| `0x0801B2C0` | Boot-time save sector scan |
| `0x0801B888` | Actor-update wrapper: pushes `{r4, lr}`, jumps to the handler, whose epilogue pops the wrapper's frame |
| `0x03000ED0`... | Title-screen actors (handler pointers at +8, e.g. `0x08070509`) |
| `0x03006560` | Priority queue struct |
| `0x03006630` | Interrupt dispatch table |
| `0x03000718` | Interrupt handler (IWRAM, ARM, from ROM `0x0801BBCC`) |
| `0x03007FFC` | BIOS ISR pointer |

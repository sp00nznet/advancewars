# Advance Wars - Game Architecture Notes

Notes discovered during static recompilation. Partially confirmed by the
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
| 0xF0 | Custom? | Possibly game-specific decompression |

## Display Configuration

- **Mode 0** with tiled backgrounds
- Init: DISPCNT = 0x0080 (forced blank during setup)
- Active: DISPCNT = 0x1C44 (BG0+BG1+BG2 + OBJ, Mode 0)
- Later: DISPCNT = 0x3F40 (all 4 BG layers + OBJ)
- Interrupts: IE = 0x2001 (VBlank + custom), IME = 1

## Save Type

Flash save (auto-detected by mGBA). Sector erase observed at offset 0xF000.

## Key Addresses

| Address | Description |
|---------|-------------|
| `0x080000C0` | crt0 entry (ARM) |
| `0x0807AD10` | AgbMain (Thumb) |
| `0x0807AD00` | Quick init |
| `0x080386E4` | Main game function (600+ blocks) |
| `0x08038812` | Main game loop (LDR/CMP/BL/B) |
| `0x03006560` | Priority queue struct |
| `0x03006630` | Interrupt dispatch table |
| `0x03000718` | Interrupt handler (IWRAM) |
| `0x03007FFC` | BIOS ISR pointer |

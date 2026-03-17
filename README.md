# Advance Wars Recompiled

**The greatest GBA strategy game, liberated from its hardware prison.**

```
    ___       __                              _       __
   /   | ____/ /   ______ _____  ________   | |     / /___ ___________
  / /| |/ __  / | / / __ `/ __ \/ ___/ _ \  | | /| / / __ `/ ___/ ___/
 / ___ / /_/ /| |/ / /_/ / / / / /__/  __/  | |/ |/ / /_/ / /  (__  )
/_/  |_\__,_/ |___/\__,_/_/ /_/\___/\___/   |__/|__/\__,_/_/  /____/
                    R E C O M P I L E D
```

## What Is This?

This project takes the original **Advance Wars** (GBA, 2001) ROM and statically recompiles it into native code that runs on modern hardware -- no emulator required. The game's ARM7TDMI instructions are translated to C, compiled with a modern toolchain, and linked against a hardware runtime library that faithfully reproduces the GBA's video, audio, and I/O behavior.

The result? Advance Wars running natively on your PC at whatever resolution you want, with the door wide open for mods, quality-of-life improvements, and ports to platforms the GBA never dreamed of.

## Why?

Because Andy, Max, Sami, and the rest of the crew deserve better than being trapped on a 20-year-old handheld. Because Intelligent Systems made something genuinely special and the world should be able to play it forever. Because static recompilation is one of the coolest preservation techniques in gaming and the GBA deserves the same love the N64 has been getting.

**Advance Wars** is a masterclass in turn-based strategy:
- Fog of war that actually creates tension
- CO Powers that turn the tide of battle
- A campaign that teaches you to think three turns ahead
- Multiplayer that ruins friendships (in the best way)

This game shipped in September 2001 and immediately got overshadowed by world events and the GBA's own stacked library. It deserves a second chance in the spotlight.

## How It Works

```
[Advance Wars ROM]
        |
        v
[gbarecomp] -- Static recompiler (ARM7TDMI -> C)
        |
        v
[Generated C source]  +  [GBA Runtime (libmgba)]
        |                        |
        v                        v
[Native compiler (gcc/clang/MSVC)]
        |
        v
[advancewars.exe / advancewars] -- Native binary!
```

1. **Disassembly** -- The ROM is analyzed, ARM and Thumb code blocks are identified, and the control flow is mapped
2. **Translation** -- Each instruction is converted to equivalent C code that operates on a virtual register file
3. **Runtime Linking** -- The generated C code links against a GBA hardware runtime (built from [libmgba](https://github.com/mgba-emu/mgba)) that handles PPU rendering, audio mixing, DMA transfers, timers, and interrupts
4. **Compilation** -- A standard C compiler produces a native binary for your platform

## Project Status

| Milestone | Status |
|-----------|--------|
| ROM analysis & disassembly | Not started |
| ARM instruction translation | Not started |
| Thumb instruction translation | Not started |
| Memory bus + MMIO dispatch | Not started |
| PPU runtime (via libmgba) | Not started |
| APU runtime (via libmgba) | Not started |
| DMA / Timers / IRQ runtime | Not started |
| Campaign playable | Not started |
| Multiplayer functional | Not started |
| Save system working | Not started |

## Target: Advance Wars 1 First

We're starting with the original **Advance Wars** (USA, Rev 1). Once the recompilation pipeline is proven and the game is playable end-to-end, we'll turn our attention to **Advance Wars 2: Black Hole Rising**.

## Related Projects

- **[gbarecomp](https://github.com/sp00nznet/gbarecomp)** -- The recompilation toolchain that makes this possible. Generic enough to work with any GBA title.
- **[N64Recomp](https://github.com/N64Recomp/N64Recomp)** -- The pioneering N64 static recompiler that proved this approach works. Major inspiration for this project.
- **[gb-recompiled](https://github.com/arcanite24/gb-recompiled)** -- Static recompiler for original Game Boy. Closest existing work to what we're building.
- **[mGBA](https://github.com/mgba-emu/mgba)** -- The excellent GBA emulator whose `libmgba` core powers our hardware runtime.

## Want to Help?

This is a big, ambitious project and we'd love help from anyone who's passionate about:
- **ARM reverse engineering** -- GBA uses ARM7TDMI with ARM/Thumb interworking
- **Compiler/toolchain development** -- The recompiler is the heart of everything
- **GBA hardware internals** -- PPU timing, DMA edge cases, audio mixing
- **Advance Wars** -- If you love this game, you belong here

Check out the [gbarecomp](https://github.com/sp00nznet/gbarecomp) repo for the recompilation tools, or open an issue here if you want to discuss the Advance Wars-specific work.

## Legal

This project does not distribute any copyrighted game data. You must provide your own legally obtained ROM. The recompilation tools and runtime are open source. The GBA hardware runtime is based on [mGBA](https://github.com/mgba-emu/mgba) (MPL-2.0).

---

*"It's your turn, and you've got nothing to lose."*

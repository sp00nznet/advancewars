#!/bin/bash
# Build script for Advance Wars Recompiled
#
# Prerequisites:
#   - gbarecomp built at ../gbarecomp/build/Release/gbarecomp.exe
#   - mGBA built at ../mgba/build/Release/mgba.lib
#   - SDL2 via vcpkg: vcpkg install sdl2:x64-windows
#   - MSVC (Visual Studio 2022)
#   - Your own legally obtained Advance Wars ROM
#
# Usage:
#   ./build.sh "path/to/Advance Wars (USA) (Rev 1).gba"

set -e

ROM="${1:-Advance Wars (USA) (Rev 1).gba}"
GBARECOMP="../gbarecomp/build/Release/gbarecomp.exe"
MGBA_DIR="../mgba"
VCPKG_TOOLCHAIN="C:/vcpkg/scripts/buildsystems/vcpkg.cmake"
OUTPUT_DIR="build_output"

echo "=== Advance Wars Recompiled - Build Script ==="
echo "ROM: $ROM"
echo ""

# Step 1: Generate C source from ROM
echo "[1/4] Analyzing and translating ROM..."
rm -rf "$OUTPUT_DIR"
"$GBARECOMP" translate "$ROM" -o "$OUTPUT_DIR" --multi
echo "  Generated $(ls "$OUTPUT_DIR"/funcs_*.c | wc -l) function files"
echo ""

# Step 2: Copy runtime files
echo "[2/4] Setting up runtime..."
cp "$GBARECOMP/../../../src/runtime_mgba.c" "$OUTPUT_DIR/runtime.c"
echo "/* empty - display integrated into runtime */" > "$OUTPUT_DIR/display.c"

# Headers
mkdir -p "$OUTPUT_DIR/gba"
for f in gba_runtime.h types.h display.h; do
    cp "../gbarecomp/include/gba/$f" "$OUTPUT_DIR/gba/$f"
done
cp "../gbarecomp/include/gba/gba_runtime.h" "$OUTPUT_DIR/gba_runtime.h"

# Add mGBA config to CMakeLists
cat >> "$OUTPUT_DIR/CMakeLists.txt" << MGBA_EOF

# libmgba hardware backend
set(MGBA_DIR "$MGBA_DIR")
target_include_directories(AWRE PRIVATE \${MGBA_DIR}/include \${MGBA_DIR}/build/include \${MGBA_DIR}/src)
target_link_libraries(AWRE PRIVATE \${MGBA_DIR}/build/Release/mgba.lib ws2_32 shlwapi)
target_compile_definitions(AWRE PRIVATE
    M_CORE_GBA ENABLE_VFS ENABLE_VFS_FD ENABLE_DIRECTORIES BUILD_STATIC
    HAVE_CRC32 HAVE_STRDUP HAVE_SETLOCALE NOMINMAX WIN32_LEAN_AND_MEAN
    _UNICODE UNICODE _CRT_SECURE_NO_WARNINGS color_t=uint32_t)
MGBA_EOF
echo ""

# Step 3: Build
echo "[3/4] Compiling (this takes a few minutes)..."
cd "$OUTPUT_DIR"

# Generate catchall stubs (two-pass: build once to find missing symbols, then add stubs)
echo "// placeholder" > catchall_stubs.c
sed -i '/funcs_062.c$/a\    catchall_stubs.c' CMakeLists.txt 2>/dev/null || true

cmake -B build -G "Visual Studio 17 2022" -A x64 \
    -DCMAKE_TOOLCHAIN_FILE="$VCPKG_TOOLCHAIN" 2>&1 | tail -1

# First build to discover missing symbols
cmake --build build --config Release 2>&1 | grep "unresolved external" | \
    grep -o 'func_[0-9A-Fa-f]*' | sort -u > /tmp/aw_missing.txt
grep -oh 'void func_[0-9A-Fa-f]*' stubs_*.c funcs_*.c 2>/dev/null | \
    grep -o 'func_[0-9A-Fa-f]*' | sort -u > /tmp/aw_existing.txt
comm -23 /tmp/aw_missing.txt /tmp/aw_existing.txt > /tmp/aw_need.txt

echo '#include "game.h"' > catchall_stubs.c
echo 'unsigned long __cdecl crc32(unsigned long c, const unsigned char* b, unsigned int l){(void)b;(void)l;return c;}' >> catchall_stubs.c
while IFS= read -r sym; do echo "void ${sym}(void){}" >> catchall_stubs.c; done < /tmp/aw_need.txt
echo "  Generated $(wc -l < catchall_stubs.c) catchall stubs"

# Final build
cmake --build build --config Release 2>&1 | tail -3
cd ..

# Step 4: Copy SDL2 DLL
echo ""
echo "[4/4] Finalizing..."
cp "C:/vcpkg/installed/x64-windows/bin/SDL2.dll" "$OUTPUT_DIR/build/Release/" 2>/dev/null || true

echo ""
echo "=== Build complete! ==="
echo "Binary: $OUTPUT_DIR/build/Release/AWRE.exe"
echo ""
echo "Run with:"
echo "  $OUTPUT_DIR/build/Release/AWRE.exe \"$ROM\""
echo ""
echo "Controls: Enter=Start, Z=A, X=B, Arrows=D-pad, Escape=Quit"

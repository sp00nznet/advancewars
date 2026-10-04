@echo off
rem Build Advance Wars from your ROM: builds the gbarecomp toolkit (ext\gbarecomp),
rem translates game\aw.gba to C in build\gen, and compiles build\b\Release\AWRE.exe.
rem Needs Visual Studio 2022 (or the Build Tools) with C++, CMake, and SDL2 from
rem vcpkg (VCPKG_ROOT, default C:\vcpkg). Setup.cmd checks all of that first.
rem The generated C is built from your ROM on your machine and never committed.
setlocal
set "ROOT=%~dp0"
set "TK=%ROOT%ext\gbarecomp"
if not defined VCPKG_ROOT set "VCPKG_ROOT=C:\vcpkg"

if not exist "%ROOT%game\aw.gba" (echo game\aw.gba not found: run Setup.cmd, or copy your ROM there. & exit /b 1)
if not exist "%TK%\CMakeLists.txt" (echo ext\gbarecomp is empty: run "git submodule update --init". & exit /b 1)

echo [1/4] Building the gbarecomp toolkit
cmake -S "%TK%" -B "%TK%\build" -G "Visual Studio 17 2022" -A x64 >nul || exit /b 1
cmake --build "%TK%\build" --config Release || exit /b 1

echo [2/4] Translating game\aw.gba to C (build\gen)
if not exist "%ROOT%build" mkdir "%ROOT%build"
rem The translator copies the runtime sources by path relative to the toolkit.
pushd "%TK%"
build\Release\gbarecomp.exe translate "%ROOT%game\aw.gba" -o "%ROOT%build\gen" --multi --entries "%ROOT%entries.txt" || (popd & exit /b 1)
popd

echo [3/4] Compiling build\b\Release\AWRE.exe (about a minute)
cmake -S "%ROOT%build\gen" -B "%ROOT%build\b" -G "Visual Studio 17 2022" -A x64 -DCMAKE_TOOLCHAIN_FILE="%VCPKG_ROOT%\scripts\buildsystems\vcpkg.cmake" >nul || exit /b 1
cmake --build "%ROOT%build\b" --config Release --parallel || exit /b 1

echo [4/4] Copying SDL2.dll
copy /y "%VCPKG_ROOT%\installed\x64-windows\bin\SDL2.dll" "%ROOT%build\b\Release\" >nul || exit /b 1
echo Built build\b\Release\AWRE.exe

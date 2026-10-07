# One-click setup for Advance Wars (static recompilation).
# Run it by double-clicking Setup.cmd in the repo folder; the README's "Step by
# step" is the same thing by hand, command for command.
#
# It checks the tools, fetches the gbarecomp toolkit into ext\gbarecomp, finds
# your Advance Wars ROM and copies it to game\aw.gba, runs build.cmd, and leaves
# a launcher. Each step is skipped when its output already exists (-Force redoes
# them). Everything it does goes to setup.log. Your ROM stays on this machine.
param([switch]$Force, [string]$Rom = "")

$ErrorActionPreference = 'Stop'
$Root = Split-Path -Parent $PSScriptRoot
$Log = Join-Path $Root 'setup.log'
$RomSha1 = '15053499d5b3f49128a941d7f2d84876f5424d0c'   # Advance Wars (USA) (Rev 1)
Set-Location $Root
function Log($t) { try { Add-Content -Path $Log -Value $t -Encoding UTF8 -ErrorAction Stop } catch {} }
Log "==== setup $(Get-Date -Format s)"

function Say($t, $c = 'Gray') { Write-Host $t -ForegroundColor $c; Log $t }
function Step($n, $t) { Write-Host ""; Say "[$n/5] $t" 'Cyan' }
function Fail($t) {
  Say ""; Say "Setup stopped: $t" 'Red'
  Say "The details are in $Log. Fix that and run Setup.cmd again; finished steps are skipped." 'Yellow'
  Read-Host "Press Enter to close" | Out-Null; exit 1
}
function Ask($q) { $a = Read-Host "$q [Y/n]"; return -not ($a -match '^[nN]') }   # Enter = yes
function Refresh-Path {
  $env:Path = [Environment]::GetEnvironmentVariable('Path', 'Machine') + ';' + [Environment]::GetEnvironmentVariable('Path', 'User')
}
# Run a program with its output in the log. Windows PowerShell turns a native
# program's stderr into errors, so 'Stop' is off while it runs.
function Exec([string[]]$cmd) {
  $old = $ErrorActionPreference; $ErrorActionPreference = 'Continue'
  $rest = @($cmd | Select-Object -Skip 1)
  & $cmd[0] @rest 2>&1 | ForEach-Object { Log "$_" }
  $code = $LASTEXITCODE
  $ErrorActionPreference = $old
  return $code
}
function Run($what, [string[]]$cmd) {
  Say "  $what..."
  $code = Exec $cmd
  if ($code -ne 0) { Fail "$what failed (exit code $code)." }
}

Clear-Host
Say "Advance Wars - static recompilation setup" 'White'
Say "You need your own Advance Wars (USA) (Rev 1) ROM. It is not downloaded or shared."
Say "The first build takes a few minutes."

# ---------------------------------------------------------------- tools
Step 1 "Checking the tools the build needs"
if (-not (Get-Command git -ErrorAction SilentlyContinue)) {
  Say "  git is not installed."
  if (-not (Ask "  Install Git for Windows now (winget, about 60 MB)?")) { Fail "git is required." }
  Exec @('winget', 'install', '-e', '--id', 'Git.Git', '--accept-package-agreements', '--accept-source-agreements') | Out-Null
  Refresh-Path
  if (-not (Get-Command git -ErrorAction SilentlyContinue)) { Fail "git installed, but Windows has not picked it up yet: close this window and run Setup.cmd again." }
}
# Visual Studio is several GB with its own installer, so say what to install.
$vswhere = Join-Path ${env:ProgramFiles(x86)} 'Microsoft Visual Studio\Installer\vswhere.exe'
$vs = if (Test-Path $vswhere) { (& $vswhere -latest -products * -requires Microsoft.VisualStudio.Component.VC.Tools.x86.x64 -property installationPath) } else { $null }
if (-not $vs) { Fail "Visual Studio 2022 (or its Build Tools) with 'Desktop development with C++' is needed. Install it, then run Setup.cmd again." }
Say "  Visual Studio: $vs"
if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) {
  Say "  cmake is not installed."
  if (-not (Ask "  Install CMake now (winget, about 30 MB)?")) { Fail "cmake is required." }
  Exec @('winget', 'install', '-e', '--id', 'Kitware.CMake', '--accept-package-agreements', '--accept-source-agreements') | Out-Null
  Refresh-Path
  if (-not (Get-Command cmake -ErrorAction SilentlyContinue)) { Fail "cmake installed, but Windows has not picked it up yet: close this window and run Setup.cmd again." }
}
# SDL2 through vcpkg (build.cmd reads VCPKG_ROOT, default C:\vcpkg)
$vcpkg = if ($env:VCPKG_ROOT) { $env:VCPKG_ROOT } elseif (Test-Path 'C:\vcpkg\vcpkg.exe') { 'C:\vcpkg' } else { Join-Path $env:USERPROFILE 'vcpkg' }
if (-not (Test-Path (Join-Path $vcpkg 'vcpkg.exe'))) {
  Say "  vcpkg (used for SDL2) is not at $vcpkg."
  if (-not (Ask "  Download and bootstrap vcpkg there now (git, about 200 MB)?")) { Fail "SDL2 is required; install vcpkg and set VCPKG_ROOT." }
  Run "Cloning vcpkg" @('git', 'clone', '--depth', '1', 'https://github.com/microsoft/vcpkg', $vcpkg)
  Run "Bootstrapping vcpkg" @('cmd', '/c', (Join-Path $vcpkg 'bootstrap-vcpkg.bat'), '-disableMetrics')
}
if (-not (Test-Path (Join-Path $vcpkg 'installed\x64-windows\bin\SDL2.dll'))) {
  Say "  SDL2 is not installed in vcpkg."
  if (-not (Ask "  Build SDL2 with vcpkg now (a few minutes)?")) { Fail "SDL2 is required." }
  Run "Installing SDL2" @((Join-Path $vcpkg 'vcpkg.exe'), 'install', 'sdl2:x64-windows')
}
$env:VCPKG_ROOT = $vcpkg
Say "  vcpkg: $vcpkg"

# ---------------------------------------------------------------- toolkit
Step 2 "Fetching the gbarecomp toolkit (ext\gbarecomp)"
if (Test-Path 'ext\gbarecomp\CMakeLists.txt') { Say "  Already there (skipping)." }
elseif (Test-Path '.git') { Run "Fetching the submodule" @('git', 'submodule', 'update', '--init') }
else {
  # A plain download (no .git, so no submodule): clone the toolkit and check
  # out the commit the submodule pins. Keep $ToolkitRef equal to that pin
  # (git -C ext\gbarecomp rev-parse HEAD) whenever the submodule moves.
  $ToolkitRef = '01d4b36b2aab5985e6d553114763a8ffcdd0a5eb'
  Run "Cloning gbarecomp" @('git', 'clone', 'https://github.com/sp00nznet/gbarecomp', 'ext\gbarecomp')
  Run "Checking out the pinned toolkit" @('git', '-C', 'ext\gbarecomp', 'checkout', '-q', $ToolkitRef)
}

# ---------------------------------------------------------------- the ROM
Step 3 "Finding your ROM"
function Sha1($p) { (Get-FileHash -Algorithm SHA1 $p).Hash.ToLower() }
function Is-Rom([string]$p) { return ($p -and (Test-Path $p) -and $p -match '\.gba$' -and (Sha1 $p) -eq $RomSha1) }
New-Item -ItemType Directory -Force game | Out-Null
if ((Is-Rom 'game\aw.gba') -and -not $Force) { Say "  game\aw.gba is already there (skipping)." }
else {
  $Rom = $Rom.Trim('"', ' ')
  if (-not (Is-Rom $Rom)) {
    # Look beside the repo and in Downloads, unzipping .zip files that hold a .gba
    $Rom = ""
    foreach ($dir in @($Root, (Join-Path $env:USERPROFILE 'Downloads'))) {
      foreach ($f in (Get-ChildItem $dir -File -ErrorAction SilentlyContinue | Where-Object { $_.Extension -in '.gba', '.zip' })) {
        if ($f.Extension -eq '.gba' -and (Is-Rom $f.FullName)) { $Rom = $f.FullName; break }
        if ($f.Extension -eq '.zip') {
          $tmp = Join-Path $env:TEMP "aw-setup-$([guid]::NewGuid())"
          try { Expand-Archive $f.FullName $tmp -ErrorAction Stop } catch { continue }
          $g = Get-ChildItem $tmp -Recurse -Filter *.gba | Where-Object { Is-Rom $_.FullName } | Select-Object -First 1
          if ($g) { Copy-Item $g.FullName 'game\aw.gba' -Force; $Rom = $f.FullName }
          Remove-Item $tmp -Recurse -Force
          if ($Rom) { break }
        }
      }
      if ($Rom) { break }
    }
    if ($Rom) { Say "  Found it: $Rom" }
  }
  while (-not $Rom) {
    $p = (Read-Host "  Paste the path of your Advance Wars (USA) (Rev 1) .gba file").Trim('"', ' ')
    if (Is-Rom $p) { $Rom = $p } else { Say "  That isn't Advance Wars (USA) (Rev 1) (SHA1 $RomSha1)." 'Yellow' }
  }
  if ($Rom -match '\.gba$') { Copy-Item $Rom 'game\aw.gba' -Force }
  Say "  Copied to game\aw.gba"
}

# ---------------------------------------------------------------- build
Step 4 "Building build\b\Release\AWRE.exe (a few minutes)"
if ((Test-Path 'build\b\Release\AWRE.exe') -and -not $Force) { Say "  Already built (skipping; -Force rebuilds)." }
else { Run "Building" @('cmd', '/c', (Join-Path $Root 'build.cmd')) }

# ---------------------------------------------------------------- launcher
Step 5 "Making the launcher"
$launcher = Join-Path $Root 'Advance Wars (recomp).cmd'
Set-Content -Path $launcher -Encoding ASCII -Value "@start `"`" `"%~dp0build\b\Release\AWRE.exe`" `"%~dp0game\aw.gba`""
Say "  Double-click 'Advance Wars (recomp).cmd' to play." 'Green'
Say "  Keys: arrows, Z = A, X = B, Enter = Start, Backspace = Select, A/S = L/R."
Read-Host "Press Enter to close" | Out-Null

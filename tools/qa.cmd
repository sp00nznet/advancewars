@echo off
rem Conformance QA for netlab (and by hand): tools\qa.cmd <AWRE.exe>
rem Without the ROM (a lab test VM) it reports SKIP and exits 0, before
rem needing Python, which the test VMs don't have.
setlocal
set "ROOT=%~dp0.."
set "EXE=%~1"
if "%EXE%"=="" set "EXE=%ROOT%\build\Release\AWRE.exe"
if not exist "%ROOT%\game\aw.gba" (echo conformance: skipped -- needs the ROM at game\aw.gba & exit /b 0)
py -3 "%ROOT%\ext\gbarecomp\tools\conformance.py" --exe "%EXE%" --rom "%ROOT%\game\aw.gba" --baseline "%ROOT%\conformance_baseline.txt" --input "%ROOT%\tools\title.txt" --frames 760
exit /b %ERRORLEVEL%

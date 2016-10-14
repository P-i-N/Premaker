@echo off

if exist premake5.exe (
  set FOUND=%cd%
) else (
  for %%X in (premake5.exe) do (set FOUND=%%~$PATH:X)
)

if not defined FOUND (
  echo Premake5 executable not found!
  echo Copy premake5.exe to Premaker^'s folder or PATH folder.
  goto done
)

if [%1]==[] goto autodetect 

set GENERATOR=%1
goto run

:autodetect
set GENERATOR=""

rem Detect Visual Studio 2015
rem -------------------------
if exist "C:\Program Files (x86)\Microsoft Visual Studio 14.0\VC\bin" (
  set GENERATOR="vs2015"
  echo Visual Studio 2015 detected!
) else (
  set GENERATOR=%GENERATOR%
)

if %GENERATOR%=="" (
  echo Visual Studio not detected! You must specify a premake generator manually.
  goto done
)

:run
if exist premaker.lua (
  premake5 --file=premaker.lua --cwd=%cd% %GENERATOR%
) else (
  premake5 --file=../Premaker/premaker.lua --cwd=%cd% %GENERATOR%
)

:checkerror
if %ERRORLEVEL% == 1 (
  rem Something went wrong! Pause, so user can read the error message...
  pause
)

:done

@echo off
setlocal
cd /d "%~dp0.."
set "PROJ=%CD%"
set "GODOT="
if exist "%USERPROFILE%\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" (
  set "GODOT=%USERPROFILE%\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
)
if not defined GODOT (
  for /f "delims=" %%G in ('dir /b /s "%USERPROFILE%\Downloads\*console.exe" 2^>nul ^| findstr /i "Godot"') do (
    set "GODOT=%%G"
    goto :godot_found
  )
)
:godot_found
if not defined GODOT (
  echo Godot executable not found.
  exit /b 2
)
echo Using Godot: %GODOT%
echo.
echo === V2.09 Phase 2 Domain QA ===
"%GODOT%" --headless --path "%PROJ%" res://V209WorldDomainQaHost.tscn
set "DOM=%ERRORLEVEL%"
if not "%DOM%"=="0" exit /b %DOM%
echo.
echo === V2.09 Phase 2 Runtime QA (rendering required) ===
"%GODOT%" --path "%PROJ%" res://V209WorldRuntimeQaHost.tscn
exit /b %ERRORLEVEL%

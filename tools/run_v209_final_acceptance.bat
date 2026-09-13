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
set "START_MS=%TIME%"
echo.
echo === V2.09 Final Domain QA (World 11 tests) ===
"%GODOT%" --headless --path "%PROJ%" res://V209WorldDomainQaHost.tscn
set "DOM_WORLD=%ERRORLEVEL%"
if not "%DOM_WORLD%"=="0" exit /b %DOM_WORLD%
echo.
echo === V2.09 Final Domain QA (Inventory 28 tests) ===
"%GODOT%" --headless --path "%PROJ%" res://V207ItemDomainQaHost.tscn
set "DOM_ITEM=%ERRORLEVEL%"
if not "%DOM_ITEM%"=="0" exit /b %DOM_ITEM%
echo.
echo === V2.09 Final Runtime QA (15-encounter flow + visual) ===
"%GODOT%" --path "%PROJ%" res://V209WorldRuntimeQaHost.tscn
set "RUN_WORLD=%ERRORLEVEL%"
if not "%RUN_WORLD%"=="0" exit /b %RUN_WORLD%
echo.
echo === V2.09 Final Inventory Runtime QA ===
"%GODOT%" --path "%PROJ%" res://V207InventoryRuntimeQaHost.tscn
set "RUN_ITEM=%ERRORLEVEL%"
if not "%RUN_ITEM%"=="0" exit /b %RUN_ITEM%
echo.
echo === Aggregate Final Acceptance Report ===
py -3 "%PROJ%\tools\aggregate_v209_final_qa.py"
exit /b %ERRORLEVEL%

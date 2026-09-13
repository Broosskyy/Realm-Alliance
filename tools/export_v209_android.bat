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
if not exist "%PROJ%\builds\android" mkdir "%PROJ%\builds\android"
echo Exporting Android Test APK...
"%GODOT%" --headless --path "%PROJ%" --export-debug "Android Test" "%PROJ%\builds\android\RealmAlliance_V2_09_Test.apk"
exit /b %ERRORLEVEL%

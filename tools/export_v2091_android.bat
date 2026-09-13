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
echo Exporting V2.09.1 Android Test APK (size-optimized)...
"%GODOT%" --headless --path "%PROJ%" --export-debug "Android Test" "%PROJ%\builds\android\RealmAlliance_V2_09_1_SizeTest_Tier1.apk"
set "T1=%ERRORLEVEL%"
if not "%T1%"=="0" exit /b %T1%
copy /Y "%PROJ%\builds\android\RealmAlliance_V2_09_1_SizeTest_Tier1.apk" "%PROJ%\builds\android\RealmAlliance_V2_09_1_Test.apk" >nul
exit /b 0

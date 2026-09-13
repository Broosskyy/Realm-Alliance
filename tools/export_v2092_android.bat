@echo off
setlocal
cd /d "%~dp0.."
set "PROJ=%CD%"
set "BT=%LOCALAPPDATA%\Android\Sdk\build-tools\36.0.0"
set "ADB=%LOCALAPPDATA%\Android\Sdk\platform-tools\adb.exe"
set "GODOT="
if exist "%USERPROFILE%\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe" (
  set "GODOT=%USERPROFILE%\Downloads\Godot_v4.7.2-stable_win64.exe\Godot_v4.7.2-stable_win64_console.exe"
)
if not defined GODOT (
  echo Godot executable not found.
  exit /b 2
)
if not exist "%PROJ%\builds\android" mkdir "%PROJ%\builds\android"
set "APK=%PROJ%\builds\android\RealmAlliance_V2_09_2_Test.apk"
set "RC=%PROJ%\builds\android\RealmAlliance_V2_09_2_RC.apk"
echo Exporting V2.09.2 signed Android Test APK...
"%GODOT%" --headless --path "%PROJ%" --export-debug "Android Test" "%RC%"
if errorlevel 1 exit /b 1
copy /Y "%RC%" "%APK%" >nul
echo Validating signature...
"%BT%\apksigner.bat" verify --verbose --print-certs "%APK%"
if errorlevel 1 (
  echo ERROR: apksigner verify FAILED
  exit /b 3
)
"%BT%\zipalign.bat" -c -v 4 "%APK%" >nul
if errorlevel 1 (
  echo ERROR: zipalign verify FAILED
  exit /b 4
)
echo APK validation PASS
exit /b 0

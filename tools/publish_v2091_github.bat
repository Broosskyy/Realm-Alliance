@echo off
setlocal
cd /d "%~dp0.."

git push -u origin main
if errorlevel 1 exit /b 1

set APK=builds\android\RealmAlliance_V2_09_1_Test.apk
if not exist "%APK%" (
  echo ERROR: APK missing
  exit /b 1
)

gh release view v2.09.1-test >nul 2>&1
if errorlevel 1 (
  gh release create v2.09.1-test --target main --title "REALM ALLIANCE V2.09.1 Test" --notes-file "docs\v2091_release_notes.md" "%APK%#RealmAlliance_V2_09_1_Test.apk"
) else (
  gh release upload v2.09.1-test "%APK%#RealmAlliance_V2_09_1_Test.apk" --clobber
)

gh release view v2.09.1-test

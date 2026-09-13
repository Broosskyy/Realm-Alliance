@echo off
setlocal
cd /d "%~dp0.."

echo === V2.09 GitHub Publish ===
echo Commit: 79dc8ce63a4caeba4c486aca90ad77bf3a63b69d
echo.

git push -u origin main
if errorlevel 1 exit /b 1

git rev-parse HEAD
git ls-remote origin refs/heads/main

set APK=builds\android\RealmAlliance_V2_09_Test.apk
if not exist "%APK%" (
  echo ERROR: APK missing: %APK%
  exit /b 1
)

gh release view v2.09.0-test >nul 2>&1
if errorlevel 1 (
  gh release create v2.09.0-test ^
    --target main ^
    --title "REALM ALLIANCE V2.09 Test" ^
    --notes-file "docs\v209_release_notes.md" ^
    "%APK%#RealmAlliance_V2_09_Test.apk"
) else (
  echo Release tag exists — uploading asset if missing...
  gh release upload v2.09.0-test "%APK%#RealmAlliance_V2_09_Test.apk" --clobber
)

gh release view v2.09.0-test
echo.
echo Done. Verify download URL above.

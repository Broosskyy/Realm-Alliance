# REALM ALLIANCE 723 – OTA device smoke test
- This small Android version 723 exists to verify automatically loading an APK in installed 722.
- Same package id and certificate, same save migration, unchanged gameplay; version number only.
- On installed 722: startup should check test-channel manifest and auto-download 723 via threaded HTTPRequest, show percentage/MiB, verify exact SHA256, then open Android Installer.
- Never remove existing app or reset game data. Installation approval via Android system dialog remains necessary.
- 723 GitHub Release must be fully signed and uploaded BEFORE changing distribution manifest.
- Android device test is NOT done by CI; user should report whether installer opens and saved progress persists.

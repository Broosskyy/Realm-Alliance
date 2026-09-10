# Android test builds

Installable debug APKs for device QA are published as **GitHub Release assets** (APK files exceed GitHub’s 100 MB single-file limit).

Latest V2.01 device test build: see release `v2.01-device-test` and download `RealmAlliance_V2_01_Test.apk`.

Local export (Godot 4.7.2):

```powershell
tools\godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --export-debug "Android Test" builds/android/RealmAlliance_V2_01_Test.apk
```

Package: `com.realmalliance.prototype` · version `2.01.0` (code 201)

Note: `.apk.idsig` is a signature sidecar only — not installable. Use the `.apk` file.

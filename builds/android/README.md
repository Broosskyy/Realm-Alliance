# Android test builds

Installable debug APKs for device QA are published as **GitHub Release assets** (APK files exceed GitHub’s 100 MB single-file limit).

**Latest:** `RealmAlliance_V2_02_Test.apk` — V2.02 runtime recovery (release gate passed).

Local export (Godot 4.7.2):

```powershell
tools/godot/Godot_v4.7.2-stable_win64_console.exe --headless --path . --export-debug "Android Test" builds/android/RealmAlliance_V2_02_Test.apk
```

Runtime acceptance (required before APK release):

```powershell
tools/godot/Godot_v4.7.2-stable_win64_console.exe --path . --scene res://V202RuntimeAcceptanceHost.tscn --display-driver windows --audio-driver Dummy
```

Package: `com.realmalliance.prototype` · version `2.02.0` (code 202)

Note: `.apk.idsig` is a signature sidecar only — not installable. Use the `.apk` file.

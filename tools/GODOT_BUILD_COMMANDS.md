# Godot CLI build commands

Run from the project root after installing Godot 4.x and matching export templates.

## Parser / project import smoke test
```bash
godot --headless --path . --editor --quit
```

## Android test APK
```bash
godot --headless --path . --export-debug "Android Test" "build/android/RealmAlliance_V1_8_Test.apk"
```

## Web test build
```bash
godot --headless --path . --export-debug "Web Test" "build/web/index.html"
```

If your executable is named `godot4`, substitute that command.

Do not treat a successful static preflight as an engine runtime test.

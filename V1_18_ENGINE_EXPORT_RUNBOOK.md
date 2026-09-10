# REALM ALLIANCE V1.18 — ENGINE / EXPORT SMOKE RUNBOOK

V1.18 is the first source package prepared specifically for a real Godot/Android/Web smoke test.
It does not claim runtime PASS because no Godot binary is available in the build environment used to prepare this source.

## Godot editor smoke
1. Open `project.godot` in Godot 4.x compatible with the project feature set.
2. Confirm `MainGame.tscn` is the startup scene.
3. Run the project once from the editor.
4. There must be no parser error, missing autoload, missing resource, invalid node-path, or startup exception.
5. Confirm visible P0 navigation is Home / Rad / Dorf only.

## Android test export
1. Install Android export templates if Godot requests them.
2. Use preset `Android Test`.
3. Export to `build/android/RealmAlliance_V1_18_Test.apk`.
4. Install on device.
5. Confirm portrait orientation, immersive mode, touch input, safe areas and readable UI.
6. Run the complete `V1_17_P0_RC_DEVICE_RUNBOOK.md`.

## Web test export
1. Use preset `Web Test`.
2. Export to `build/web/index.html`.
3. Serve through HTTP rather than opening the HTML directly.
4. Test Home / Wheel / Village, save behavior supported by the browser environment, resizing and touch emulation.

## Debug/release separation
`P0TestHarness` is allowed in the source tree but must only enable itself when `OS.is_debug_build()` is true.
The TEST UI must not be visible in a release export.

## Stop conditions
Do not move to P1 if the engine reports parser/startup errors, the APK cannot export/install, the first 10 encounters cannot be completed, save/recovery fails, input locks stick, resources duplicate, or P1 UI leaks into the P0 build.

# REALM ALLIANCE SOURCE V1.18
## P0 ENGINE / EXPORT SMOKE READINESS — Master V1.4

No new assets. No P1 enablement. No gameplay expansion.

- Build metadata updated to V1.18 / build 28.
- Added a machine-readable engine/export manifest.
- Added static verification for main scene, autoload targets, 1080×1920 reference viewport, portrait mode, canvas_items stretch and GL compatibility renderer.
- Android preset is checked for arm64, immersive mode, package identity, output path and version metadata.
- Web test preset is checked for a valid output path.
- Debug harness isolation is explicitly validated against `OS.is_debug_build()`.
- Added source-integrity checks to prevent accidental APK/AAB/EXE/PCK binaries from being packed into source.
- Added the first explicit editor/Android/Web smoke-test runbook.
- All V1.13–V1.17 Core, feel, first-session, balance and acceptance checks remain part of the regression suite.

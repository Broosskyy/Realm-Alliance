# V2.00 Pre-APK / Device Runbook

Use V2.00 as the APK-test baseline. Do not add broad features before this pass is tested.

## Boot / first session
1. Fresh install / fresh save: boot to TAP without errors or legacy-menu flash.
2. Verify portrait layout, safe area and bottom navigation on at least one narrow and one tall Android device.
3. Complete the early loop: TAP -> reward -> TAP upgrade -> SPIN -> DORF -> MODI -> one side mode.

## Visual acceptance
- TAP monster, HP, damage, reward and defeat states remain centered and do not retain stale scale/modulate/rotation.
- REALM SPIN shows exactly three independent reels. Reel windows, symbols, machine frame, payline and win-line remain aligned on the real device resolution.
- DORF keeps four buildings readable in two columns. Decorative Greenvale world props must sit behind functional building cards and not block input.
- TD, Lane, Puzzle, Journey and Heroes use production assets without obvious placeholder flashes, clipping or stretched art.
- Bottom navigation remains TAP / SPIN / DORF / MODI only.

## State / resume
- Background/foreground during TAP, SPIN and each side mode.
- Kill app while a result is pending, relaunch, and verify MODI · FORTSETZEN restores the next deterministic pending result.
- Verify save/resume after upgrades and village actions.

## Android/export
- Open project in the intended Godot 4.x version.
- Let all imports finish before export.
- Validate Android SDK/JDK/keystore/export preset locally.
- Build a debug APK first; do not treat successful static QA as proof of runtime/export correctness.
- Capture screenshots of TAP, SPIN, DORF, MODI, Puzzle, TD, Lane and Heroes for final visual comparison.

# V1.8 BUILD READINESS

## Required locally
- Godot 4.x
- matching export templates
- Android SDK/JDK configured for Android export
- browser or local HTTP server for Web output

## First run order
1. Open/import project once.
2. Resolve any Godot parser/import errors.
3. Run `tools/preflight.py`.
4. Run Home/Tap manually.
5. Export Web Test.
6. Export Android Test.
7. Install APK on a real portrait phone.
8. Execute V1.7 mobile-device QA.
9. Execute 5/15/30 minute Core sessions.

## PASS gate
Do not add P1 features until:
- project parses
- Home/Tap works
- Wheel consumes exactly one spin
- rewards are not duplicated
- all four buildings upgrade
- boss occurs at encounter 10
- save survives app restart
- UI is readable on small portrait phone

# V1.9 ENGINE READINESS

This pass specifically reduces common first-import / first-export risks.

Local Godot test order:
1. `python tools/preflight.py`
2. open project in Godot 4.x
3. inspect parser/import errors
4. run MainGame.tscn
5. test Home -> Reward -> Wheel -> Village -> Boss
6. background and resume app
7. export Web Test
8. export Android Test
9. run V1.7 mobile QA on a real device

Do not interpret static PASS as runtime PASS.

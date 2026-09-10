# REALM ALLIANCE SOURCE V1.12
## P0 TESTABILITY / DEBUG HARNESS — Master V1.4

- added debug-only P0TestHarness autoload
- added reproducible profiles: Fresh, 5/10, Boss 10/10, Wheel, Village, Return, Low Resource
- added debug-only in-game TEST panel
- TEST UI is hidden in non-debug builds via OS.is_debug_build()
- profiles save immediately for restart/device testing
- added corrupted-primary + valid-backup recovery fixture
- added P0 debug snapshot for monster/resources/village/contract
- added structured test matrix and harness validator
- no P1 feature enabled

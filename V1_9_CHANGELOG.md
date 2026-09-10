# REALM ALLIANCE SOURCE V1.9
## GODOT 4 ENGINE HARDENING — Master V1.4

- replaced absolute DirAccess save-file helpers with user:// directory operations
- save now also triggers on application focus loss
- normalized repeatable named signal connections through _connect_once
- viewport resize connection is idempotent
- ResponsiveLayout clamps modal size against the actual viewport
- AudioService now uses a small SFX player pool instead of one interrupting player
- P0MonsterVisualSystem falls back safely if encounter JSON is missing/invalid
- BuildInfo/project/export metadata moved to V1.9 / Android code 19
- preflight expanded with duplicate-function and risky API checks
- no gameplay feature added

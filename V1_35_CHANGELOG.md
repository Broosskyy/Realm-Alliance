# REALM ALLIANCE V1.35 — Account / Profile / Cloud / Support Polish

- Continued the V1.34 entry flow without inventing a live backend.
- Added `AccountState.gd` with explicit Guest and Local Profile modes.
- Guest remains the zero-friction default and can always enter the existing local game.
- Register now validates player name, password length, password confirmation and consent, but never stores the password.
- A successful Register action creates only a local profile scaffold; secure online authentication still requires the later backend.
- Added Account & Cloud panel to the existing Settings area.
- Added Help & Legal panel with release-ready slots for Help Center, Privacy, Terms and Imprint.
- Added Guest→Account and Cloud Save status UX without pretending server synchronization exists.
- Added six replaceable Account/Support placeholder assets.
- Fixed a malformed scene boundary near the debug/region block discovered during the polish pass.
- Existing gameplay save remains authoritative and cannot be overwritten by BootFlow registration before `SaveGame.load_game()`.
- Account state is persisted as an optional V20 save field after the gameplay save is safely loaded.
- HOME / SPIN / DORF remain the primary gameplay navigation.
- Website remains excluded.

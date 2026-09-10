# REALM ALLIANCE V1.38 — Home / Combat / Responsive UI Polish

- Continued from V1.37 with a visible HOME/HUD polish pass rather than adding another game mode.
- Unified monster title rendering so `_update_monster_ui()` and `_update_monster_visual()` no longer overwrite each other with different formats.
- HOME monster header now consistently communicates MONSTER/BOSS, encounter level and encounter name.
- Tightened HP bar width and Quick Action typography for better portrait readability.
- Strengthened the HOME Realm Spin CTA wording without changing the underlying core loop.
- Damage-number placement now uses a deterministic four-position presentation cycle instead of random visual jitter.
- Reward pulse now honors Reduced Motion.
- ResponsiveLayout no longer assumes a hard-coded 1080 px spin center; reel/payline placement now derives from the current viewport width.
- ResponsiveLayout now scales the resource pills, Settings button, Quick Actions and the newer Feature/Account/Social/Support overlays.
- Corrected Settings modal responsive target to the expanded Settings layout.
- Added exactly six replaceable HOME/HUD placeholder art assets for Topbar, HP, Tap prompt, Boss alert, Reward burst and Bottom navigation.
- No new economy values, currencies or fake online data were introduced.
- HOME / SPIN / DORF remain the primary gameplay navigation.
- Website remains excluded.

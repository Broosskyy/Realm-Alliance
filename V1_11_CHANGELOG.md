# REALM ALLIANCE SOURCE V1.11
## P0 CORE ACCEPTANCE GATE — Master V1.4

- fixed P02CoreController: scene child is now referenced via $P02CoreController instead of an undeclared global
- added live Goldmine UI refresh timer while Village is open
- Save schema V18 adds generic last_seen_unix and return-duration basis
- Save writes now use temp + backup + restore-on-failure
- corrupted primary save can recover from backup
- added CoreAcceptanceService runtime contract validation
- Core Acceptance explicitly blocks P1 expansion until real runtime/device PASS
- startup no longer rebuilds hidden Daily/Quest UI when disabled
- hidden Hero/Attack/Defense refresh work removed from normal P0 refresh path
- added deterministic first-session source simulator
- preflight now catches P02 controller regression and P0 feature-flag drift
- no P1 feature enabled

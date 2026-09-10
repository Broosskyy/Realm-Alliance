# V1.84 CHANGELOG — Guild Governance / Tasks / Donations / Activity / Season Settlement

- Added GuildGovernanceService with server-owned roles, permission snapshots and member actions.
- Added GuildTaskService with server-owned guild tasks, contribution flow and transactional donations.
- Added OnlineActivityService for server-ordered activity feed and notification center.
- Notification read state is server-owned; no client-fabricated social activity.
- Added SeasonSettlementService for final PvP season rank/league/rating and payout claim flow.
- PvP season claim delegates final reward delivery to RewardLedgerService.
- Added routing for guild governance/tasks/donations/activity/notifications/season settlement.
- Save schema advanced to v30.
- No new player-facing controls or fake online identities/data.

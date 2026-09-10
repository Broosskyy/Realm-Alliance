# V1.80 CHANGELOG — Response Routing / Resilience / Social-Guild-Ranking Contracts

- Added OnlineResponseRouter for endpoint-specific HTTP response dispatch.
- Guest/session refresh responses route into AuthSessionService.
- Player sync responses stage/apply through SyncReconciliationService.
- Authority intent responses resolve pending requests and advance revision/server time.
- Added NetworkResilienceService with bounded retry, backoff and disconnect threshold.
- HTTP 401 moves auth state to refresh-required.
- Consecutive transport failures move session to OFFLINE_LIMITED.
- Added OnlineSocialService: friend list/request/accept contracts.
- Added GuildService: snapshot/create/join/leave contracts.
- Added RankingOnlineService: daily/weekly/event snapshots and claim contract.
- LiveOpsRankingSystem can consume server ranking snapshots.
- No fake friends, guild members or ranking users are created.
- Save schema advanced to v26.

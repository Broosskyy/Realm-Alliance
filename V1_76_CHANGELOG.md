# V1.76 CHANGELOG — Economy / SPIN / Save-Sync Authority

- REALM SPIN now creates an authority intent before result mutation.
- Spin RNG/reward resolution remains local only in Local Development mode; production online mode refuses client-side commit.
- Spin cost + reward are committed as one EconomyAuthorityService transaction.
- Wheel reward resolver no longer directly grants currency.
- Spin results carry authority_request_id and authority_revision.
- OnlineAuthorityService now tracks bounded pending intents and resolved request IDs for idempotency-ready sync.
- Save schema advanced to v22.
- Save timestamps use ServerClockService.
- Save contains PlayerSnapshotService sync metadata/fingerprint.
- Added EconomyAuthorityService and PlayerSnapshotService.
- No fake backend; Local Development Authority remains a replaceable adapter.

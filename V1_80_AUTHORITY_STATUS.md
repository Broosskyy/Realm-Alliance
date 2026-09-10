# V1.80 Authority Status

Transport path now:
UI/System request → service contract → authenticated HTTP transport → bounded retry/resilience → response router → domain service → validated snapshot/state.

Prepared online domains:
- Account/Auth
- Player Sync
- Gameplay Authority Intents
- Friends
- Guilds
- Rankings

Next:
- wire actual backend endpoint/provider
- implement response correlation for gameplay presentation callbacks
- remote SPIN result/RNG
- remote combat/reward result
- guild boss/co-op contracts
- async PvP contracts
- entitlement/inventory backend

# V1.44 LiveOps / UI QA

1. Halloween event is data-driven and scheduled for 20 Oct–3 Nov 2026 UTC.
2. Halloween progress uses authoritative boss-defeat commits.
3. Halloween event reward is only locally claimable while the event is active and target is complete.
4. Daily, Weekly and Event rankings expose reward previews.
5. No fake multiplayer entries are generated in the new ranking system.
6. Ranking claims are disabled without authoritative server confirmation.
7. AFK reward is created after load from `seconds_away_on_last_load`, saved before display and claimed once.
8. AFK cap is 8 hours and minimum is 2 minutes.
9. Itemshop purchases cannot grant client-side rewards while production store validation is disabled.
10. Progression Hub reads existing gameplay systems rather than duplicating progression state.
11. New overlays are modal/input-lock aware.
12. ResponsiveLayout includes LiveOps, Shop, Progression and AFK overlays.
13. V1.44 placeholder kit contains exactly 8 replaceable assets.
14. Save Schema remains V20.
15. Real server leaderboard/payment integration and device visual QA remain pending.

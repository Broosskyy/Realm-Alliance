# V1.36 Profile / Social QA

1. Social hub is secondary under Account & Cloud; primary gameplay nav is unchanged.
2. Profile snapshot reads real local progression only.
3. Inbox contains only static product/system messages, not fake player messages.
4. Inbox read state persists in Save V20 optional data.
5. Achievements are computed from existing progression and cannot duplicate-grant rewards because V1.36 achievements have no rewards.
6. Friends/Alliances explicitly state that backend service is required.
7. No fake friends, online status or network claims.
8. No invented production URLs.
9. Six Social placeholder assets are replaceable integration art.
10. Old saves without `social_hub` remain compatible.
11. Social hub can be closed without changing gameplay progression.
12. Website code remains excluded.

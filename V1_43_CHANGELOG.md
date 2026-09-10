# REALM ALLIANCE V1.43 — Shared Monster Defeat Transaction

- Replaced the temporary V1.42 defeat scaffold with an authoritative `MonsterDefeatService`.
- Manual TAP kills and Hero Auto-DPS kills now use the same reward/progression/save transaction.
- Monster reward, XP, bonus-spin chance, boss bonus Spins, boss Dice, Meta boss progress and next-monster spawn are booked in one boundary.
- Save occurs before defeat presentation, preventing rewarded HP=0 resume states.
- Each defeat receives a `defeat_id`, source attribution and config version.
- MainGame owns presentation only; HeroSystem no longer duplicates economy/progression side effects.
- Auto-DPS defeats now reach the same visible defeat/reward presentation path while HOME is visible.
- Existing boss/monster presentation, milestone hooks and reward overlays are reused.
- No economy or balance values were changed.
- Master V2.1 multi-gameplay-pillar direction remains binding.
- Save Schema remains V20.

# REALM ALLIANCE — V2.05 ABSCHLUSSREPORT

**Milestone:** V2.05.0 (build 2050)  
**Basis:** V2.04.0 QA-PASS Stand  
**Datum:** 2026-09-11  
**QA:** PASS (Smoke + Full Visual Runtime, 81.0s)  
**APK:** `builds/android/RealmAlliance_V2_05_Test.apk` (debug export, ~456 MB)

---

## STATUS

**V2.05 PASS** — Meta-Progression ist im Kernloop verankert:

Kämpfen → Objectives → Quest/Daily → Reward Pipeline → Chest → Boss → Player XP → Save/Reload.

Godot Runtime QA belegt: Event-driven Quest Progress, Claim + Duplicate-Block, Boss Failure/Retry/Victory, Chest Open + Duplicate-Block, Persistenz nach Reload.

---

## QUEST ENGINE

**Authority:** `ObjectiveSystem.gd` (nicht paralleles `QuestSystem.gd`)

- States: `LOCKED → ACTIVE → COMPLETED → CLAIMABLE → CLAIMED`
- Daten: `data/objectives_v1_52.json` (starter, daily, weekly, achievements)
- Events: `GameplayEventService` → `register_action()` (tap, crit, monster/boss defeat, upgrade, spin, afk, …)
- Claims: `RewardPipeline.grant_quest()` + idempotente `claimed_transaction_ids`
- Fix V2.05: Rekursions-Bug `quest_state ↔ row_state` behoben (Stack Overflow)

---

## DAILY

**`DailyRewards.gd`** + Objective daily pool

- Reset via `ServerClockService.day_key()` (server-ready)
- Claims über `RewardPipeline.grant_daily()`
- `claimed_day_keys` Idempotency
- UI: Daily-Tab in Quest-View, `FeatureFlags.SHOW_DAILY=true`

---

## PLAYER PROGRESSION

- XP/Level: bestehendes `PlayerData` + `RewardPipeline.grant()` XP hook
- Quellen: Monster/Boss (Pipeline), Quest/Daily (Pipeline)
- Level-Up Overlay + Unlock hooks via `UnlockService` (kein paralleles Account-System)

---

## CHESTS

**`ChestRewardSystem.gd`** + `data/chests_v205.json`

- Flow: acquire → pending → open → `RewardPipeline.grant_chest()` → opened state
- Boss-Defeat: `ChestRewardSystem.acquire_chest("boss", "boss_defeat")`
- Idempotency: `opened_chest_ids` / duplicate open rejected (QA verified)

---

## REWARD PIPELINE

**Erweitert in V2.05:**

| Quelle | Pfad |
|--------|------|
| Monster | `grant_monster_defeat()` |
| Boss | `SOURCE_BOSS_DEFEAT` |
| SPIN | `commit_spin_reward()` |
| AFK | `grant_afk()` |
| Daily | `grant_daily()` |
| Quest | `grant_quest()` |
| Chest | `grant_chest()` |

Village Goldmine weiterhin über Pipeline wo migriert; Realm-Chest Meta nutzt `grant_chest()`.

---

## BOSS UX

- **BOSS BEREIT:** `EncounterProgressService` + `boss_proximity_p0` im Main Flow
- **Failure:** Timer-Timeout → klares Failure-Overlay, Retry CTA, kein Progress-Verlust
- **QA:** Failure → Retry → Victory → `boss_defeat` Transaction

---

## ECONOMY

`tools/economy_sim_v205.py` — 5/15/30/60 Min @ 2.5 taps/s:

Combat-Netto bleibt dominante Einnahmequelle; Daily/Quest/Chest liefern ~5–15% Meta-Bonus (keine Combat-Inflation).

---

## VISUAL IMPROVEMENTS

- Quest/Daily UI in Progressions-Hub (mobile-first)
- Gemeinsame Reward-Sprache über `RewardPipeline` + bestehende Overlays
- Boss Failure/Ready Screens in Full-QA Screenshots erfasst

---

## ASSET STATUS

Production Assets wiederverwendet (HUD, Monster, Spin, Village).  
Placeholder dokumentiert für dedizierte Quest/Daily/Chest/Level-Up Production Art (keine Debug-Shapes als final deklariert).

---

## SAVE / MIGRATION

- **Save Version:** 38
- Persistiert: objectives, daily_rewards, chest_rewards, reward_pipeline, player XP/level
- V2.04 Saves: Migration getestet via QA fresh profile + reload flows

---

## ONLINE-READY

- `ServerClockService` für Daily/Reset
- `GameplayEventService` Contract (UI → Command → Domain → Authority → Result)
- Quest Definitions JSON (remote-loadable später)
- Keine Client-only Reward-Mutation außerhalb Pipeline

---

## RUNTIME QA

| Gate | Result |
|------|--------|
| Smoke QA | PASS (3/3 TAP, 18.2s) |
| Full QA | PASS (81.0s) |
| TAP determinism | 3/3 |
| Regression | boot/nav/spin/save/tap |
| Quest claim + dup block | verified |
| Daily claim + dup block | verified |
| Boss failure/retry/victory | verified |
| Chest open + dup block | verified |
| Save/Reload | verified |

Evidence: `docs/v205_visual_runtime_qa/`

---

## STATE EVIDENCE

Erweitert um: daily_bucket, daily_progress, quest_ready_count, chest_pending, player_level/xp, boss_failure, reward_transaction_id, balances before/after.

---

## SCREENSHOTS

Full QA: Main, Quest initial/progress/complete/reward, Daily, Boss Ready/Failure/Retry/Victory/Reward, Chest acquired/opening/reward, AFK, SPIN, Village, Reload, Viewport Matrix (1080×2340/2400/1920, 1440×3200).

---

## VIEWPORT MATRIX

Alle Profile PASS (1080×2340 primary flow, matrix captures für 2400/1920/3200).

---

## APK

`builds/android/RealmAlliance_V2_05_Test.apk`  
Version: **2.05.0** (code 2050)  
Export: `--export-debug "Android Test"` aus QA-PASS Source-Stand.

---

## REMAINING ISSUES

1. **P0 Boot Drift Warning** — QA direct MainGame load (`qa_direct_main_load`), non-blocking
2. **Lambda capture freed** — sporadisch in QA logs, non-blocking
3. **Legacy `QuestSystem.gd`** — noch in Save-Schema, nicht mehr Primary
4. **Release Keystore** — Debug-APK exportiert; Release-Signing separat konfigurieren
5. **Heroes** — bewusst nicht ausgebaut (nächster Milestone)

---

## NEXT

- Heroes Milestone (Lifecycle, Datenmodell, Unlock)
- Remote Quest/Daily Content Loading
- Server-authoritative Daily reset + claim validation
- Production Assets für Quest/Daily/Chest/Level-Up
- Release-signed Play Store APK pipeline

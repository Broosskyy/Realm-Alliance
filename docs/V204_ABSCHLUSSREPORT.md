# REALM ALLIANCE — V2.04 ABSCHLUSSREPORT

**Milestone:** V2.04.0 (build 2040)  
**Basis:** V2.03 QA-PASS Stand  
**Datum:** 2026-09-11  
**QA:** PASS (Full Visual Runtime, 65.8s)  
**APK:** `builds/android/RealmAlliance_V2_04_Test.apk`

---

## STATUS

**V2.04 PASS** — Godot Runtime QA belegt den vollständigen Progressionsloop:

Boot → Combat → Crit → Defeat → Reward Transaction → Upgrade → Boss Ready → Boss Fight → Boss Victory → Boss Reward → SPIN → Village → AFK Return → AFK Claim (duplicate blocked) → Save → Reload → State korrekt.

---

## REWARD PIPELINE

**Neu:** `RewardPipeline.gd` (Autoload)

Contract: `RewardSource` → `RewardDefinition` → `EconomyAuthorityService` → strukturiertes `Transaction Result` → Save/Feedback.

**Integrierte Quellen (V2.04):**
| Quelle | Pfad |
|--------|------|
| Monster Defeat | `MonsterDefeatService` → `grant_monster_defeat()` |
| Boss Defeat | `MonsterDefeatService` (boss flag) → `SOURCE_BOSS_DEFEAT` |
| SPIN | `WheelSystem` → `commit_spin_reward()` |
| AFK | `AfkRewardSystem` → `grant_afk()` |

**Transaction Result Felder:** `source`, `transaction_id`, `reward`, `balances_before/after`, `authority_request_id`, `timestamp_unix`, `ok`, `metadata`.

**Noch nicht migriert (bewusst):** Daily, Quests, Chests, Events — Konstanten/Hook vorbereitet, keine Scope-Explosion.

---

## AFK

**`AfkRewardSystem.gd`** — vollständiger Offline-Loop:

- Persistenz: `pending_reward`, `claimed_claim_ids`, `claim_sequence`, `last_prepared_seconds`
- Cap: `GameConfig.AFK_MIN_SECONDS` (120s) / `AFK_MAX_SECONDS` (8h)
- Berechnung: `GameConfig.afk_gold_for_seconds()` mit Progression + Village-Multiplier
- Idempotency: `claim_id` + `claimed_claim_ids` — QA verifiziert duplicate claim block
- UI: `AfkReturnP0` / `AfkClaimP0` in MainGame, kein Popup bei <2min Abwesenheit

**QA Evidence:** 600s offline → 80 gold → claim 2716→2796 → reload behält 2796.

---

## BOSS

**`BossChallengeSystem.gd`** (Autoload):

- Timer: `GameConfig.boss_time_limit_seconds()` (45s base, skaliert pro Zyklus)
- Flow: Intro → `start_challenge()` → tick → defeat/failure → retry ohne kaputten State
- Scaling: `BOSS_HP_MULTIPLIER` (2.35), `BOSS_REWARD_MULTIPLIER` (3.2) in `GameConfig`
- Presentation: Boss-Intro, Timer auf `BossProximityP0`, Defeat-Feedback, Reward via Pipeline

**QA Evidence:** B001 @ stage 10, timer ~45s, boss_defeat txn `boss_defeat_*`, gold 1900→2476, stage reset M010.

---

## PROGRESSION

**`EncounterProgressService`:** Region · Stage · Boss-Proximity Labels (`X / 10 BIS BOSS`, `BOSS BEREIT`).

Boss-Zyklus: Encounter 1–9 → Boss (level % 10 == 0) → Victory → nächster Abschnitt.

---

## ECONOMY / BALANCE

**`GameConfig.gd` Tuning (V2.04):**
- TAP upgrade: 220 base, +5 damage/level
- Monster reward: 40 + 14×level
- Crit spin chance: 22%
- AFK: 8 gold/min base + 2/level progression

**Offline-Simulation** (`tools/economy_sim_v204.py`, 2.5 taps/s):
| Fenster | Kills | Upgrades | Tap Lv | Damage | Gold |
|---------|-------|----------|--------|--------|------|
| 5 min   | 37    | 7        | 8      | 45     | 2803 |
| 15 min  | 52    | 8        | 9      | 50     | 8476 |
| 30 min  | 62    | 9        | 10     | 55     | 6776 |

Regelmäßige Upgrades ohne permanentes Button-Spamming; Feintuning weiter über GameConfig.

---

## SPIN / VILLAGE INTEGRATION

- **SPIN:** Rewards via `RewardPipeline.commit_spin_reward()` — QA: `reward_source=spin`, gold 2476→2716
- **Village → AFK:** `P0VillageSystem.goldmine_rate_per_minute()` modifiziert AFK-Rate (bis +35% über Referenz 30/min)

---

## VISUAL IMPROVEMENTS

- Boss-Timer + Proximity-Label auf Main HUD
- AFK Return/Claim Overlay (kompakt, hochwertiger Backdrop)
- Konsistentes Reward-Feedback via `RewardProgressionVisualDirectorV193`
- 24 Runtime-Screenshots + Viewport-Matrix (1080×2340, 2400, 1920, 1440×3200) — alle PASS

---

## SAVE / MIGRATION

**`SaveGame.gd` SAVE_VERSION = 37**

Neue persistierte Blöcke: `boss_challenge`, `reward_pipeline`, `afk_reward` (pending/claimed).

V2.03 Save → Migration → Reload verifiziert (gold 2796, M010, afk claimed).

---

## ONLINE-READY ARCHITECTURE

- UI → Service/Authority → Transaction Result → Feedback (kein direktes `gold +=` für Gameplay-Rewards)
- `OnlineAuthorityService` Intent + `EconomyAuthorityService` duplicate-request guard
- Transaction IDs + `authority_request_id` für spätere Server-Validierung
- AFK: Client-berechnet, `claim_id` idempotent

---

## RUNTIME QA

| Gate | Ergebnis |
|------|----------|
| TAP determinism | 3/3 PASS |
| Regression (boot/nav/save/spin/tap) | all true |
| Full flow V2.04 | PASS |
| Viewport matrix | PASS (alle 4) |
| Elapsed | 65.8s |

**Evidence:** `docs/v204_visual_runtime_qa/visual_acceptance_report.json`, `state_evidence.json`, Screenshots PNG.

---

## STATE EVIDENCE (Auszug)

| Step | reward_source | gold before→after | encounter |
|------|---------------|-------------------|-----------|
| defeat_reward | monster_defeat | 300→354 | M002 |
| upgrade_bought | — | 354→134 (spend) | tap L2, dmg 15 |
| boss_victory | boss_defeat | 1900→2476 | M010 |
| spin_result | spin | 2476→2716 | — |
| afk_claim | afk | 2716→2796 | — |
| main_reload | afk | 2796 (persisted) | M010 |

---

## SCREENSHOTS

Pfad: `docs/v204_visual_runtime_qa/`

1. Main Progression — `01_main_1080x2340.png`
2. Normal Combat — `02_tap_hit_1080x2340.png`
3. Normal Reward — `03_defeat_reward_1080x2340.png`
4. Boss Ready — `12_boss_ready_1080x2340.png`
5. Boss Intro — `13_boss_intro_1080x2340.png`
6. Boss Combat — `14_boss_combat_1080x2340.png`
7. Boss Victory — `15_boss_victory_1080x2340.png`
8. Boss Reward — `16_boss_reward_1080x2340.png`
9. Stage Progression — `17_stage_progress_1080x2340.png`
10. SPIN Result — `07_spin_result_1080x2340.png`
11. Village — `08_village_1080x2340.png`
12. AFK Return — `17_afk_return_1080x2340.png`
13. AFK Claim — `18_afk_claim_1080x2340.png`
14. Main nach Reload — `19_main_reload_1080x2340.png`

---

## VIEWPORT MATRIX

| Viewport | Status |
|----------|--------|
| 1080×2340 | PASS (primary flow, 21 shots) |
| 1080×2400 | PASS |
| 1080×1920 | PASS |
| 1440×3200 | PASS |

---

## APK

| Feld | Wert |
|------|------|
| Pfad | `builds/android/RealmAlliance_V2_04_Test.apk` |
| Größe | 384 547 947 bytes (~366.9 MB) |
| Timestamp (UTC) | 2026-09-11T10:23:32Z |
| package | `com.realmalliance.prototype` |
| versionName | `2.04.0` |
| versionCode | `2040` |
| ABI | arm64-v8a |
| Export | Post-QA-PASS, gleicher Source-Stand |

---

## PRODUCTION ASSET NEEDS

| Bereich | Status |
|---------|--------|
| Boss Intro/Defeat | Bestehende Assets reused; optional dediziertes Boss-Portrait |
| AFK Overlay | Production Backdrop via `ProductionUiBinder` — dediziertes AFK-Icon optional |
| Reward VFX | Shared foundation OK; Boss-spezifischer Burst optional |

Keine KI-Assets im Milestone erzeugt.

---

## REMAINING ISSUES

1. **P0 Boot Drift Warning** — QA lädt MainGame direkt; `P0BootDiagnostics` loggt `Main scene setting drift` (nicht blockierend, `qa_direct_main_load` Flag)
2. **Lambda capture freed** — sporadisch in QA-Log bei Scene-Reload (nicht blockierend)
3. **Daily/Quests/Heroes** — FeatureFlags bleiben; lazy-init-Lifecycle für später vorbereitet, nicht implementiert
4. **Village Goldmine / Daily / Quest Rewards** — noch nicht über zentrale Pipeline (niedrige Priorität)
5. **Economy Sim** — offline Python-Snapshot; kein ingame Telemetry-Dashboard

---

## NEXT (V2.05+)

- Daily/Quest Pipeline-Migration + lazy lifecycle
- Boss Failure-Retry UX polish + dedizierte Boss-Assets
- Server-authoritative AFK validation endpoint
- Ingame economy telemetry / live tuning
- P0 Boot Drift + Lambda cleanup (QA harness hardening)

---

*Exportiert aus exakt dem QA-PASS Source-Stand. V2.03 geschlossen; V2.04 abgenommen.*

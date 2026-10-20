# REALM ALLIANCE V2 — Legacy Migration Matrix

This document is the first migration gate for the V2 web-first rebuild.

## Decision rule
Every legacy feature must be classified before migration:

- KEEP — strategically useful and already compatible enough
- ADAPT — useful, but must be redesigned for web-first / online-ready architecture
- REBUILD — product value remains, implementation should not migrate
- LATER — valid long-term feature, not required for the first playable web slice
- DROP — complexity does not justify its value

## V2 first playable slice
URL → Quick Play → Grünhain → Waldwinzling → tap combat → four visual combat states → XP/gold/item → equip → next encounter → persistent save → reload/resume.

## Legacy system migration

| Area | Decision | V2 direction |
|---|---|---|
| World / regions | ADAPT | Region-driven progression, no requirement for free-roam open world |
| Grünhain | KEEP | First playable region and calibration environment |
| Monster roster | KEEP | Existing concepts/assets are valuable content |
| 4-state monster presentation | KEEP | Idle/Ready, Attack, Hit/Damage, Defeated |
| Tap combat | ADAPT | Immediate browser-friendly core loop |
| Auto combat | LATER | Unlockable/controlled automation rather than replacing interaction immediately |
| XP / levels | ADAPT | Data-driven progression |
| Gold / currencies | ADAPT | Server-authoritative-ready economy contracts |
| Loot | ADAPT | Clear drops, rarity and progression feedback |
| Equipment | ADAPT | Data-driven items, slots and power contribution |
| Skills / builds | LATER | Preserve architecture boundary, expand after core loop |
| Bosses | ADAPT | Region milestones and repeatable encounters |
| Village | LATER | Meta hub once core combat/progression is stable |
| Wheel / reward mechanics | LATER | Re-evaluate reward cadence and economy impact |
| Item shop | LATER | Must use online-ready transaction/economy model |
| Offline / AFK rewards | LATER | Server-time-ready calculation |
| Save / resume | REBUILD | Web persistence first; account/cloud linking next |
| Accounts | REBUILD | Guest-first with later account linking |
| Guilds | LATER | Online domain, not V2.0 blocker |
| PvP | LATER | Server-authoritative only |
| PvE group systems | LATER | Online-ready boundary |
| Events / seasons | LATER | LiveOps-ready data model |
| Rankings | LATER | Server-backed |
| Existing UI foundation | ADAPT | Reuse visual language where it improves mobile web UX |
| Existing Godot implementation | REBUILD | Reference/donor, not V2 runtime foundation |

## Architecture locks

1. Web-first, mobile-first, responsive.
2. Optional installable/native app later using the same product/backend basis.
3. Quick Play must not require account creation.
4. Browser must feel like a game, not a dashboard.
5. Content is data-driven.
6. Client save is an early fallback, not the final authority for competitive/economic state.
7. Online systems must be designed around stable IDs and explicit domain contracts.
8. Legacy code is not copied blindly.

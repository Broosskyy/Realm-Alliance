# REALM ALLIANCE V2 — Web First

Technical restart for REALM ALLIANCE with a browser-first, mobile-first runtime.

## Product direction

REALM V2 is not a content reset. Existing REALM worldbuilding, monsters, regions, progression ideas and proven visual assets remain migration candidates. The runtime is rebuilt around immediate browser access and an online-ready architecture.

Primary entry:

`URL → Quick Play → Grünhain → Fight → Loot → Equip → Continue`

No download and no mandatory account before the first fight.

## Prototype 0.1

This slice intentionally stays small:

- direct browser launch
- Grünhain encounter flow
- Waldwinzling as the first enemy
- tap combat
- four enemy presentation states
- XP and level progression
- gold rewards
- item drops
- equipment/power progression
- persistent local browser save
- reset option for development/testing

## Run locally

```bash
npm install
npm run dev
```

Then open the local Vite URL.

## Build

```bash
npm run build
npm run preview
```

## Next production steps

The prototype is a foundation, not a finished architecture. Next milestones should replace placeholder presentation with production REALM assets, separate content/domain/application/UI layers further, introduce account linking and server persistence contracts, and migrate legacy systems only through the migration matrix.

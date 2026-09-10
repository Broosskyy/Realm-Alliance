# V1.4 CORE CLOSURE QA

## 5-second test
A first-time player should identify the Monster as the main action without instruction.

## Home
- Gold, Spins, Shields readable.
- Monster is largest interactive surface.
- no Daily/Quest/Hero/Attack/Defense clutter.
- Wheel CTA is obvious when Spins exist.
- Dorf remains one clear secondary destination.

## Wheel
- 1 Spin is consumed.
- rotation starts and clearly stops.
- one reward resolves.
- reward overlay has one obvious Continue action.
- attack/defense prototype fields still resolve into useful fallback rewards.

## Village
- exactly four P0 building choices.
- tap building -> price/effect -> VERBESSERN.
- level 1/2/3 visual changes.
- no placement, workers, queues or production-chain UI.

## Boss
- Boss at each 10th encounter.
- intro short.
- B001 uses boss visual states.
- defeat celebration stronger.
- boss reward grants +2 Spins and chest highlight.

## P1 isolation
- hidden Hero Auto-DPS does not damage P0 monsters.
- hidden modes cannot start without explicit future activation.

## Responsive manual tests
- 720×1600
- 1080×1920
- 1080×2400

## Session tests
- 5 minutes: loop understood?
- 15 minutes: wheel/village motivating?
- 30 minutes: voluntary repeat or fatigue?

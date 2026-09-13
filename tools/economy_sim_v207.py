#!/usr/bin/env python3
"""V2.07 equipment power budget simulation (baseline vs common vs rare loadouts)."""
import json
from pathlib import Path

MONSTER_BASE_HP = 100
MONSTER_HP_GROWTH = 1.085
BOSS_MULT = 2.35
TAP_START = 10
HERO_BASE = 6
HERO_SCALING = 4
HERO_INTERVAL = 1.0

LOADOUTS = {
    "baseline": {"tap_flat": 0, "hero_flat": 0, "boss_pct": 0},
    "common_early": {"tap_flat": 15, "hero_flat": 8, "boss_pct": 0},
    "rare_geared": {"tap_flat": 22, "hero_flat": 14, "boss_pct": 5, "crit_flat": 2},
}


def monster_hp(level: int) -> int:
    hp = round(MONSTER_BASE_HP * (MONSTER_HP_GROWTH ** max(level - 1, 0)))
    if level % 10 == 0:
        hp = round(hp * BOSS_MULT)
    return int(hp)


def simulate(minutes: float, loadout: dict, taps_per_sec: float = 2.5, hero_level: int = 3):
    sec = minutes * 60
    tap_dmg = TAP_START + int(loadout.get("tap_flat", 0))
    hero_dmg = HERO_BASE + HERO_SCALING * (hero_level - 1) + int(loadout.get("hero_flat", 0))
    boss_pct = float(loadout.get("boss_pct", 0)) / 100.0
    mlv = 1
    hp = monster_hp(mlv)
    kills = 0
    t = 0.0
    tap_cd = 1.0 / taps_per_sec
    next_tap = 0.0
    next_hero = HERO_INTERVAL
    boss_kills = 0
    while t < sec:
        if t >= next_hero and hp > 0:
            dmg = hero_dmg
            if mlv % 10 == 0:
                dmg = int(round(dmg * (1.0 + boss_pct)))
            hp -= dmg
            next_hero += HERO_INTERVAL
            if hp <= 0:
                kills += 1
                if mlv % 10 == 0:
                    boss_kills += 1
                mlv += 1
                hp = monster_hp(mlv)
        if t >= next_tap and hp > 0:
            hp -= tap_dmg
            next_tap += tap_cd
            if hp <= 0:
                kills += 1
                if mlv % 10 == 0:
                    boss_kills += 1
                mlv += 1
                hp = monster_hp(mlv)
        t += 0.05
    combined_dps = tap_dmg * taps_per_sec + hero_dmg / HERO_INTERVAL
    return {
        "minutes": minutes,
        "loadout": loadout,
        "tap_dps": round(tap_dmg * taps_per_sec, 1),
        "hero_dps": round(hero_dmg / HERO_INTERVAL, 1),
        "combined_dps": round(combined_dps, 1),
        "kills": kills,
        "boss_kills": boss_kills,
        "monster_level_end": mlv,
    }


def main() -> None:
    report = {"version": "v2.07-equipment-sim", "scenarios": []}
    for minutes in (5, 15, 30, 60):
        block = {"minutes": minutes, "results": {}}
        for name, loadout in LOADOUTS.items():
            block["results"][name] = simulate(minutes, loadout)
        report["scenarios"].append(block)
    out = Path(__file__).resolve().parents[1] / "docs" / "v207_economy_sim" / "equipment_power_report.json"
    out.parent.mkdir(parents=True, exist_ok=True)
    out.write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(json.dumps({"ok": True, "path": str(out), "scenarios": len(report["scenarios"])}, indent=2))


if __name__ == "__main__":
    main()

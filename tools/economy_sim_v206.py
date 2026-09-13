#!/usr/bin/env python3
"""V2.06 progression sim: TAP vs Hero vs Combined."""
import math

MONSTER_BASE_HP = 100
MONSTER_HP_GROWTH = 1.085
MONSTER_BASE_REWARD = 40
MONSTER_REWARD_PER_LEVEL = 14
TAP_START = 10
TAP_GAIN = 5
TAP_COST_BASE = 220
TAP_COST_GROWTH = 1.65
HERO_BASE = 6
HERO_SCALING = 4
HERO_INTERVAL = 1.0
BOSS_MULT = 2.35

def monster_hp(level: int) -> int:
    hp = round(MONSTER_BASE_HP * (MONSTER_HP_GROWTH ** max(level - 1, 0)))
    if level % 10 == 0:
        hp = round(hp * BOSS_MULT)
    return int(hp)

def monster_reward(level: int) -> int:
    return MONSTER_BASE_REWARD + max(level, 1) * MONSTER_REWARD_PER_LEVEL

def tap_cost(lv: int) -> int:
    return int(round(TAP_COST_BASE * (TAP_COST_GROWTH ** max(lv - 1, 0))))

def simulate(minutes: float, taps_per_sec: float, hero_power: int, hero_interval: float, mode: str):
    sec = minutes * 60
    gold = 300
    tap_lv = 1
    tap_dmg = TAP_START
    hero_lv = 1
    mlv = 1
    hp = monster_hp(mlv)
    kills = 0
    t = 0.0
    tap_cd = 1.0 / taps_per_sec
    hero_cd = hero_interval
    next_tap = 0.0
    next_hero = hero_interval
    while t < sec:
        if mode in ("hero", "combined") and t >= next_hero and hp > 0:
            hp -= hero_power
            next_hero += hero_cd
            if hp <= 0:
                gold += monster_reward(mlv)
                kills += 1
                mlv += 1
                hp = monster_hp(mlv)
        if mode in ("tap", "combined") and t >= next_tap and hp > 0:
            hp -= tap_dmg
            next_tap += tap_cd
            if hp <= 0:
                gold += monster_reward(mlv)
                kills += 1
                mlv += 1
                hp = monster_hp(mlv)
                cost = tap_cost(tap_lv)
                if gold >= cost:
                    gold -= cost
                    tap_lv += 1
                    tap_dmg += TAP_GAIN
        t += 0.05
    return {"mode": mode, "minutes": minutes, "kills": kills, "gold": gold, "tap_lv": tap_lv, "mlv": mlv}

if __name__ == "__main__":
    for m in (5, 15, 30, 60):
        print(f"\n=== {m} min ===")
        for mode in ("tap", "hero", "combined"):
            hpwr = HERO_BASE + HERO_SCALING * 0
            print(simulate(m, 2.5, hpwr, HERO_INTERVAL, mode))

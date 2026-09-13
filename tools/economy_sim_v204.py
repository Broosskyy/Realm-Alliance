#!/usr/bin/env python3
"""V2.04 early-progression balance snapshot (offline, mirrors GameConfig.gd)."""
import math

MONSTER_BASE_HP = 100
MONSTER_HP_GROWTH = 1.085
MONSTER_BASE_REWARD = 40
MONSTER_REWARD_PER_LEVEL = 14
BONUS_SPIN_CHANCE = 0.22
TAP_UPGRADE_BASE_COST = 220
TAP_UPGRADE_COST_GROWTH = 1.65
TAP_DAMAGE_GAIN = 5
TAP_START_DAMAGE = 10
BOSS_HP_MULT = 2.35
BOSS_REWARD_MULT = 3.2
AFK_GOLD_PER_MIN = 8
AFK_MIN_SEC = 120

def monster_hp(level: int) -> int:
    hp = round(MONSTER_BASE_HP * (MONSTER_HP_GROWTH ** max(level - 1, 0)))
    if level % 10 == 0:
        hp = round(hp * BOSS_HP_MULT)
    return int(hp)

def monster_reward(level: int) -> int:
    r = MONSTER_BASE_REWARD + max(level, 1) * MONSTER_REWARD_PER_LEVEL
    if level % 10 == 0:
        r = round(r * BOSS_REWARD_MULT)
    return int(r)

def tap_cost(tap_level: int) -> int:
    return int(round(TAP_UPGRADE_BASE_COST * (TAP_UPGRADE_COST_GROWTH ** max(tap_level - 1, 0))))

def simulate(minutes: float, taps_per_sec: float = 2.5):
    sec = minutes * 60
    gold = 300
    tap_level = 1
    tap_damage = TAP_START_DAMAGE
    monster_level = 1
    monster_hp_cur = monster_hp(monster_level)
    kills = 0
    upgrades = 0
    elapsed = 0.0
    tap_interval = 1.0 / taps_per_sec
    while elapsed < sec:
        monster_hp_cur -= tap_damage
        elapsed += tap_interval
        if monster_hp_cur <= 0:
            gold += monster_reward(monster_level)
            kills += 1
            monster_level += 1
            monster_hp_cur = monster_hp(monster_level)
            cost = tap_cost(tap_level)
            if gold >= cost:
                gold -= cost
                tap_level += 1
                tap_damage += TAP_DAMAGE_GAIN
                upgrades += 1
    return {
        "minutes": minutes,
        "kills": kills,
        "upgrades": upgrades,
        "gold": gold,
        "tap_level": tap_level,
        "tap_damage": tap_damage,
        "monster_level": monster_level,
        "afk_10min": int(round(10 * AFK_GOLD_PER_MIN)),
    }

if __name__ == "__main__":
    for m in (5, 15, 30):
        s = simulate(m)
        print(f"--- {m} min @ 2.5 taps/s ---")
        for k, v in s.items():
            print(f"  {k}: {v}")

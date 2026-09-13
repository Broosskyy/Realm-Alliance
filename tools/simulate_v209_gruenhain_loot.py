#!/usr/bin/env python3
"""Monte Carlo loot rolls for V2.09 Grünhain encounter cycle."""
import json
import random
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
CATALOG = ROOT / "data" / "encounters_greenvale_p0_v1_4.json"
OUT = ROOT / "docs" / "v209_balance" / "loot_simulation_phase2.json"
RUNS = 10000


def encounter_ids(catalog: dict) -> list[str]:
    rotation = catalog["rotation"]
    boss_every = int(catalog["boss_every_kills"])
    bosses = catalog.get("boss_rotation", ["B001"])
    seq = []
    for level in range(1, boss_every + 1):
        if level % boss_every == 0:
            boss_index = max((level // boss_every) - 1, 0) % len(bosses)
            seq.append(bosses[boss_index])
        else:
            idx = level - 1 - ((level - 1) // boss_every)
            if idx < len(rotation):
                seq.append(rotation[idx])
            else:
                overflow = catalog.get("rotation_overflow", [])
                seq.append(overflow[(idx - len(rotation)) % len(overflow)])
    return seq


def roll_chance(catalog: dict, monster_id: str) -> float:
    for entry in catalog.get("monsters", []):
        if entry.get("id") == monster_id:
            return float(entry.get("stats", {}).get("loot_roll_chance", 0.0))
    return 0.0


def loot_source(catalog: dict, monster_id: str) -> str:
    for entry in catalog.get("monsters", []):
        if entry.get("id") == monster_id:
            return str(entry.get("stats", {}).get("loot_source", ""))
    return ""


def main() -> None:
    catalog = json.loads(CATALOG.read_text(encoding="utf-8"))
    seq = encounter_ids(catalog)
    elite_level = next(i + 1 for i, mid in enumerate(seq) if mid == "M010")

    no_item_before_elite = 0
    has_item_before_elite = 0
    three_plus_before_elite = 0
    first_index_hist: dict[int, int] = {}
    items_before_boss_hist: dict[int, int] = {}
    source_contrib = {"greenvale_normal": 0, "greenvale_tough": 0, "greenvale_elite": 0, "greenvale_boss": 0}

    for run in range(RUNS):
        rng = random.Random(run + 1)
        items = 0
        first_index = None
        for level in range(1, elite_level):
            mid = seq[level - 1]
            chance = roll_chance(catalog, mid)
            if chance <= 0.0:
                continue
            if rng.random() <= chance:
                items += 1
                source = loot_source(catalog, mid)
                if source in source_contrib:
                    source_contrib[source] += 1
                if first_index is None:
                    first_index = level
        if items == 0:
            no_item_before_elite += 1
        else:
            has_item_before_elite += 1
        if items >= 3:
            three_plus_before_elite += 1
        if first_index is not None:
            first_index_hist[first_index] = first_index_hist.get(first_index, 0) + 1

        boss_level = len(seq)
        total_before_boss = 0
        for level in range(1, boss_level):
            mid = seq[level - 1]
            chance = roll_chance(catalog, mid)
            if chance > 0.0 and rng.random() <= chance:
                total_before_boss += 1
        items_before_boss_hist[total_before_boss] = items_before_boss_hist.get(total_before_boss, 0) + 1

    report = {
        "runs": RUNS,
        "catalog_version": catalog.get("version"),
        "encounter_count": len(seq),
        "elite_level": elite_level,
        "pct_no_item_before_elite": no_item_before_elite / RUNS,
        "pct_has_item_before_elite": has_item_before_elite / RUNS,
        "pct_three_plus_before_elite": three_plus_before_elite / RUNS,
        "first_item_index_histogram": {str(k): v for k, v in sorted(first_index_hist.items())},
        "items_before_boss_histogram": {str(k): v for k, v in sorted(items_before_boss_hist.items())},
        "source_contribution_rolls": source_contrib,
        "sequence": seq,
    }
    OUT.parent.mkdir(parents=True, exist_ok=True)
    OUT.write_text(json.dumps(report, indent=2), encoding="utf-8")
    print(json.dumps({
        "pct_no_item_before_elite": round(report["pct_no_item_before_elite"], 4),
        "pct_has_item_before_elite": round(report["pct_has_item_before_elite"], 4),
        "pct_three_plus_before_elite": round(report["pct_three_plus_before_elite"], 4),
        "elite_level": elite_level,
    }))


if __name__ == "__main__":
    main()

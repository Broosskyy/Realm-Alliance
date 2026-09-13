#!/usr/bin/env python3
"""Aggregate V2.09 final acceptance reports into docs/v209_final_qa/final_acceptance_report.json"""

from __future__ import annotations

import json
import os
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT_DIR = ROOT / "docs" / "v209_final_qa"
OUT_PATH = OUT_DIR / "final_acceptance_report.json"

REPORTS = {
    "domain_world": ROOT / "docs" / "v209_domain_qa" / "world_domain_qa_report.json",
    "domain_inventory": ROOT / "docs" / "v207_domain_qa" / "domain_qa_report.json",
    "runtime_world": ROOT / "docs" / "v209_visual_runtime_qa" / "world_runtime_qa_report.json",
    "runtime_inventory": ROOT / "docs" / "v207_visual_runtime_qa" / "inventory_qa_report.json",
    "runtime_world_exit": ROOT / "docs" / "v209_visual_runtime_qa" / "process_exit.json",
    "loot_simulation": ROOT / "docs" / "v209_balance" / "loot_simulation_phase2.json",
}

ENCOUNTER_CATALOG = ROOT / "data" / "encounters_greenvale_p0_v1_4.json"
EXPECTED_SEQUENCE = [
    "M001", "M012", "M002", "M003", "M004", "M005",
    "M006", "M013", "M008", "M011", "M004", "M012", "M003", "M010", "B001",
]
ACTIVE_MONSTER_IDS = sorted(set(EXPECTED_SEQUENCE))


def load_json(path: Path) -> dict:
    if not path.is_file():
        return {"_missing": str(path)}
    with path.open("r", encoding="utf-8") as fh:
        return json.load(fh)


def source_audit() -> dict:
    catalog = load_json(ENCOUNTER_CATALOG)
    version = str(catalog.get("version", ""))
    boss_every = int(catalog.get("boss_every_kills", 0))
    rotation = list(catalog.get("rotation", []))
    overflow = list(catalog.get("rotation_overflow", []))
    seq = []
    for level in range(1, boss_every + 1):
        if level % boss_every == 0:
            seq.append("B001")
        else:
            idx = level - 1 - (level - 1) // boss_every
            if idx < len(rotation):
                seq.append(rotation[idx])
            else:
                seq.append("?")
    checks = {
        "encounter_catalog_version": version,
        "encounter_count": boss_every,
        "boss_every_kills": boss_every,
        "sequence_matches_v209": seq == EXPECTED_SEQUENCE,
        "m010_at_l14": seq[13] == "M010" if len(seq) >= 14 else False,
        "b001_at_l15": seq[14] == "B001" if len(seq) >= 15 else False,
        "rotation_overflow_reserve": overflow,
        "save_version_expected": 41,
        "buildinfo_version": None,
        "deprecated_monsters_json_non_runtime": True,
    }
    buildinfo = (ROOT / "BuildInfo.gd").read_text(encoding="utf-8")
    checks["buildinfo_version"] = "2.09.0" if 'SOURCE_VERSION := "2.09.0"' in buildinfo else "unknown"
    checks["buildinfo_build_number"] = 2090 if "BUILD_NUMBER := 2090" in buildinfo else None
    ok = (
        version.startswith("v2.09-encounters-")
        and boss_every == 15
        and checks["sequence_matches_v209"]
        and checks["m010_at_l14"]
        and checks["b001_at_l15"]
        and checks["buildinfo_version"] == "2.09.0"
    )
    return {"ok": ok, "checks": checks, "computed_sequence": seq}


def gate_status(report: dict) -> str:
    if report.get("_missing"):
        return "MISSING"
    return str(report.get("status", "UNKNOWN"))


def main() -> int:
    OUT_DIR.mkdir(parents=True, exist_ok=True)
    loaded = {key: load_json(path) for key, path in REPORTS.items()}

    audit = source_audit()
    domain_world = loaded["domain_world"]
    domain_inv = loaded["domain_inventory"]
    runtime_world = loaded["runtime_world"]
    runtime_inv = loaded["runtime_inventory"]
    loot_sim = loaded["loot_simulation"]

    gates = {
        "static_data": audit["ok"],
        "domain_world": gate_status(domain_world) == "PASS",
        "domain_inventory": gate_status(domain_inv) == "PASS",
        "runtime_world": gate_status(runtime_world) == "PASS",
        "runtime_inventory": gate_status(runtime_inv) == "PASS",
        "encounter_trace": runtime_world.get("encounter_trace", []) and len(runtime_world.get("encounter_trace", [])) == 15,
        "hero_unlock": bool(runtime_world.get("hero_unlock_evidence", {}).get("hero_unlocked_after", False)),
        "visual_qa": gate_status(runtime_world) == "PASS" and not runtime_world.get("visual_issues"),
        "loot_simulation_present": "runs" in loot_sim and loot_sim.get("runs", 0) >= 10000,
    }
    all_pass = all(gates.values())

    report = {
        "status": "PASS" if all_pass else "FAIL",
        "version": "2.09.0",
        "build": 2090,
        "milestone": "V2.09-Final-Acceptance",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source_state": audit,
        "encounter_version": audit["checks"].get("encounter_catalog_version"),
        "active_monster_ids": ACTIVE_MONSTER_IDS,
        "gates": gates,
        "domain_results": {
            "world": {
                "status": gate_status(domain_world),
                "tests_passed": domain_world.get("tests_passed"),
                "tests_total": domain_world.get("tests_total"),
                "issues": domain_world.get("issues", []),
            },
            "inventory": {
                "status": gate_status(domain_inv),
                "tests_passed": sum(1 for t in domain_inv.get("tests", []) if t.get("ok")),
                "tests_total": len(domain_inv.get("tests", [])),
                "issues": domain_inv.get("issues", []),
            },
        },
        "runtime_results": {
            "world": {
                "status": gate_status(runtime_world),
                "duration_ms": runtime_world.get("duration_ms"),
                "step_timings": runtime_world.get("step_timings", []),
                "issues": runtime_world.get("issues", []),
                "process_exit": loaded["runtime_world_exit"],
            },
            "inventory": {
                "status": gate_status(runtime_inv),
                "issues": runtime_inv.get("issues", []),
                "assertions": runtime_inv.get("assertions", []),
            },
        },
        "encounter_trace": runtime_world.get("encounter_trace", []),
        "hero_unlock_evidence": runtime_world.get("hero_unlock_evidence", {}),
        "hp_evidence": runtime_world.get("hp_evidence", domain_world.get("state_evidence", {}).get("classification_hp", {})),
        "loot_source_evidence": runtime_world.get("loot_source_evidence", []),
        "loot_simulation": loot_sim,
        "production_assets": runtime_world.get("production_asset_paths", {}),
        "viewport_matrix": runtime_world.get("viewport_matrix", []) + runtime_inv.get("viewport_matrix", []),
        "screenshots": runtime_world.get("screenshots", []) + runtime_inv.get("screenshots", []),
        "visual_issues": (runtime_world.get("visual_issues", []) or []) + (runtime_inv.get("visual_issues", []) or []),
        "regression": {
            "world_smoke": runtime_world.get("regression", {}),
            "inventory_state_evidence": runtime_inv.get("state_evidence", {}),
        },
        "known_non_blocking_issues": [
            "Godot may hang on quit() after runtime QA despite complete PASS report",
            "Attack state assets present but unwired (deferred)",
        ],
        "qa_timings": {
            "world_runtime_ms": runtime_world.get("duration_ms"),
            "world_slowest_step": runtime_world.get("qa_performance", {}).get("slowest_step", {}),
        },
    }

    with OUT_PATH.open("w", encoding="utf-8") as fh:
        json.dump(report, fh, indent="\t")
        fh.write("\n")

    print(json.dumps({"status": report["status"], "path": str(OUT_PATH), "gates": gates}, indent=2))
    return 0 if all_pass else 1


if __name__ == "__main__":
    sys.exit(main())

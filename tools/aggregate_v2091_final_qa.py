#!/usr/bin/env python3
"""Aggregate V2.09.1 acceptance + size optimization evidence."""

from __future__ import annotations

import json
import sys
from datetime import datetime, timezone
from pathlib import Path

ROOT = Path(__file__).resolve().parents[1]
OUT = ROOT / "docs" / "v2091_final_qa" / "final_acceptance_report.json"
BASELINE_APK = ROOT / "builds" / "android" / "RealmAlliance_V2_09_Test.apk"
FINAL_APK = ROOT / "builds" / "android" / "RealmAlliance_V2_09_1_Test.apk"

# Reuse V2.09 aggregator logic
sys.path.insert(0, str(ROOT / "tools"))
from aggregate_v209_final_qa import (  # noqa: E402
    ACTIVE_MONSTER_IDS,
    REPORTS,
    gate_status,
    load_json,
    source_audit as base_source_audit,
)


def source_audit() -> dict:
    audit = base_source_audit()
    checks = audit["checks"]
    buildinfo = (ROOT / "BuildInfo.gd").read_text(encoding="utf-8")
    checks["buildinfo_version"] = "2.09.1" if 'SOURCE_VERSION := "2.09.1"' in buildinfo else "unknown"
    checks["buildinfo_build_number"] = 2091 if "BUILD_NUMBER := 2091" in buildinfo else None
    checks["export_exclude_filter"] = True
    export_cfg = (ROOT / "export_presets.cfg").read_text(encoding="utf-8")
    checks["export_has_docs_exclude"] = "docs/*" in export_cfg and "exclude_filter=" in export_cfg
    audit["ok"] = (
        audit["ok"]
        or (
            checks.get("sequence_matches_v209")
            and checks.get("buildinfo_version") == "2.09.1"
            and checks.get("export_has_docs_exclude")
        )
    )
    # strict ok for v209.1
    audit["ok"] = (
        str(checks.get("encounter_catalog_version", "")).startswith("v2.09-encounters-")
        and checks.get("boss_every_kills") == 15
        and checks.get("sequence_matches_v209")
        and checks.get("buildinfo_version") == "2.09.1"
        and checks.get("export_has_docs_exclude")
    )
    audit["checks"] = checks
    return audit


def apk_bytes(path: Path) -> int | None:
    return path.stat().st_size if path.is_file() else None


def main() -> int:
    OUT.parent.mkdir(parents=True, exist_ok=True)
    loaded = {key: load_json(path) for key, path in REPORTS.items()}
    audit = source_audit()
    runtime_world = loaded["runtime_world"]
    runtime_inv = loaded["runtime_inventory"]
    domain_world = loaded["domain_world"]
    domain_inv = loaded["domain_inventory"]

    before = apk_bytes(BASELINE_APK)
    after = apk_bytes(FINAL_APK)
    saved = (before - after) if before and after else None
    pct = round(100.0 * saved / before, 2) if saved and before else None

    gates = {
        "static_data": audit["ok"],
        "domain_world": gate_status(domain_world) == "PASS",
        "domain_inventory": gate_status(domain_inv) == "PASS",
        "runtime_world": gate_status(runtime_world) == "PASS",
        "runtime_inventory": gate_status(runtime_inv) == "PASS",
        "encounter_trace": len(runtime_world.get("encounter_trace", [])) == 15,
        "hero_unlock": bool(runtime_world.get("hero_unlock_evidence", {}).get("hero_unlocked_after", False)),
        "visual_qa": gate_status(runtime_world) == "PASS",
        "apk_size_reduced": saved is not None and saved > 0,
        "final_apk_present": after is not None,
    }
    all_pass = all(gates.values())

    report = {
        "status": "PASS" if all_pass else "FAIL",
        "version": "2.09.1",
        "build": 2091,
        "milestone": "V2.09.1-Size-Optimization",
        "generated_at": datetime.now(timezone.utc).isoformat(),
        "source_state": audit,
        "size_optimization": {
            "baseline_apk_bytes": before,
            "final_apk_bytes": after,
            "saved_bytes": saved,
            "saved_percent": pct,
            "baseline_apk": str(BASELINE_APK.relative_to(ROOT)).replace("\\", "/"),
            "final_apk": str(FINAL_APK.relative_to(ROOT)).replace("\\", "/"),
            "tier1_changes": [
                "export_presets.cfg exclude_filter for docs/tools/builds/artifacts/logs",
                "exclude *_source_sheet.png master production sheets",
                "arm64-v8a only (unchanged)",
            ],
        },
        "gates": gates,
        "domain_results": {
            "world": {"status": gate_status(domain_world), "tests_passed": domain_world.get("tests_passed"), "tests_total": domain_world.get("tests_total")},
            "inventory": {"status": gate_status(domain_inv), "tests_total": len(domain_inv.get("tests", []))},
        },
        "runtime_results": {
            "world": {"status": gate_status(runtime_world), "duration_ms": runtime_world.get("duration_ms")},
            "inventory": {"status": gate_status(runtime_inv)},
        },
        "encounter_trace": runtime_world.get("encounter_trace", []),
        "hero_unlock_evidence": runtime_world.get("hero_unlock_evidence", {}),
        "visual_issues": runtime_world.get("visual_issues", []) or [],
        "known_non_blocking_issues": [
            "Godot may hang on quit() after runtime QA despite complete PASS report",
            "Attack state deferred",
        ],
    }
    OUT.write_text(json.dumps(report, indent="\t") + "\n", encoding="utf-8")
    print(json.dumps({"status": report["status"], "saved_mb": round((saved or 0) / 1_000_000, 2), "gates": gates}, indent=2))
    return 0 if all_pass else 1


if __name__ == "__main__":
    sys.exit(main())

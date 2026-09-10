#!/usr/bin/env python3
from pathlib import Path
import json, sys

ROOT=Path(__file__).resolve().parents[1]
errors=[]
forbidden_ext={".apk",".aab",".exe",".pck"}
for p in ROOT.rglob("*"):
    if p.is_file() and p.suffix.lower() in forbidden_ext:
        errors.append(f"Binary build artifact inside source package: {p.relative_to(ROOT)}")

required=[
 "project.godot","export_presets.cfg","MainGame.tscn","MainGame.gd",
 "FeatureFlags.gd","P0RuntimeContract.gd","P0TestHarness.gd",
 "data/p0_core_acceptance_v1_17.json","data/p0_balance_profile_v1_16.json",
 "data/build_manifest_v1_18.json"
]
for rel in required:
    if not (ROOT/rel).exists():
        errors.append(f"Required file missing: {rel}")

print(json.dumps({"ok":not errors,"errors":errors,"required_count":len(required)},indent=2))
sys.exit(0 if not errors else 1)

#!/usr/bin/env python3
from pathlib import Path
import re, json, sys

ROOT=Path(__file__).resolve().parents[1]
errors=[]

h=(ROOT/"P0TestHarness.gd").read_text(encoding="utf-8")
main=(ROOT/"MainGame.gd").read_text(encoding="utf-8")
scene=(ROOT/"MainGame.tscn").read_text(encoding="utf-8")
save=(ROOT/"SaveGame.gd").read_text(encoding="utf-8")

profiles=["fresh","half_boss","boss_ready","wheel","village","return","low_resource"]
for p in profiles:
    if f'"{p}"' not in h:
        errors.append(f"profile missing: {p}")

if "OS.is_debug_build()" not in h:
    errors.append("harness not debug-gated")
if "P0DebugToggle" not in scene:
    errors.append("debug toggle missing")
if "p0_debug_toggle.visible = P0TestHarness.enabled" not in main:
    errors.append("release visibility gate missing")
if "BACKUP_SAVE_PATH" not in save:
    errors.append("backup save support missing")
if "write_corrupt_primary_with_backup_fixture" not in h:
    errors.append("recovery fixture missing")

print(json.dumps({"ok":not errors,"errors":errors},indent=2))
sys.exit(0 if not errors else 1)

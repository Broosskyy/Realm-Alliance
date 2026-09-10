#!/usr/bin/env python3
from pathlib import Path
import json,re,sys
ROOT=Path(__file__).resolve().parents[1]
errors=[]
save=(ROOT/"SaveGame.gd").read_text(encoding="utf-8")
boot=(ROOT/"P0BootDiagnostics.gd").read_text(encoding="utf-8")
harness=(ROOT/"P0TestHarness.gd").read_text(encoding="utf-8")
main=(ROOT/"MainGame.gd").read_text(encoding="utf-8")
build=(ROOT/"BuildInfo.gd").read_text(encoding="utf-8")
def req(c,m):
    if not c: errors.append(m)

req("const SAVE_VERSION := 20" in save,"Save schema not V20")
for token in [
    "func _is_save_dictionary_valid(data: Dictionary) -> bool:",
    "if int(data.get(\"gold\", 0)) < 0:",
    "if int(data.get(\"spins\", 0)) < 0:",
    "monster_hp < 0 or monster_hp > monster_max_hp",
    "func _remove_rejected_primary_files() -> void:",
    "if recovered_from_backup:",
    "_remove_rejected_primary_files()",
    "save_sequence",
    "last_save_ok",
    'load_source = "backup"',
    'load_source = "primary"',
    'load_source = "fresh"',
    "_repair_legacy_zero_hp_monster()"
]:
    req(token in save,f"Save lifecycle token missing: {token}")

req("write_invalid_primary_with_backup_fixture" in harness,"Logical corruption fixture missing")
req("SaveGame.load_source" in boot,"Boot diagnostics missing save source")
req("SaveGame.save_game()" in main and "NOTIFICATION_APPLICATION_PAUSED" in main,"Pause save path missing")
req('SOURCE_VERSION := "V1.21"' in build,"Build version drift")
req('BUILD_NUMBER := 31' in build,"Build number drift")

print(json.dumps({"ok":not errors,"errors":errors},indent=2))
sys.exit(0 if not errors else 1)

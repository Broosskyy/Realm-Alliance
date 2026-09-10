#!/usr/bin/env python3
from pathlib import Path
import re, json, sys

ROOT=Path(__file__).resolve().parents[1]
errors=[]
main=(ROOT/"MainGame.gd").read_text(encoding="utf-8")
hero=(ROOT/"HeroSystem.gd").read_text(encoding="utf-8")
lane=(ROOT/"LaneAttackSystem.gd").read_text(encoding="utf-8")
td=(ROOT/"TowerDefenseSystem.gd").read_text(encoding="utf-8")
boot=(ROOT/"P0BootDiagnostics.gd").read_text(encoding="utf-8")
flags=(ROOT/"FeatureFlags.gd").read_text(encoding="utf-8")
build=(ROOT/"BuildInfo.gd").read_text(encoding="utf-8")

def req(c,m):
    if not c: errors.append(m)

ready=re.search(r"func _ready\(\) -> void:.*?(?=\nfunc |\Z)",main,re.S)
req(ready is not None,"MainGame._ready missing")
if ready:
    r=ready.group(0)
    forbidden=[
      "HeroSystem.auto_damage_done",
      "LaneAttackSystem.battle_updated.connect",
      "TowerDefenseSystem.defense_updated.connect",
      'hero_knight.pressed.connect',
      'daily_button.pressed.connect',
      'quest_button.pressed.connect'
    ]
    for token in forbidden:
        req(token not in r,f"Unconditional P1 wiring remains in _ready: {token}")
    req("_setup_optional_p1_runtime()" in r,"Gated P1 setup not called")

req("func _setup_optional_p1_runtime() -> void:" in main,"Gated P1 setup missing")
for flag in ["SHOW_HEROES","SHOW_ATTACK","SHOW_DEFENSE","SHOW_DAILY","SHOW_QUESTS"]:
    req(f"if FeatureFlags.{flag}" in main or f"FeatureFlags.{flag} or" in main, f"P1 gate missing: {flag}")

req("set_process(FeatureFlags.ENABLE_HERO_AUTODPS)" in hero,"HeroSystem not process-gated")
req("func _ready() -> void:" in lane and "set_process(false)" in lane,"LaneAttackSystem not dormant at boot")
req("func _ready() -> void:" in td and "set_process(false)" in td,"TowerDefenseSystem not dormant at boot")

for token in ["HeroSystem.is_processing()","LaneAttackSystem.is_processing()","TowerDefenseSystem.is_processing()"]:
    req(token in boot,f"Boot isolation check missing: {token}")

for f in ["SHOW_DAILY","SHOW_QUESTS","SHOW_HEROES","SHOW_ATTACK","SHOW_DEFENSE","ENABLE_HERO_AUTODPS"]:
    req(f"const {f} := false" in flags,f"P1 flag enabled: {f}")

req('SOURCE_VERSION := "V1.20"' in build,"Build version drift")
req('BUILD_NUMBER := 30' in build,"Build number drift")

print(json.dumps({"ok":not errors,"errors":errors},indent=2))
sys.exit(0 if not errors else 1)

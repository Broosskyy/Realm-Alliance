from pathlib import Path
import json, sys

root = Path(__file__).resolve().parents[1]
errors = []

regions = json.loads((root / "data/regions.json").read_text(encoding="utf-8"))
encounters = json.loads((root / "data/encounters_greenvale_p0_v1_4.json").read_text(encoding="utf-8"))
loot = json.loads((root / "data/loot_tables_v207.json").read_text(encoding="utf-8"))

region_by = {r["id"]: r for r in regions.get("regions", [])}
greenvale = region_by.get("greenvale", {})

if greenvale.get("encounter_catalog", "").endswith("encounters_greenvale_p0_v1_4.json") is False:
    errors.append("greenvale encounter_catalog")
if not str(greenvale.get("background_asset", "")).endswith("BG001_gruenhain_home_v11.png"):
    errors.append("greenvale background_asset")
if encounters.get("region_id") != "greenvale":
    errors.append("encounters region_id")

monster_ids = {m["id"] for m in encounters.get("monsters", [])}
for rid in encounters.get("rotation", []):
    if rid not in monster_ids:
        errors.append(f"rotation ref {rid}")
for bid in encounters.get("boss_rotation", []):
    if bid not in monster_ids:
        errors.append(f"boss_rotation ref {bid}")

asset_root = greenvale.get("monster_asset_root", "")
for mid in ["M001", "M002", "M010", "B001"]:
    for state in ["idle", "attack", "hit", "defeat"]:
        rel = f"{asset_root.replace('res://', '')}/{mid}_{state}.png"
        if not (root / rel).exists():
            errors.append(f"missing asset {rel}")

loot_sources = loot.get("sources", {})
for key in ["greenvale_boss", "greenvale_elite", "greenvale_normal"]:
    if key not in loot_sources:
        errors.append(f"loot source {key}")

save_text = (root / "SaveGame.gd").read_text(encoding="utf-8")
if "const SAVE_VERSION := 41" not in save_text:
    errors.append("save version 41")
if "region_progression" not in save_text:
    errors.append("region_progression save block")

print(json.dumps({"ok": not errors, "errors": errors, "source": "V2.08"}, indent=2))
sys.exit(1 if errors else 0)

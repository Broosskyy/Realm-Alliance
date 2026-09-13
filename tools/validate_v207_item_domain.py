#!/usr/bin/env python3
from pathlib import Path
import json
import sys

ROOT = Path(__file__).resolve().parents[1]
errors = []

items_path = ROOT / "data" / "items_v207.json"
loot_path = ROOT / "data" / "loot_tables_v207.json"
bindings_path = ROOT / "data" / "runtime_art_bindings_v200.json"

items = json.loads(items_path.read_text(encoding="utf-8"))
loot = json.loads(loot_path.read_text(encoding="utf-8"))
bindings = json.loads(bindings_path.read_text(encoding="utf-8")).get("bindings", {})

item_ids = set()
for item in items.get("items", []):
    item_id = item.get("item_id", "")
    if not item_id:
        errors.append("item missing item_id")
        continue
    if item_id in item_ids:
        errors.append(f"duplicate item_id: {item_id}")
    item_ids.add(item_id)
    rarity = item.get("rarity", "")
    if rarity not in items.get("valid_rarities", []):
        errors.append(f"{item_id}: invalid rarity {rarity}")
    slot = item.get("slot", "")
    if slot not in items.get("valid_slots", []):
        errors.append(f"{item_id}: invalid slot {slot}")
    icon = item.get("icon_asset", "")
    if icon not in bindings:
        errors.append(f"{item_id}: icon_asset not bound: {icon}")
    for mod in item.get("modifiers", []):
        if mod.get("stat") not in items.get("valid_stats", []):
            errors.append(f"{item_id}: invalid stat {mod.get('stat')}")
        if mod.get("operation") not in items.get("valid_operations", []):
            errors.append(f"{item_id}: invalid operation {mod.get('operation')}")

sources = loot.get("sources", {})
if not sources:
    errors.append("loot tables empty")
for source_id, source_def in sources.items():
    for entry in source_def.get("guaranteed", []) + source_def.get("weighted_entries", []):
        ref = entry.get("item_id", "")
        if ref and ref not in item_ids:
            errors.append(f"{source_id}: unknown item {ref}")
        if source_def.get("weighted_entries") and entry in source_def.get("weighted_entries", []):
            if float(entry.get("weight", 0)) <= 0:
                errors.append(f"{source_id}: non-positive weight for {ref}")

save = (ROOT / "SaveGame.gd").read_text(encoding="utf-8")
if "SAVE_VERSION := 40" not in save:
    errors.append("SaveGame not at version 40")
if "item_inventory" not in save:
    errors.append("SaveGame missing item_inventory block")

reward = (ROOT / "RewardPipeline.gd").read_text(encoding="utf-8")
if '"items"' not in reward or "_normalize_reward" not in reward:
    errors.append("RewardPipeline missing item normalization")

project = (ROOT / "project.godot").read_text(encoding="utf-8")
for svc in ["ItemInventoryService", "LootTableService", "StatModifierService"]:
    if svc not in project:
        errors.append(f"autoload missing: {svc}")

result = {"ok": not errors, "errors": errors, "item_count": len(item_ids)}
print(json.dumps(result, indent=2))
sys.exit(0 if not errors else 1)

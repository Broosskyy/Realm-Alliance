#!/usr/bin/env python3
from pathlib import Path
import re, json, sys

ROOT = Path(__file__).resolve().parents[1]
errors = []
warnings = []

project = ROOT / "project.godot"
scene = ROOT / "MainGame.tscn"

if not project.exists():
    errors.append("project.godot missing")
if not scene.exists():
    errors.append("MainGame.tscn missing")

def res_exists(path: str) -> bool:
    return (ROOT / path.replace("res://","")).exists()

if scene.exists():
    text = scene.read_text(encoding="utf-8")
    for path in re.findall(r'path="(res://[^"]+)"', text):
        if not res_exists(path):
            errors.append(f"Missing scene resource: {path}")

    unique_names = re.findall(r'\[node name="([^"]+)"[\s\S]*?unique_name_in_owner = true', text)
    duplicates = sorted({n for n in unique_names if unique_names.count(n) > 1})
    for name in duplicates:
        errors.append(f"Duplicate unique_name_in_owner: {name}")

# %Node references
gd_files = list(ROOT.glob("*.gd"))
scene_text = scene.read_text(encoding="utf-8") if scene.exists() else ""
scene_nodes = set(re.findall(r'\[node name="([^"]+)"', scene_text))
for gd in gd_files:
    text = gd.read_text(encoding="utf-8")
    for node in re.findall(r'%([A-Z][A-Za-z0-9_]*)', text):
        if node not in scene_nodes and gd.name == "MainGame.gd":
            errors.append(f"MainGame.gd references missing % node: {node}")

# Autoload script existence
if project.exists():
    ptxt = project.read_text(encoding="utf-8")
    m = re.search(r'\[autoload\]([\s\S]*?)(?=\n\[|\Z)', ptxt)
    if m:
        for name,path in re.findall(r'^([A-Za-z0-9_]+)="\*?(res://[^"]+)"', m.group(1), re.M):
            if not res_exists(path):
                errors.append(f"Autoload missing: {name} -> {path}")

# Data JSON parse
for jp in (ROOT/"data").glob("*.json"):
    try:
        json.loads(jp.read_text(encoding="utf-8"))
    except Exception as exc:
        errors.append(f"Invalid JSON: {jp.name}: {exc}")


# Common Godot 4 build-risk patterns
for gd in gd_files:
    text = gd.read_text(encoding="utf-8")
    if "DirAccess.rename_absolute" in text or "DirAccess.remove_absolute" in text:
        warnings.append(f"Absolute DirAccess helper still used: {gd.name}")
    if "\t " in text:
        warnings.append(f"Mixed indentation suspicion: {gd.name}")

# Duplicate function names per file
for gd in gd_files:
    text = gd.read_text(encoding="utf-8")
    funcs = re.findall(r"^func\s+([A-Za-z0-9_]+)\s*\(", text, re.M)
    for fn in sorted(set(funcs)):
        if funcs.count(fn) > 1:
            errors.append(f"Duplicate function in {gd.name}: {fn}")


# P0 controller must be called through its scene node, not as an undeclared global.
main_game = ROOT / "MainGame.gd"
if main_game.exists():
    main_text = main_game.read_text(encoding="utf-8")
    if "P02CoreController.apply(" in main_text:
        errors.append("P02CoreController global-style call remains")
    if "p02_core_controller.apply(self)" not in main_text:
        errors.append("P02CoreController scene-node call missing")

# P0 feature-flag contract
flags = ROOT / "FeatureFlags.gd"
if flags.exists():
    flag_text = flags.read_text(encoding="utf-8")
    for flag in ["SHOW_ATTACK","SHOW_DEFENSE"]:
        m = re.search(rf"const\s+{flag}\s*:=\s*(true|false)", flag_text)
        if not m or m.group(1) != "false":
            errors.append(f"P0 feature flag must be false: {flag}")

report = {
    "ok": not errors,
    "errors": errors,
    "warnings": warnings,
    "gd_files": len(gd_files),
    "scene_nodes": len(scene_nodes)
}
print(json.dumps(report, indent=2, ensure_ascii=False))
sys.exit(0 if not errors else 1)

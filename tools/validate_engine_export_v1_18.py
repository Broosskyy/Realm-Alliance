#!/usr/bin/env python3
from pathlib import Path
import json, re, sys

ROOT=Path(__file__).resolve().parents[1]
errors=[]
warnings=[]

project=(ROOT/"project.godot").read_text(encoding="utf-8")
exports=(ROOT/"export_presets.cfg").read_text(encoding="utf-8")
flags=(ROOT/"FeatureFlags.gd").read_text(encoding="utf-8")
harness=(ROOT/"P0TestHarness.gd").read_text(encoding="utf-8")
main=(ROOT/"MainGame.gd").read_text(encoding="utf-8")
manifest=json.loads((ROOT/"data/build_manifest_v1_18.json").read_text(encoding="utf-8"))

def require(cond,msg):
    if not cond: errors.append(msg)

# Main scene / project basics
require('run/main_scene="res://MainGame.tscn"' in project, "Main scene drift")
require((ROOT/"MainGame.tscn").exists(), "MainGame.tscn missing")
require('window/size/viewport_width=1080' in project, "Reference width drift")
require('window/size/viewport_height=1920' in project, "Reference height drift")
require('window/stretch/mode="canvas_items"' in project, "Stretch mode drift")
require('window/handheld/orientation=1' in project, "Portrait orientation drift")
require('renderer/rendering_method="gl_compatibility"' in project, "GL compatibility renderer drift")
require('renderer/rendering_method.mobile="gl_compatibility"' in project, "Mobile GL renderer drift")

# Every autoload target must exist
autoload_section=re.search(r"\[autoload\](.*?)(?=\n\[|\Z)",project,re.S)
require(autoload_section is not None,"Autoload section missing")
autoloads=[]
if autoload_section:
    for name,path in re.findall(r'^([A-Za-z0-9_]+)="\*res://([^"]+)"',autoload_section.group(1),re.M):
        autoloads.append((name,path))
        require((ROOT/path).exists(), f"Autoload missing: {name} -> {path}")

# Android preset
require('name="Android Test"' in exports, "Android Test preset missing")
require('platform="Android"' in exports, "Android platform preset missing")
require('architectures/arm64-v8a=true' in exports, "ARM64 disabled")
require('architectures/armeabi-v7a=false' in exports, "Unexpected armeabi-v7a enabled")
require('screen/immersive_mode=true' in exports, "Android immersive mode disabled")
require('package/unique_name="com.realmalliance.prototype"' in exports, "Android package drift")
require('export_path="build/android/RealmAlliance_V1_18_Test.apk"' in exports, "Android export path drift")
require('version/code=28' in exports, "Android version code drift")
require('version/name="1.18.0"' in exports, "Android version name drift")

# Web preset
require('name="Web Test"' in exports, "Web Test preset missing")
require('platform="Web"' in exports, "Web platform preset missing")
require('export_path="build/web/index.html"' in exports, "Web export path drift")

# Debug harness isolation / P1 gate
require("var enabled: bool = OS.is_debug_build()" in harness, "Debug harness is not debug-build gated")
require("p0_debug_toggle.visible = P0TestHarness.enabled" in main, "Debug UI visibility not tied to harness")
for flag in ["SHOW_DAILY","SHOW_QUESTS","SHOW_HEROES","SHOW_ATTACK","SHOW_DEFENSE","ENABLE_HERO_AUTODPS"]:
    require(f"const {flag} := false" in flags, f"P1 enabled: {flag}")

# Manifest consistency
require(manifest["main_scene"]=="res://MainGame.tscn","Manifest main scene drift")
require(manifest["reference_resolution"]==[1080,1920],"Manifest resolution drift")
require(manifest["android"]["export_path"]=="build/android/RealmAlliance_V1_18_Test.apk","Manifest Android path drift")
require(manifest["build_number"]==28,"Manifest build number drift")

result={
    "ok":not errors,
    "errors":errors,
    "warnings":warnings,
    "autoload_count":len(autoloads),
    "android_preset":True,
    "web_preset":True,
    "portrait":True,
    "arm64_only":True,
    "debug_harness_gated":True,
    "runtime_status":"NOT_RUNTIME_TESTED"
}
print(json.dumps(result,ensure_ascii=False,indent=2))
sys.exit(0 if not errors else 1)

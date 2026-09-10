#!/usr/bin/env python3
from pathlib import Path
import json, re, sys

ROOT=Path(__file__).resolve().parents[1]
errors=[]
project=(ROOT/"project.godot").read_text(encoding="utf-8")
main=(ROOT/"MainGame.gd").read_text(encoding="utf-8")
boot=(ROOT/"P0BootDiagnostics.gd").read_text(encoding="utf-8")
acceptance=(ROOT/"CoreAcceptanceService.gd").read_text(encoding="utf-8")
runtime=(ROOT/"P0RuntimeContract.gd").read_text(encoding="utf-8")
harness=(ROOT/"P0TestHarness.gd").read_text(encoding="utf-8")
build=(ROOT/"BuildInfo.gd").read_text(encoding="utf-8")

def req(cond,msg):
    if not cond: errors.append(msg)

req('P0BootDiagnostics="*res://P0BootDiagnostics.gd"' in project,"P0BootDiagnostics autoload missing")
req('P0BootDiagnostics.complete_scene_boot(self)' in main,"Main scene does not complete boot diagnostics")
req('CoreAcceptanceService.validate_runtime_contract()' in boot,"Boot diagnostics do not validate Core contract")
req('ProjectSettings.get_setting("application/run/main_scene"' in boot,"Boot diagnostics do not validate main scene")
req('ProjectSettings.get_setting("display/window/size/viewport_width"' in boot,"Boot diagnostics do not validate viewport")
req('P0TestHarness.enabled and not OS.is_debug_build()' in boot,"Release harness leak check missing")
req('const STARTING_SPINS := P0RuntimeContract.STARTING_SPINS' in acceptance,"Stale CoreAcceptance starting spin constant")
req('const STARTING_SPINS := 5' in runtime,"Runtime starting spins drift")
req('const STARTING_GOLD := 300' in runtime,"Runtime starting gold drift")
req('"boot":P0BootDiagnostics.snapshot()' in harness,"Harness snapshot lacks boot diagnostics")
req('SOURCE_VERSION := "V1.19"' in build,"BuildInfo version drift")
req('BUILD_NUMBER := 29' in build,"Build number drift")

# ensure boot autoload is last to reduce dependency-order risk
autoload=re.search(r"\[autoload\](.*?)(?=\n\[|\Z)",project,re.S)
if autoload:
    names=re.findall(r'^([A-Za-z0-9_]+)=',autoload.group(1),re.M)
    req(bool(names) and names[-1]=="P0BootDiagnostics","P0BootDiagnostics must be final autoload")
else:
    errors.append("Autoload section missing")

print(json.dumps({"ok":not errors,"errors":errors},indent=2))
sys.exit(0 if not errors else 1)

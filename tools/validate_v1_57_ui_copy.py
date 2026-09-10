from pathlib import Path
import re, sys
root=Path(__file__).resolve().parents[1]
errors=[]
bi=(root/'BuildInfo.gd').read_text()
if 'SOURCE_VERSION := "V1.57"' not in bi: errors.append('BuildInfo version')
if 'MASTER_CONCEPT := "V2.1"' not in bi: errors.append('master concept marker')
proj=(root/'project.godot').read_text()
if 'UiCopyCalibration=' not in proj: errors.append('autoload UiCopyCalibration')
main=(root/'MainGame.gd').read_text()
if 'UiCopyCalibration.apply(self)' not in main: errors.append('copy calibration apply')
if 'DREHEN · 1 SPIN' not in main: errors.append('spin CTA calibration')
scene=(root/'MainGame.tscn').read_text()
for forbidden in ['LANE BATTLE\\n','DEFENSE\\n','PROFIL & SOCIAL','TREASURE PORTAL','AFK-BELOHNUNG ABHOLEN','text = "PROGRESSION"']:
    if forbidden in scene: errors.append('legacy player copy: '+forbidden)
boot=(root/'BootFlow.tscn').read_text()
if 'text = "LOGIN"' in boot: errors.append('legacy LOGIN label')
if errors:
    print('V1.57 UI COPY QA: FAIL')
    for e in errors: print('-',e)
    sys.exit(1)
print('V1.57 UI COPY QA: PASS')

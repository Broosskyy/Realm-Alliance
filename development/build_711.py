"""Build 711 web; Android requires the owner's original private signing identity."""
from pathlib import Path
import argparse,os,subprocess
p=argparse.ArgumentParser();p.add_argument('--godot',default='godot');p.add_argument('--output',required=True);p.add_argument('--android',action='store_true');p.add_argument('--keystore');a=p.parse_args()
root=Path(__file__).resolve().parents[1];output=Path(a.output).resolve()
subprocess.run(['python3',str(root/'development/build_web711.py'),'--godot',a.godot,'--output',str(output/'web')],check=True)
if a.android:
 if not a.keystore or not Path(a.keystore).is_file():raise SystemExit('Android update build requires the original private keystore. No replacement key will be generated.')
 output.joinpath('android').mkdir(exist_ok=True)
 env={**os.environ,'GODOT_ANDROID_KEYSTORE_DEBUG_PATH':str(Path(a.keystore).resolve())}
 subprocess.run([a.godot,'--headless','--path',str(root/'godot/realm_alliance'),'--export-debug','Android Debug',str(output/'android/REALM_ALLIANCE_711.apk')],env=env,check=True)

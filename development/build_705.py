"""Rebuild both isolated 705 test artifacts with an installed Godot toolchain."""
from pathlib import Path
import argparse
import os
import subprocess

p = argparse.ArgumentParser()
p.add_argument('--godot', default='godot')
p.add_argument('--output', required=True)
args = p.parse_args()
root = Path(__file__).resolve().parents[1]
project = root / 'godot/realm_alliance'
output = Path(args.output).expanduser().resolve()
(output / 'web').mkdir(parents=True, exist_ok=True)
(output / 'android').mkdir(parents=True, exist_ok=True)
env = {**os.environ,
       'GODOT_ANDROID_KEYSTORE_DEBUG_PATH': str(root / 'development/realm-preview-debug.keystore'),
       'GODOT_ANDROID_KEYSTORE_DEBUG_USER': 'androiddebugkey',
       'GODOT_ANDROID_KEYSTORE_DEBUG_PASSWORD': 'android'}
base = [args.godot, '--headless', '--path', str(project)]
subprocess.run(base + ['--import'], env=env, check=True)
for preset, target in [('Web', output / 'web/index.html'),
                       ('Android Debug', output / 'android/REALM_ALLIANCE_705_Rekonstruktion.apk')]:
    subprocess.run(base + ['--export-debug', preset, str(target)], env=env, check=True)

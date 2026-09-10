from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
project=(root/'project.godot').read_text(); flags=(root/'FeatureFlags.gd').read_text(); scene=(root/'MainGame.tscn').read_text(); game=(root/'MainGame.gd').read_text(); hero=(root/'HeroSystem.gd').read_text(); save=(root/'SaveGame.gd').read_text(); cfg=json.loads((root/'data/heroes.json').read_text())
checks=[
('version','config/version="1.31"' in project or 'config/version="1.41"' in project or 'config/version="1.40"' in project or 'config/version="1.39"' in project or 'config/version="1.38"' in project or 'config/version="1.37"' in project or 'config/version="1.36"' in project or 'config/version="1.32"' in project or 'config/version="1.33"' in project or 'config/version="1.34"' in project or 'config/version="1.33"' in project or 'config/version="1.34"' in project or 'config/version="1.35"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
errors=[n for n,ok in checks if not ok]
print(json.dumps({'ok':not errors,'errors':errors,'source':'V1.31'},indent=2)); sys.exit(1 if errors else 0)

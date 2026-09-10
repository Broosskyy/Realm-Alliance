from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
errors=[]
project=(root/"project.godot").read_text(encoding="utf-8")
flags=(root/"FeatureFlags.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
sysgd=(root/"DiceJourneySystem.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/dice_journey_greenvale_v1_26.json").read_text(encoding="utf-8"))
checks=[
 ("autoload",'DiceJourneySystem="*res://DiceJourneySystem.gd"' in project),
 ('version','config/version="1.26"' in project or 'config/version="1.41"' in project or 'config/version="1.38"' in project or 'config/version="1.37"' in project or 'config/version="1.36"' in project or 'config/version="1.27"' in project or 'config/version="1.28"' in project or 'config/version="1.29"' in project or 'config/version="1.30"' in project or 'config/version="1.32"' in project or 'config/version="1.33"' in project or 'config/version="1.34"' in project or 'config/version="1.33"' in project or 'config/version="1.34"' in project or 'config/version="1.31"' in project or 'config/version="1.35"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
 ("dice flag","const SHOW_DICE := true" in flags),
 ("journey flag","const SHOW_REALM_JOURNEY := true" in flags),
 ("portal flag","const SHOW_TREASURE_PORTAL := true" in flags),
 ("journey view",'name="View_RealmJourney"' in scene),
 ("journey entry",'name="JourneyButton"' in scene),
 ("dice button",'name="DiceRollButton"' in scene),
 ("portal button",'name="TreasurePortalButton"' in scene),
 ("primary SPIN wording",'text = "SPIN"' in scene and 'text = "RAD"' not in scene),
 ("no visible old wheel CTA",'text = "RAD DREHEN"' not in scene),
 ("save export",'"dice_journey": DiceJourneySystem.export_save_data()' in save),
 ("save import",'DiceJourneySystem.apply_save_data(parsed.get("dice_journey", {}))' in save),
 ("schema V20","const SAVE_VERSION := 20" in save),
 ("roll implementation","randi_range(1,6)" in sysgd or "rng.randi_range(1,6)" in sysgd),
 ("portal implementation","open_treasure_portal" in sysgd),
 ("runtime dice","_on_dice_roll_pressed" in game),
 ("runtime portal","_on_treasure_portal_pressed" in game),
 ("12 nodes",int(cfg.get("board_nodes",0))==12)
]
for label,ok in checks:
 if not ok: errors.append(label)
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.26","journey_nodes":cfg.get("board_nodes")},indent=2))
sys.exit(1 if errors else 0)

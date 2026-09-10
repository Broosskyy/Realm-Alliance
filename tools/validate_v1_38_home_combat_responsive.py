from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
project=(root/"project.godot").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
responsive=(root/"ResponsiveLayout.gd").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
errors=[]
checks=[
("version",'config/version="1.38"' in project or 'config/version="1.45"' in project or 'config/version="1.44"' in project or 'config/version="1.43"' in project or 'config/version="1.42"' in project or 'config/version="1.41"' in project or 'config/version="1.40"' in project or 'config/version="1.39"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("monster helper","func _monster_title_text_p0" in game),
("monster helper used",game.count("_monster_title_text_p0(PlayerData.monster_level)") >= 2),
("damage deterministic","randf_range(-34.0,34.0)" not in game and "damage_feedback_index_p0" in game),
("reward reduced motion",'if SettingsService.reduced_motion:' in game[game.find("func _show_reward_pulse"):game.find("func _show_boss_shield_state")]),
("no fixed spin center","center_x := 540.0" not in responsive),
("viewport center","var center_x := viewport_w * 0.5" in responsive),
("dynamic payline","viewport_w * 0.10" in responsive and "viewport_w * 0.90" in responsive),
("small pills","pill_w := 150.0 if profile == PROFILE_SMALL" in responsive),
("overlay fit",all(x in responsive for x in ["feature_hub","account_overlay","social_overlay","support_overlay"])),
("settings fit","Vector2(900, 1000)" in responsive),
("realm spin cta",'REALM SPIN · BELOHNUNG DREHEN' in scene),
("primary nav",all(x in scene for x in ['text = "HOME"','text = "SPIN"','text = "DORF"'])),
("schema","const SAVE_VERSION := 20" in save),
]
for label,ok in checks:
    if not ok: errors.append(label)
assets=list((root/"assets/home_polish").glob("HOME*.png"))
if len(assets)!=6: errors.append("home polish asset count")
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.38","assets":len(assets)},indent=2))
sys.exit(1 if errors else 0)

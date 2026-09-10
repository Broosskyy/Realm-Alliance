from pathlib import Path
import json,sys,re
root=Path(__file__).resolve().parents[1]
project=(root/"project.godot").read_text(encoding="utf-8")
journey=(root/"DiceJourneySystem.gd").read_text(encoding="utf-8")
puzzle=(root/"PuzzleSystem.gd").read_text(encoding="utf-8")
hero=(root/"HeroSystem.gd").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/dice_journey_greenvale_v1_26.json").read_text(encoding="utf-8"))
errors=[]
checks=[
("version",'config/version="1.41"' in project or 'config/version="1.49"' in project or 'config/version="1.48"' in project or 'config/version="1.47"' in project or 'config/version="1.46"' in project or 'config/version="1.45"' in project or 'config/version="1.44"' in project or 'config/version="1.43"' in project or 'config/version="1.42"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("journey config",(
    ('const CONFIG_VERSION := "v1.41-journey-02"' in journey and cfg.get("version")=="v1.41-journey-02")
    or ('const CONFIG_VERSION := "v1.47-journey-progression-03"' in journey and cfg.get("version")=="v1.47-journey-progression-03")
)),
("journey contract",'RESULT_CONTRACT_VERSION := "journey-result-v1"' in journey),
("roll id",'"roll_id":_roll_id(roll_seed)' in journey),
("roll seed",'"roll_seed":roll_seed' in journey and 'rng.seed = roll_seed' in journey),
("scoped rng",'var rng := RandomNumberGenerator.new()' in journey and 'var value := rng.randi_range(1,6)' in journey),
("pending journey",'"pending_result":pending_result.duplicate(true)' in journey),
("save before emit",'pending_result = result.duplicate(true)\n\tSaveGame.save_game()\n\tdice_rolled.emit(result)' in journey),
("resume", "func _restore_pending_journey_presentation()" in game and "DiceJourneySystem.peek_pending_result()" in game),
("resume no reroll","func _restore_pending_journey_presentation()" in game and "DiceJourneySystem.roll()" not in game[game.find("func _restore_pending_journey_presentation()"):game.find("func _monster_title_text_p0")]),
("puzzle utc","func _utc_day_key()" in puzzle and "attempts_day_utc" in puzzle),
("puzzle reset","func ensure_daily_attempts()" in puzzle and 'daily_free_attempts' in puzzle),
("puzzle persisted",'"attempts_day_utc":attempts_day_utc' in puzzle),
("hero selection","func select_hero(hero_id: String)" in hero and "SaveGame.save_game()" in hero[hero.find("func select_hero"):hero.find("func get_selected_hero_id")]),
("no select upgrade","_select_and_upgrade_hero" not in game),
("explicit upgrade",'name="HeroUpgradeButtonP0"' in scene and "func _upgrade_selected_hero_p0()" in game),
("hero persistence",'"selected_hero_id":selected_hero_id' in hero),
("level cap","GameConfig.HERO_LEVEL_CAP" in game[game.find("func _refresh_hero_equipment_ui"):game.find("func _upgrade_hero_equipment")]),
("schema","const SAVE_VERSION := 20" in save),
("primary nav",all(x in scene for x in ['text = "HOME"','text = "SPIN"','text = "DORF"']))
]
for label,ok in checks:
    if not ok: errors.append(label)
assets=list((root/"assets/v141_hardening").glob("V141_*.png"))
if len(assets)!=6: errors.append("v141 asset count")
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.41","assets":len(assets)},indent=2))
sys.exit(1 if errors else 0)

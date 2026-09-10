from pathlib import Path
import json,sys,re
root=Path(__file__).resolve().parents[1]
errors=[]
project=(root/"project.godot").read_text(encoding="utf-8")
flags=(root/"FeatureFlags.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
daily=(root/"DailyRewards.gd").read_text(encoding="utf-8")
quests=(root/"QuestSystem.gd").read_text(encoding="utf-8")
p02=(root/"P02CoreController.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/daily_quests_v1_32.json").read_text(encoding="utf-8"))

cycle=cfg.get("daily",{}).get("cycle",[])
quest_cfg=cfg.get("quests",[])
checks=[
("version",'config/version="1.32"' in project or 'config/version="1.41"' in project or 'config/version="1.40"' in project or 'config/version="1.39"' in project or 'config/version="1.38"' in project or 'config/version="1.37"' in project or 'config/version="1.36"' in project or 'config/version="1.33"' in project or 'config/version="1.34"' in project or 'config/version="1.33"' in project or 'config/version="1.34"' in project or 'config/version="1.35"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("daily flag","const SHOW_DAILY := true" in flags),
("quests flag","const SHOW_QUESTS := true" in flags),
("daily view",'name="View_Daily"' in scene),
("quest view",'name="View_Quests"' in scene),
("daily entry",'name="DailyButton"' in scene),
("quest entry",'name="QuestButton"' in scene),
("daily cycle label",'name="DailyCycleLabel"' in scene),
("quest summary",'name="QuestSummaryLabel"' in scene),
("p02 daily","DailyButton\", FeatureFlags.SHOW_DAILY" in p02),
("p02 quests","QuestButton\", FeatureFlags.SHOW_QUESTS" in p02),
("daily no broken call","claim_reward()" not in daily),
("daily claim func","func claim_today" in daily),
("daily immediate save","SaveGame.save_game()" in daily),
("quest config path",'DATA_PATH := "res://data/daily_quests_v1_32.json"' in quests),
("quest save export",'"quest_system": QuestSystem.export_save_data()' in save),
("daily streak save",'"daily_streak": PlayerData.daily_streak' in save),
("last daily save",'"last_daily_claim_unix": PlayerData.last_daily_claim_unix' in save),
("spin hook",'QuestSystem.add_progress("spin_3", 1)' in game),
("tap hook",'QuestSystem.add_progress("tap_10", 1)' in game),
("upgrade hook",'QuestSystem.add_progress("upgrade_1", 1)' in game),
("daily telemetry",'daily_claim"' in game),
("quest telemetry",'quest_claim"' in game),
("cycle 7",len(cycle)==7),
("quests 3",len(quest_cfg)==3),
("ids",{q.get("id") for q in quest_cfg}=={"tap_10","spin_3","upgrade_1"}),
("source reward preservation",
 cycle==[
  {"day":1,"gold":300},{"day":2,"spins":5},{"day":3,"gold":600},
  {"day":4,"gems":25},{"day":5,"spins":10},{"day":6,"gold":1200},
  {"day":7,"gems":75,"spins":15}
 ]),
("schema V20","const SAVE_VERSION := 20" in save),
("primary nav",'text = "HOME"' in scene and 'text = "SPIN"' in scene and 'text = "DORF"' in scene)
]
for label,ok in checks:
    if not ok: errors.append(label)

# The legacy town-hall function used to increment upgrade_1 twice in the same path.
town=game[game.find("func _on_town_hall_pressed"):game.find("func _on_tap_upgrade_pressed")]
if town.count('QuestSystem.add_progress("upgrade_1", 1)') > 1:
    errors.append("legacy townhall duplicate upgrade progress")

print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.32","daily_days":len(cycle),"quests":len(quest_cfg)},indent=2))
sys.exit(1 if errors else 0)

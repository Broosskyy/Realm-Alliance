from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
project=(root/"project.godot").read_text(encoding="utf-8")
service=(root/"MonsterDefeatService.gd").read_text(encoding="utf-8")
hero=(root/"HeroSystem.gd").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
errors=[]
checks=[
("version",'config/version="1.43"' in project or 'config/version="1.49"' in project or 'config/version="1.48"' in project or 'config/version="1.47"' in project or 'config/version="1.46"' in project or 'config/version="1.45"' in project or 'config/version="1.44"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("autoload",'MonsterDefeatService="*res://MonsterDefeatService.gd"' in project),
("service commit",'func commit_defeat(source: String)' in service),
("service hp guard",'PlayerData.current_monster_hp > 0' in service),
("reward once",service.count("PlayerData.reward_monster_kill()")==1),
("boss spins",'PlayerData.add_spin(boss_bonus_spins)' in service),
("boss dice",'DiceJourneySystem.grant_dice' in service),
("meta",'MetaProgressSystem.register_boss_defeat()' in service),
("spawn",'PlayerData.spawn_next_monster()' in service),
("save before emit",service.find("SaveGame.save_game()") < service.find("defeat_committed.emit(result)")),
("hero shared",'MonsterDefeatService.commit_defeat("auto_dps")' in hero),
("hero no direct reward",'PlayerData.reward_monster_kill()' not in hero),
("hero no direct spawn",'PlayerData.spawn_next_monster()' not in hero),
("tap shared",'MonsterDefeatService.commit_defeat("tap")' in game),
("presentation",'func _present_monster_defeat_v143(result: Dictionary)' in game),
("signal",'MonsterDefeatService.defeat_committed' in game),
("old scaffold removed",'_resolve_monster_defeat_v142' not in game),
("schema",'const SAVE_VERSION := 20' in save),
]
for label,ok in checks:
    if not ok: errors.append(label)
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.43"},indent=2))
sys.exit(1 if errors else 0)

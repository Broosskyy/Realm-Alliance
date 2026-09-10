from pathlib import Path
import json,sys
from PIL import Image
root=Path(__file__).resolve().parents[1]
project=(root/"project.godot").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
live=(root/"LiveOpsRankingSystem.gd").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/liveops_v1_44.json").read_text(encoding="utf-8"))
swap=json.loads((root/"data/asset_swap_map_v1_46.json").read_text(encoding="utf-8"))
errors=[]
checks=[
("version",'config/version="1.46"' in project or 'config/version="1.49"' in project or 'config/version="1.48"' in project or 'config/version="1.47"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("config version",cfg.get("config_version")=="v1.46-halloween-liveops-02"),
("currency","halloween_tokens" in live and "pumpkin_tokens" in str(cfg)),
("metrics",all(x in live for x in ["register_journey_lap","register_puzzle_match","register_spin"])),
("quests","claim_ready_halloween_quests" in live and len(cfg["halloween_2026"].get("quests",[]))==3),
("chest","open_halloween_chest" in live and "HalloweenChestP0" in scene),
("ui currency","HalloweenCurrencyP0" in scene and "halloween_currency_p0" in game),
("cross hooks",all(x in game for x in ["register_puzzle_match(1)","register_journey_lap()","register_spin()"])),
("ranking safety",cfg["multiplayer_contract"]["local_fake_players_forbidden"] is True and cfg["multiplayer_contract"]["reward_claim_requires_signed_server_result"] is True),
("swap",len(swap.get("slots",[]))==8),
("save integration",'"liveops_ranking": LiveOpsRankingSystem.export_save_data()' in save),
("schema",'const SAVE_VERSION := 20' in save)
]
for label,ok in checks:
    if not ok: errors.append(label)
assets=list((root/"assets/v146_halloween").glob("V146_*.png"))
if len(assets)!=8: errors.append("asset count")
for a in assets:
    im=Image.open(a)
    if im.size!=(768,768) or im.mode!="RGBA": errors.append("asset format:"+a.name)
print(json.dumps({"ok":not errors,"errors":errors,"assets":len(assets),"source":"V1.46"},indent=2))
sys.exit(1 if errors else 0)

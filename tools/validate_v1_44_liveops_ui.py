from pathlib import Path
import json,sys
root=Path(__file__).resolve().parents[1]
project=(root/"project.godot").read_text(encoding="utf-8")
game=(root/"MainGame.gd").read_text(encoding="utf-8")
scene=(root/"MainGame.tscn").read_text(encoding="utf-8")
save=(root/"SaveGame.gd").read_text(encoding="utf-8")
live=(root/"LiveOpsRankingSystem.gd").read_text(encoding="utf-8")
afk=(root/"AfkRewardSystem.gd").read_text(encoding="utf-8")
shop=(root/"PurchaseService.gd").read_text(encoding="utf-8")
responsive=(root/"ResponsiveLayout.gd").read_text(encoding="utf-8")
cfg=json.loads((root/"data/liveops_v1_44.json").read_text(encoding="utf-8"))
errors=[]
checks=[
("version",'config/version="1.44"' in project or 'config/version="1.49"' in project or 'config/version="1.48"' in project or 'config/version="1.47"' in project or 'config/version="1.46"' in project or 'config/version="1.45"' in project or 'config/version="1.50"' in project or 'config/version="1.51"' in project or 'config/version="1.52"' in project or 'config/version="1.53"' in project),
("liveops autoload",'LiveOpsRankingSystem="*res://LiveOpsRankingSystem.gd"' in project),
("afk autoload",'AfkRewardSystem="*res://AfkRewardSystem.gd"' in project),
("progress autoload",'ProgressionOverviewSystem="*res://ProgressionOverviewSystem.gd"' in project),
("halloween config",'halloween_2026' in cfg and cfg["halloween_2026"]["target"]==10),
("ranking types",all(k in cfg.get("leaderboards",{}) for k in ["daily","weekly","event"])),
("no fake contract",cfg.get("multiplayer_contract",{}).get("local_fake_players_forbidden") is True),
("server reward contract",cfg.get("multiplayer_contract",{}).get("reward_claim_requires_signed_server_result") is True),
("afk cap",'const MAX_SECONDS := 28800' in afk),
("afk persistence",'"pending_reward":pending_reward.duplicate(true)' in afk and '"afk_rewards": AfkRewardSystem.export_save_data()' in save),
("shop hardened",'const PRODUCTION_PURCHASES_ENABLED := false' in shop),
("shop overlay",'name="ShopOverlayP0"' in scene and "func _hub_open_shop_p0()" in game),
("liveops overlay",'name="LiveOpsOverlayP0"' in scene and "func _hub_open_liveops_p0()" in game),
("progress overlay",'name="ProgressionOverlayP0"' in scene and "ProgressionOverviewSystem.summary_text()" in game),
("afk overlay",'name="AfkOverlayP0"' in scene and "func _claim_afk_reward_p0()" in game),
("modal aware",all(x in game for x in ["liveops_overlay_p0.visible","shop_overlay_p0.visible","progression_overlay_p0.visible","afk_overlay_p0.visible"])),
("responsive",all(x in responsive for x in ["LiveOpsOverlayP0","ShopOverlayP0","ProgressionOverlayP0","AfkOverlayP0"])),
("save v20",'const SAVE_VERSION := 20' in save)
]
for label,ok in checks:
    if not ok: errors.append(label)
assets=list((root/"assets/v144_liveops").glob("V144_*.png"))
if len(assets)!=8: errors.append("asset count")
print(json.dumps({"ok":not errors,"errors":errors,"source":"V1.44","assets":len(assets)},indent=2))
sys.exit(1 if errors else 0)

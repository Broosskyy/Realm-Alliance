extends Node

signal boss_snapshot_changed
signal boss_attack_result(result: Dictionary)
signal boss_reward_result(result: Dictionary)

const CONTRACT_VERSION := "guild-raid-v2"
var snapshot_data: Dictionary = {}
var last_revision: int = 0
var concurrency_token: String = ""
var last_attack_request_id: String = ""
var phase_snapshot: Dictionary = {}
var contribution_tiers: Array[Dictionary] = []
var reward_tiers: Array[Dictionary] = []

func request_phase() -> Dictionary:
	return _post("guild_boss_phase",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("guild_boss_phase"),
		"boss_id":str(snapshot_data.get("boss_id",""))
	})

func request_contribution() -> Dictionary:
	return _post("guild_boss_contribution",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("guild_boss_contribution"),
		"boss_id":str(snapshot_data.get("boss_id",""))
	})

func request_reward_tiers() -> Dictionary:
	return _post("guild_boss_reward_tiers",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("guild_boss_reward_tiers"),
		"boss_id":str(snapshot_data.get("boss_id",""))
	})

func request_snapshot() -> Dictionary:
	return _post("guild_boss_snapshot",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("guild_boss_snapshot")
	})

func attack(loadout_revision: int = 0) -> Dictionary:
	if not GuildService.has_guild():
		return {"ok":false,"error_code":"NO_GUILD"}
	if not LoadoutSnapshotService.has_published_snapshot():
		return {"ok":false,"error_code":"LOADOUT_SNAPSHOT_REQUIRED"}
	if concurrency_token.is_empty():
		return {"ok":false,"error_code":"BOSS_CONCURRENCY_TOKEN_REQUIRED"}
	var request_id := OnlineAuthorityService.new_request_id("guild_boss_attack")
	last_attack_request_id = request_id
	return _post("guild_boss_attack",{
		"contract_version":CONTRACT_VERSION,
		"request_id":request_id,
		"guild_id":str(GuildService.guild.get("guild_id","")),
		"boss_id":str(snapshot_data.get("boss_id","")),
		"expected_boss_revision":last_revision,
		"concurrency_token":concurrency_token,
		"loadout_snapshot_id":LoadoutSnapshotService.published_snapshot_id,
		"loadout_revision":maxi(loadout_revision,LoadoutSnapshotService.published_revision)
	})

func claim_reward() -> Dictionary:
	if not bool(snapshot_data.get("reward_claimable",false)):
		return {"ok":false,"error_code":"REWARD_NOT_CLAIMABLE"}
	return _post("guild_boss_claim",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("guild_boss_claim"),
		"guild_id":str(GuildService.guild.get("guild_id","")),
		"boss_id":str(snapshot_data.get("boss_id","")),
		"reward_claim_id":str(snapshot_data.get("reward_claim_id",""))
	})

func _post(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready():
		return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())

func accept_snapshot_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < last_revision:
		return false
	var boss = envelope.get("boss",{})
	if typeof(boss) != TYPE_DICTIONARY:
		return false
	var max_hp := maxi(int(boss.get("max_hp",0)),1)
	snapshot_data = {
		"boss_id":str(boss.get("boss_id","")),
		"name":str(boss.get("name","Gildenboss")).left(32),
		"max_hp":max_hp,
		"current_hp":clampi(int(boss.get("current_hp",max_hp)),0,max_hp),
		"phase":maxi(int(boss.get("phase",1)),1),
		"ends_unix":maxi(int(boss.get("ends_unix",0)),0),
		"player_contribution":maxi(int(boss.get("player_contribution",0)),0),
		"guild_contribution":maxi(int(boss.get("guild_contribution",0)),0),
		"reward_claimable":bool(boss.get("reward_claimable",false)),
		"reward_claim_id":str(boss.get("reward_claim_id","")),
		"phase_id":str(boss.get("phase_id","phase_%d" % maxi(int(boss.get("phase",1)),1))),
		"phase_progress":clampf(float(boss.get("phase_progress",0.0)),0.0,1.0)
	}
	concurrency_token = str(envelope.get("concurrency_token",boss.get("concurrency_token","")))
	last_revision = revision
	boss_snapshot_changed.emit()
	return true

func accept_attack_envelope(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)):
		return false
	var response_request_id := str(envelope.get("request_id",""))
	if not last_attack_request_id.is_empty() and response_request_id != last_attack_request_id:
		return false
	var accepted := accept_snapshot_envelope(envelope)
	if accepted:
		boss_attack_result.emit(envelope)
	return accepted

func accept_claim_envelope(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)):
		return false
	boss_reward_result.emit(envelope)
	if envelope.has("boss"):
		return accept_snapshot_envelope(envelope)
	return true


func accept_phase_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < last_revision:
		return false
	var phase = envelope.get("phase",{})
	if typeof(phase) != TYPE_DICTIONARY:
		return false
	phase_snapshot = {
		"phase_id":str(phase.get("phase_id","")),
		"index":maxi(int(phase.get("index",1)),1),
		"title":str(phase.get("title","Phase")).left(32),
		"hp_threshold":clampf(float(phase.get("hp_threshold",1.0)),0.0,1.0),
		"damage_multiplier":maxf(float(phase.get("damage_multiplier",1.0)),0.0),
		"ends_unix":maxi(int(phase.get("ends_unix",0)),0)
	}
	return true

func accept_contribution_envelope(envelope: Dictionary) -> bool:
	var incoming = envelope.get("tiers",[])
	if typeof(incoming) != TYPE_ARRAY:
		return false
	contribution_tiers.clear()
	for item in incoming:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		contribution_tiers.append({
			"tier_id":str(item.get("tier_id","")),
			"required_contribution":maxi(int(item.get("required_contribution",0)),0),
			"reached":bool(item.get("reached",false)),
			"claim_id":str(item.get("claim_id",""))
		})
	return true

func accept_reward_tiers_envelope(envelope: Dictionary) -> bool:
	var incoming = envelope.get("tiers",[])
	if typeof(incoming) != TYPE_ARRAY:
		return false
	reward_tiers.clear()
	for item in incoming:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		reward_tiers.append({
			"tier_id":str(item.get("tier_id","")),
			"rank_min":maxi(int(item.get("rank_min",0)),0),
			"rank_max":maxi(int(item.get("rank_max",0)),0),
			"reward_preview":Dictionary(item.get("reward_preview",{})).duplicate(true),
			"claim_id":str(item.get("claim_id",""))
		})
	return true

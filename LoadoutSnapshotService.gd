extends Node

signal loadout_published(snapshot_id: String, revision: int)
signal loadout_changed

const CONTRACT_VERSION := "loadout-snapshot-v1"

var published_snapshot_id: String = ""
var published_revision: int = 0
var last_published_fingerprint: String = ""

func build_candidate_snapshot() -> Dictionary:
	var selected_hero := HeroSystem.get_selected_hero_id()
	var heroes: Array[Dictionary] = []
	for hero_id in ["knight","archer","mage"]:
		var card := HeroSystem.get_card_data(hero_id)
		if card.is_empty():
			continue
		heroes.append({
			"hero_id":hero_id,
			"unlocked":bool(card.get("unlocked",false)),
			"level":maxi(int(card.get("level",1)),1),
			"power":maxi(int(card.get("power",0)),0),
			"weapon_tier":clampi(int(card.get("weapon_tier",0)),0,3),
			"charm_tier":clampi(int(card.get("charm_tier",0)),0,3),
			"mastery_level":maxi(int(card.get("mastery_level",1)),1)
		})
	return {
		"contract_version":CONTRACT_VERSION,
		"client_build":BuildInfo.SOURCE_VERSION,
		"selected_hero_id":selected_hero,
		"tap_level":PlayerData.tap_level,
		"tap_damage":PlayerData.tap_damage,
		"player_level":PlayerData.player_level,
		"heroes":heroes
	}

func candidate_fingerprint() -> String:
	return str(hash(JSON.stringify(build_candidate_snapshot())))

func publish_candidate() -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get("loadout_publish","/v1/loadout/publish"))
	var payload := {
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("loadout_publish"),
		"expected_revision":published_revision,
		"fingerprint":candidate_fingerprint(),
		"loadout":build_candidate_snapshot()
	}
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())

func request_server_snapshot() -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get("loadout_snapshot","/v1/loadout/snapshot"))
	return OnlineTransportService.post_json(route,{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("loadout_snapshot")
	},AuthSessionService.auth_header())

func accept_loadout_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < published_revision:
		return false
	var snapshot_id := str(envelope.get("snapshot_id",""))
	if snapshot_id.is_empty():
		return false
	published_snapshot_id = snapshot_id
	published_revision = revision
	last_published_fingerprint = str(envelope.get("fingerprint",""))
	loadout_changed.emit()
	loadout_published.emit(published_snapshot_id,published_revision)
	return true

func published_reference() -> Dictionary:
	return {
		"snapshot_id":published_snapshot_id,
		"revision":published_revision,
		"fingerprint":last_published_fingerprint
	}

func has_published_snapshot() -> bool:
	return not published_snapshot_id.is_empty()

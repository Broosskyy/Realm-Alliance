extends Node

signal defense_team_changed
signal defense_team_published(snapshot_id: String, revision: int)

const CONTRACT_VERSION := "defense-team-v1"

var selected_hero_ids: Array[String] = []
var defense_snapshot_id: String = ""
var defense_revision: int = 0
var last_fingerprint: String = ""

func set_local_team(hero_ids: Array[String]) -> Dictionary:
	var clean: Array[String] = []
	for hero_id in hero_ids:
		if hero_id not in ["knight","archer","mage"]:
			continue
		if not HeroSystem.is_unlocked(hero_id):
			continue
		if not clean.has(hero_id):
			clean.append(hero_id)
	if clean.is_empty():
		return {"ok":false,"error_code":"NO_VALID_HERO"}
	if clean.size() > 3:
		clean.resize(3)
	selected_hero_ids = clean
	defense_team_changed.emit()
	return {"ok":true,"heroes":selected_hero_ids.duplicate()}

func build_candidate() -> Dictionary:
	var ids := selected_hero_ids.duplicate()
	if ids.is_empty():
		var selected := HeroSystem.get_selected_hero_id()
		if HeroSystem.is_unlocked(selected):
			ids.append(selected)
	var heroes: Array[Dictionary] = []
	for hero_id in ids:
		var card := HeroSystem.get_card_data(hero_id)
		if card.is_empty():
			continue
		heroes.append({
			"hero_id":hero_id,
			"level":maxi(int(card.get("level",1)),1),
			"power":maxi(int(card.get("power",0)),0),
			"weapon_tier":clampi(int(card.get("weapon_tier",0)),0,3),
			"charm_tier":clampi(int(card.get("charm_tier",0)),0,3),
			"mastery_level":maxi(int(card.get("mastery_level",1)),1)
		})
	return {
		"contract_version":CONTRACT_VERSION,
		"heroes":heroes,
		"player_level":PlayerData.player_level,
		"tap_level":PlayerData.tap_level
	}

func fingerprint() -> String:
	return str(hash(JSON.stringify(build_candidate())))

func publish() -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	var candidate := build_candidate()
	if Array(candidate.get("heroes",[])).is_empty():
		return {"ok":false,"error_code":"EMPTY_DEFENSE_TEAM"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get("pvp_defense_team_publish","/v1/pvp/defense-team/publish"))
	return OnlineTransportService.post_json(route,{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("defense_team_publish"),
		"expected_revision":defense_revision,
		"fingerprint":fingerprint(),
		"team":candidate
	},AuthSessionService.auth_header())

func request_server_team() -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get("pvp_defense_team_get","/v1/pvp/defense-team"))
	return OnlineTransportService.post_json(route,{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("defense_team_get")
	},AuthSessionService.auth_header())

func accept_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < defense_revision:
		return false
	var snapshot_id := str(envelope.get("defense_snapshot_id",""))
	if snapshot_id.is_empty():
		return false
	var team = envelope.get("team",{})
	if typeof(team) != TYPE_DICTIONARY:
		return false
	var heroes = team.get("heroes",[])
	if typeof(heroes) != TYPE_ARRAY:
		return false
	selected_hero_ids.clear()
	for item in heroes:
		if typeof(item) == TYPE_DICTIONARY:
			var hero_id := str(item.get("hero_id",""))
			if hero_id in ["knight","archer","mage"] and not selected_hero_ids.has(hero_id):
				selected_hero_ids.append(hero_id)
	defense_snapshot_id = snapshot_id
	defense_revision = revision
	last_fingerprint = str(envelope.get("fingerprint",""))
	defense_team_changed.emit()
	defense_team_published.emit(defense_snapshot_id,defense_revision)
	return true

func has_server_snapshot() -> bool:
	return not defense_snapshot_id.is_empty()

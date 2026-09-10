extends Node

signal social_changed

var read_message_ids: Array[String] = []
var achievement_seen_ids: Array[String] = []

const MESSAGES := [
	{"id":"welcome","title":"Willkommen in REALM ALLIANCE","body":"Dein Abenteuer in Grünhain hat begonnen."},
	{"id":"account","title":"Account & Cloud","body":"Dein lokaler Spielstand funktioniert ohne Online-Konto. Cloud-Verknüpfung folgt mit dem Backend."},
	{"id":"community","title":"Community","body":"Offizielle Community-Kanäle werden für den Release zentral konfiguriert."}
]

func profile_snapshot() -> Dictionary:
	return {
		"name": AccountState.display_name if not AccountState.is_guest() else "Gastheld",
		"level": PlayerData.player_level,
		"region": "Grünhain",
		"bosses": MetaProgressSystem.boss_defeats,
		"village": P0VillageSystem.get_level("townhall"),
		"chests": MetaProgressSystem.realm_chests_opened
	}

func achievements() -> Array:
	return [
		{"id":"first_steps","title":"Erste Schritte","description":"Erreiche Account-Level 2.","current":PlayerData.player_level,"target":2},
		{"id":"greenvale_guard","title":"Wächter von Grünhain","description":"Besiege 3 Bosse.","current":MetaProgressSystem.boss_defeats,"target":3},
		{"id":"builder","title":"Reichsbauer","description":"Bringe das Rathaus auf Stufe 3.","current":P0VillageSystem.get_level("townhall"),"target":3},
		{"id":"chest_seeker","title":"Schatzsucher","description":"Öffne eine Realm Chest.","current":MetaProgressSystem.realm_chests_opened,"target":1}
	]

func completed_achievement_count() -> int:
	var count := 0
	for item in achievements():
		if int(item.current) >= int(item.target):
			count += 1
	return count

func unread_count() -> int:
	var count := 0
	for message in MESSAGES:
		if not read_message_ids.has(str(message.id)):
			count += 1
	return count

func mark_all_read() -> void:
	for message in MESSAGES:
		var message_id := str(message.id)
		if not read_message_ids.has(message_id):
			read_message_ids.append(message_id)
	social_changed.emit()
	SaveGame.save_game()

func export_save_data() -> Dictionary:
	return {
		"read_message_ids":read_message_ids.duplicate(),
		"achievement_seen_ids":achievement_seen_ids.duplicate()
	}

func apply_save_data(data: Dictionary) -> void:
	read_message_ids.assign(data.get("read_message_ids", []))
	achievement_seen_ids.assign(data.get("achievement_seen_ids", []))
	social_changed.emit()

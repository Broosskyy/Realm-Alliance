extends Node

signal unlocked(id: String, title: String)

const UNLOCKS := [
	{"id":"daily","level":3,"title":"Tagesaufgaben"},
	{"id":"heroes","level":5,"title":"Helden"},
	{"id":"attack","level":7,"title":"Angriff"},
	{"id":"defense","level":10,"title":"Verteidigung"}
]

var seen: Array[String] = []

func refresh() -> void:
	for entry in UNLOCKS:
		if PlayerData.player_level >= int(entry.level) and not seen.has(str(entry.id)):
			seen.append(str(entry.id))
			unlocked.emit(str(entry.id),str(entry.title))
			SaveGame.save_game()

func export_save_data() -> Dictionary:
	return {"seen":seen}

func apply_save_data(data: Dictionary) -> void:
	seen.clear()
	for item in data.get("seen",[]):
		seen.append(str(item))

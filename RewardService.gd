extends Node

signal reward_ready(payload: Dictionary)

func present(payload: Dictionary) -> void:
	reward_ready.emit(payload)

func gold(amount: int, title: String = "Belohnung") -> void:
	present({"title":title,"gold":amount})

func mixed(title: String, gold: int = 0, gems: int = 0, spins: int = 0, xp: int = 0) -> void:
	present({
		"title":title,
		"gold":gold,
		"gems":gems,
		"spins":spins,
		"xp":xp
	})

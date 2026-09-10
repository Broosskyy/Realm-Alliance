extends Node

signal settings_changed

var sound_enabled: bool = true
var music_enabled: bool = true
var haptics_enabled: bool = true
var reduced_motion: bool = false
var damage_numbers_enabled: bool = true
var screen_shake_enabled: bool = true
var language_code: String = "de"

func toggle_sound() -> void:
	sound_enabled = not sound_enabled
	settings_changed.emit()
	SaveGame.save_game()

func toggle_music() -> void:
	music_enabled = not music_enabled
	settings_changed.emit()
	SaveGame.save_game()

func toggle_haptics() -> void:
	haptics_enabled = not haptics_enabled
	settings_changed.emit()
	SaveGame.save_game()

func toggle_reduced_motion() -> void:
	reduced_motion = not reduced_motion
	settings_changed.emit()
	SaveGame.save_game()

func toggle_damage_numbers() -> void:
	damage_numbers_enabled = not damage_numbers_enabled
	settings_changed.emit()
	SaveGame.save_game()

func toggle_screen_shake() -> void:
	screen_shake_enabled = not screen_shake_enabled
	settings_changed.emit()
	SaveGame.save_game()

func cycle_language() -> void:
	language_code = "en" if language_code == "de" else "de"
	settings_changed.emit()
	SaveGame.save_game()

func export_save_data() -> Dictionary:
	return {
		"sound_enabled": sound_enabled,
		"music_enabled": music_enabled,
		"haptics_enabled": haptics_enabled,
		"reduced_motion": reduced_motion,
		"damage_numbers_enabled": damage_numbers_enabled,
		"screen_shake_enabled": screen_shake_enabled,
		"language_code": language_code
	}

func apply_save_data(data: Dictionary) -> void:
	sound_enabled = bool(data.get("sound_enabled", true))
	music_enabled = bool(data.get("music_enabled", true))
	haptics_enabled = bool(data.get("haptics_enabled", true))
	reduced_motion = bool(data.get("reduced_motion", false))
	damage_numbers_enabled = bool(data.get("damage_numbers_enabled", true))
	screen_shake_enabled = bool(data.get("screen_shake_enabled", true))
	language_code = str(data.get("language_code", "de"))
	settings_changed.emit()

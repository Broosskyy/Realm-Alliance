extends Node

const SFX := {
	"tap": "res://assets/audio/p0/sfx_tap.wav",
	"hit_heavy": "res://assets/audio/p0/sfx_hit_heavy.wav",
	"kill": "res://assets/audio/p0/sfx_kill.wav",
	"coin": "res://assets/audio/p0/sfx_coin.wav",
	"wheel_spin": "res://assets/audio/p0/sfx_wheel_spin.wav",
	"wheel_stop": "res://assets/audio/p0/sfx_wheel_stop.wav",
	"upgrade": "res://assets/audio/p0/sfx_upgrade.wav",
	"boss_intro": "res://assets/audio/p0/sfx_boss_intro.wav",
	"boss_defeat": "res://assets/audio/p0/sfx_boss_defeat.wav"
}
const MUSIC_GREENVALE := "res://assets/audio/p0/music_greenvale_loop_placeholder.wav"

var sfx_players: Array[AudioStreamPlayer] = []
var music_player: AudioStreamPlayer
var initialized_from_save: bool = false

func _ready() -> void:
	for _i in range(4):
		var player := AudioStreamPlayer.new()
		add_child(player)
		sfx_players.append(player)
	music_player = AudioStreamPlayer.new()
	add_child(music_player)

func initialize_after_save() -> void:
	initialized_from_save = true
	sync_settings()

func play_sfx(id: String) -> void:
	if not SettingsService.sound_enabled:
		return
	var path := str(SFX.get(id, ""))
	if path.is_empty() or not ResourceLoader.exists(path):
		return
	var player := _available_sfx_player()
	player.stream = load(path)
	player.play()

func sync_settings() -> void:
	if not initialized_from_save:
		return
	if not SettingsService.music_enabled:
		music_player.stop()
		return
	if not ResourceLoader.exists(MUSIC_GREENVALE):
		return
	if music_player.stream == null:
		music_player.stream = load(MUSIC_GREENVALE)
	if not music_player.playing:
		music_player.play()


func _available_sfx_player() -> AudioStreamPlayer:
	for player in sfx_players:
		if not player.playing:
			return player
	return sfx_players[0]

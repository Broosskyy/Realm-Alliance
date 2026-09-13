extends Node
## V2.04 — timed boss challenge with safe retry on failure.

signal challenge_started(state: Dictionary)
signal challenge_failed(state: Dictionary)
signal challenge_cleared(state: Dictionary)
signal challenge_tick(state: Dictionary)

var active: bool = false
var boss_level: int = 0
var time_remaining: float = 0.0
var failed: bool = false
var failure_count: int = 0
var last_failure_message: String = ""

func start_challenge(level: int) -> void:
	if not P0MonsterVisualSystem.is_boss(level):
		return
	active = true
	boss_level = level
	failed = false
	last_failure_message = ""
	time_remaining = GameConfig.boss_time_limit_seconds(level)
	challenge_started.emit(snapshot())

func tick(delta: float) -> void:
	if not active or failed:
		return
	time_remaining = maxf(time_remaining - delta, 0.0)
	challenge_tick.emit(snapshot())
	if time_remaining <= 0.0:
		_trigger_failure()

func on_boss_defeated() -> void:
	if not active and boss_level <= 0:
		return
	active = false
	failed = false
	last_failure_message = ""
	challenge_cleared.emit(snapshot())
	boss_level = 0
	time_remaining = 0.0

func prepare_retry(level: int) -> void:
	if not P0MonsterVisualSystem.is_boss(level):
		return
	start_challenge(level)

func _trigger_failure() -> void:
	active = false
	failed = true
	failure_count += 1
	last_failure_message = "ZEIT ABGELAUFEN · NOCHMAL!"
	PlayerData.current_monster_hp = PlayerData.monster_max_hp
	PlayerData.monster_changed.emit()
	challenge_failed.emit(snapshot())
	SaveGame.save_game()

func timer_label() -> String:
	if not active or not P0MonsterVisualSystem.is_boss(boss_level):
		return ""
	return "BOSS · %ds" % int(ceil(time_remaining))

func snapshot() -> Dictionary:
	return {
		"active": active,
		"boss_level": boss_level,
		"boss_state": "active" if active else ("failed" if failed else "idle"),
		"time_remaining": snapped(time_remaining, 0.1),
		"time_limit": GameConfig.boss_time_limit_seconds(boss_level) if boss_level > 0 else 0.0,
		"failed": failed,
		"failure_count": failure_count
	}

func export_save_data() -> Dictionary:
	return snapshot()

func apply_save_data(data: Dictionary) -> void:
	active = bool(data.get("active", false))
	boss_level = int(data.get("boss_level", 0))
	time_remaining = float(data.get("time_remaining", 0.0))
	failed = bool(data.get("failed", false))
	failure_count = int(data.get("failure_count", 0))

func reset_runtime() -> void:
	active = false
	boss_level = 0
	time_remaining = 0.0
	failed = false
	last_failure_message = ""

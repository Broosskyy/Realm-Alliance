extends Node

signal stats_changed
signal monster_changed
signal progression_changed
signal shop_changed(message: String)

var gold: int = 300
var gems: int = 0
var spins: int = P0RuntimeContract.STARTING_SPINS
var shields: int = 0:
	set(value):
		shields = clampi(value, 0, GameConfig.MAX_SHIELDS)
		stats_changed.emit()

var player_level: int = 1
var player_xp: int = 0

var village_level: int = 1
var tap_level: int = 1
var tap_damage: int = 10

var monster_level: int = 1
var monster_max_hp: int = 100
var current_monster_hp: int = 100

var owned_cosmetics: Array[String] = []
var active_cosmetic: String = "" # generic cosmetic slot
var no_ads_owned: bool = false
var daily_streak: int = 0
var last_daily_claim_unix: int = 0

func _ready() -> void:
	monster_max_hp = GameConfig.effective_monster_hp(monster_level)
	current_monster_hp = monster_max_hp

func add_gold(amount: int) -> void:
	gold += max(amount, 0)
	stats_changed.emit()

func spend_gold(amount: int) -> bool:
	if amount <= 0:
		return true
	if gold < amount:
		return false
	gold -= amount
	stats_changed.emit()
	return true

func add_gems(amount: int) -> void:
	gems += max(amount, 0)
	stats_changed.emit()

func spend_gems(amount: int) -> bool:
	if amount <= 0:
		return true
	if gems < amount:
		return false
	gems -= amount
	stats_changed.emit()
	return true

func use_spin() -> bool:
	if spins <= 0:
		return false
	spins -= 1
	stats_changed.emit()
	return true

func add_spin(amount: int = 1) -> void:
	spins += max(amount, 0)
	stats_changed.emit()

func add_xp(amount: int) -> void:
	player_xp += max(amount, 0)
	while player_xp >= GameConfig.player_xp_required(player_level):
		player_xp -= GameConfig.player_xp_required(player_level)
		player_level += 1
	progression_changed.emit()
	stats_changed.emit()

func increase_tap_damage() -> bool:
	var cost := GameConfig.tap_upgrade_cost(tap_level)
	if not spend_gold(cost):
		return false
	tap_level += 1
	tap_damage += GameConfig.TAP_DAMAGE_GAIN
	progression_changed.emit()
	stats_changed.emit()
	return true

func damage_monster(amount: int) -> bool:
	current_monster_hp = maxi(current_monster_hp - max(amount, 0), 0)
	monster_changed.emit()
	return current_monster_hp <= 0

func reward_monster_kill() -> Dictionary:
	var reward_gold := GameConfig.effective_monster_reward(monster_level)
	add_gold(reward_gold)
	add_xp(GameConfig.PLAYER_XP_PER_MONSTER)

	var bonus_spin := false
	if randf() <= GameConfig.BONUS_SPIN_CHANCE:
		add_spin(1)
		bonus_spin = true

	return {
		"gold": reward_gold,
		"bonus_spin": bonus_spin,
		"xp": GameConfig.PLAYER_XP_PER_MONSTER
	}

func spawn_next_monster() -> void:
	monster_level += 1
	monster_max_hp = GameConfig.effective_monster_hp(monster_level)
	current_monster_hp = monster_max_hp
	monster_changed.emit()
	progression_changed.emit()

func upgrade_village() -> bool:
	var cost := GameConfig.village_upgrade_cost(village_level)
	if not spend_gold(cost):
		return false
	village_level += 1
	progression_changed.emit()
	stats_changed.emit()
	return true

func grant_product(product_id: String, payload: Dictionary) -> void:
	if payload.has("gold"):
		add_gold(int(payload.gold))
	if payload.has("gems"):
		add_gems(int(payload.gems))
	if payload.has("spins"):
		add_spin(int(payload.spins))
	if payload.has("no_ads") and bool(payload.no_ads):
		no_ads_owned = true
	if payload.has("cosmetic"):
		var cosmetic_id := str(payload.cosmetic)
		if not owned_cosmetics.has(cosmetic_id):
			owned_cosmetics.append(cosmetic_id)
	shop_changed.emit("Produkt erhalten: %s" % product_id)
	stats_changed.emit()


func apply_save_data(data: Dictionary) -> void:
	gold = int(data.get("gold", gold))
	gems = int(data.get("gems", gems))
	spins = int(data.get("spins", spins))
	shields = int(data.get("shields", shields))
	player_level = int(data.get("player_level", player_level))
	player_xp = int(data.get("player_xp", player_xp))
	village_level = int(data.get("village_level", village_level))
	tap_level = int(data.get("tap_level", tap_level))
	tap_damage = int(data.get("tap_damage", tap_damage))
	monster_level = int(data.get("monster_level", monster_level))
	monster_max_hp = int(data.get("monster_max_hp", GameConfig.effective_monster_hp(monster_level)))
	current_monster_hp = int(data.get("current_monster_hp", monster_max_hp))
	owned_cosmetics.assign(data.get("owned_cosmetics", []))
	no_ads_owned = bool(data.get("no_ads_owned", false))
	daily_streak = int(data.get("daily_streak", daily_streak))
	last_daily_claim_unix = int(data.get("last_daily_claim_unix", last_daily_claim_unix))
	stats_changed.emit()
	monster_changed.emit()
	progression_changed.emit()

extends Node

# Zentrale, datengetriebene Balancewerte.
# Spaeter idealerweise aus JSON/Remote Config/Admin-Backend laden.

const MAX_SHIELDS := 3

const MONSTER_BASE_HP := 100
const MONSTER_HP_GROWTH := 1.085
const MONSTER_BASE_REWARD := 35
const MONSTER_REWARD_PER_LEVEL := 15
const BONUS_SPIN_CHANCE := 0.20

const VILLAGE_BASE_UPGRADE_COST := 500
const VILLAGE_UPGRADE_MULTIPLIER := 2.0

const TAP_UPGRADE_BASE_COST := 250
const TAP_UPGRADE_COST_GROWTH := 1.65
const TAP_DAMAGE_GAIN := 5

const PLAYER_XP_PER_MONSTER := 10
const PLAYER_LEVEL_XP_BASE := 100
const PLAYER_LEVEL_XP_GROWTH := 1.35

const SPIN_GOLD_MIN := 120
const SPIN_GOLD_MAX := 350

func monster_hp_for_level(level: int) -> int:
	return int(round(MONSTER_BASE_HP * pow(MONSTER_HP_GROWTH, max(level - 1, 0))))

func monster_reward_for_level(level: int) -> int:
	return MONSTER_BASE_REWARD + max(level, 1) * MONSTER_REWARD_PER_LEVEL

func village_upgrade_cost(level: int) -> int:
	return int(round(VILLAGE_BASE_UPGRADE_COST * pow(VILLAGE_UPGRADE_MULTIPLIER, max(level - 1, 0))))

func tap_upgrade_cost(tap_level: int) -> int:
	return int(round(TAP_UPGRADE_BASE_COST * pow(TAP_UPGRADE_COST_GROWTH, max(tap_level - 1, 0))))

func player_xp_required(level: int) -> int:
	return int(round(PLAYER_LEVEL_XP_BASE * pow(PLAYER_LEVEL_XP_GROWTH, max(level - 1, 0))))


# ------------------------------
# V0.4 HERO FOUNDATION
# Spieler sieht nur: Level, Stärke, Upgrade.
# Interne Werte bleiben bewusst klein.
# ------------------------------
const HERO_UNLOCK_ACCOUNT_LEVEL := 5
const HERO_LEVEL_CAP := 20
const HERO_UPGRADE_BASE_COST := 180
const HERO_UPGRADE_COST_GROWTH := 1.42
const AUTO_ATTACK_INTERVAL := 1.0

func hero_upgrade_cost(hero_level: int, cost_modifier: float = 1.0) -> int:
	return int(round(
		HERO_UPGRADE_BASE_COST
		* cost_modifier
		* pow(HERO_UPGRADE_COST_GROWTH, max(hero_level - 1, 0))
	))


# V0.6 core-feel balance placeholders.
# Bosses remain short highlight moments, not long walls.
const BOSS_HP_MULTIPLIER := 2.4
const BOSS_REWARD_MULTIPLIER := 3.0

func effective_monster_hp(level: int) -> int:
	var hp := monster_hp_for_level(level)
	if level % 10 == 0:
		hp = int(round(hp * BOSS_HP_MULTIPLIER))
	return hp

func effective_monster_reward(level: int) -> int:
	var reward := monster_reward_for_level(level)
	if level % 10 == 0:
		reward = int(round(reward * BOSS_REWARD_MULTIPLIER))
	return reward


# V0.8 Tower Defense prototype targets
const DEFENSE_UNLOCK_ACCOUNT_LEVEL := 10
const DEFENSE_TARGET_DURATION := 55.0
const DEFENSE_BASE_REWARD := 260

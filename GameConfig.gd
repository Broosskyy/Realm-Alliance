extends Node

# Zentrale, datengetriebene Balancewerte.
# Spaeter idealerweise aus JSON/Remote Config/Admin-Backend laden.

const MAX_SHIELDS := 3

const MONSTER_BASE_HP := 100
const MONSTER_HP_GROWTH := 1.085
const MONSTER_BASE_REWARD := 40
const MONSTER_REWARD_PER_LEVEL := 14
const BONUS_SPIN_CHANCE := 0.22

const VILLAGE_BASE_UPGRADE_COST := 500
const VILLAGE_UPGRADE_MULTIPLIER := 2.0

const TAP_UPGRADE_BASE_COST := 220
const TAP_UPGRADE_COST_GROWTH := 1.65
const TAP_DAMAGE_GAIN := 5

const CRIT_BASE_CHANCE := 0.08
const CRIT_CHANCE_PER_LEVEL := 0.015
const CRIT_CHANCE_CAP := 0.35
const CRIT_BASE_MULTIPLIER := 2.0
const CRIT_DAMAGE_BONUS_PER_LEVEL := 0.12
const CRIT_DAMAGE_MULTIPLIER_CAP := 4.0
const CRIT_UPGRADE_BASE_COST := 320
const CRIT_UPGRADE_COST_GROWTH := 1.68

const PLAYER_XP_PER_MONSTER := 10
const PLAYER_LEVEL_XP_BASE := 50
const PLAYER_LEVEL_XP_GROWTH := 1.28

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

func crit_upgrade_cost(crit_level: int) -> int:
	return int(round(CRIT_UPGRADE_BASE_COST * pow(CRIT_UPGRADE_COST_GROWTH, max(crit_level - 1, 0))))

func effective_crit_chance(crit_level: int = -1) -> float:
	var level := crit_level if crit_level >= 0 else PlayerData.crit_level
	return clampf(CRIT_BASE_CHANCE + float(maxi(level - 1, 0)) * CRIT_CHANCE_PER_LEVEL, 0.0, CRIT_CHANCE_CAP)

func effective_crit_multiplier(crit_level: int = -1) -> float:
	var level := crit_level if crit_level >= 0 else PlayerData.crit_level
	return clampf(CRIT_BASE_MULTIPLIER + float(maxi(level - 1, 0)) * CRIT_DAMAGE_BONUS_PER_LEVEL, CRIT_BASE_MULTIPLIER, CRIT_DAMAGE_MULTIPLIER_CAP)

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
const BOSS_HP_MULTIPLIER := 2.35
const BOSS_REWARD_MULTIPLIER := 3.2
const BOSS_TIME_LIMIT_BASE := 45.0
const BOSS_TIME_LIMIT_MIN := 32.0

const AFK_MIN_SECONDS := 120
const AFK_MAX_SECONDS := 28800
const AFK_GOLD_PER_MINUTE_BASE := 8
const AFK_PROGRESSION_GOLD_PER_LEVEL := 2
const AFK_VILLAGE_RATE_REFERENCE := 30

func effective_monster_hp(level: int) -> int:
	var encounter_hp := EncounterStatService.effective_hp(level)
	if encounter_hp > 0:
		return encounter_hp
	var hp := monster_hp_for_level(level)
	if level % 10 == 0:
		hp = int(round(hp * BOSS_HP_MULTIPLIER))
	return hp

func effective_monster_reward(level: int) -> int:
	var encounter_reward := EncounterStatService.gold_reward(level)
	if encounter_reward > 0:
		return encounter_reward
	var reward := monster_reward_for_level(level)
	if level % 10 == 0:
		reward = int(round(reward * BOSS_REWARD_MULTIPLIER))
	return reward

func boss_time_limit_seconds(level: int) -> float:
	var cycle := maxi(int((level - 1) / 10), 0)
	return maxf(BOSS_TIME_LIMIT_BASE - float(cycle) * 1.5, BOSS_TIME_LIMIT_MIN)

func afk_gold_for_seconds(seconds: int, player_level: int = -1) -> int:
	var capped := clampi(seconds, 0, AFK_MAX_SECONDS)
	if capped < AFK_MIN_SECONDS:
		return 0
	var minutes := maxi(int(capped / 60), 1)
	var pl := player_level if player_level >= 0 else PlayerData.player_level
	var progression_bonus := maxi(pl - 1, 0) * AFK_PROGRESSION_GOLD_PER_LEVEL
	var village_rate := float(P0VillageSystem.goldmine_rate_per_minute())
	var village_mult := 1.0 + maxf(village_rate - float(AFK_VILLAGE_RATE_REFERENCE), 0.0) / float(AFK_VILLAGE_RATE_REFERENCE) * 0.35
	return int(round(float(minutes) * float(AFK_GOLD_PER_MINUTE_BASE + progression_bonus) * village_mult))


# V0.8 Tower Defense prototype targets
const DEFENSE_UNLOCK_ACCOUNT_LEVEL := 10
const DEFENSE_TARGET_DURATION := 55.0
const DEFENSE_BASE_REWARD := 260

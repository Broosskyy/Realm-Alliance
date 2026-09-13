extends Node
## V2.09 — data-driven encounter stats from region encounter catalogs.

const VALID_CLASSIFICATIONS := ["normal", "tough", "elite", "boss", "special"]
const ATTACK_STATE_HOOK := "res://docs/v209_asset_convergence/attack_state_hook.md"

static func stats_for_level(level: int) -> Dictionary:
	var def := P0MonsterVisualSystem.encounter_definition(level)
	var stats: Dictionary = def.get("stats", {})
	if stats.is_empty():
		return _fallback_stats(level)
	return stats

static func _fallback_stats(level: int) -> Dictionary:
	var cls := P0MonsterVisualSystem.monster_classification(level)
	var loot_kind := cls
	if cls == "special":
		loot_kind = "elite"
	return {
		"base_hp": 0,
		"hp_scaling": 1.0,
		"xp_reward": GameConfig.PLAYER_XP_PER_MONSTER,
		"reward_multiplier": 1.0,
		"loot_source": RegionProgressionSystem.loot_source_for(loot_kind),
		"loot_roll_chance": 0.0
	}

static func effective_hp(level: int) -> int:
	var breakdown := hp_breakdown(level)
	return int(breakdown.get("effective_hp", 0))

static func hp_breakdown(level: int) -> Dictionary:
	var stats := stats_for_level(level)
	var base_hp := int(stats.get("base_hp", 0))
	if base_hp <= 0:
		return {
			"base_hp": 0,
			"hp_scaling": 1.0,
			"stage_in_cycle": EncounterProgressService.stage_in_cycle(level),
			"stage_factor": 1.0,
			"classification": P0MonsterVisualSystem.monster_classification(level),
			"effective_hp": 0
		}
	var scaling := float(stats.get("hp_scaling", 1.0))
	var stage := EncounterProgressService.stage_in_cycle(level)
	var stage_factor := 1.0
	if scaling > 1.0 and stage > 1:
		stage_factor = pow(scaling, float(stage - 1) * 0.15)
	return {
		"base_hp": base_hp,
		"hp_scaling": scaling,
		"stage_in_cycle": stage,
		"stage_factor": stage_factor,
		"classification": P0MonsterVisualSystem.monster_classification(level),
		"effective_hp": maxi(int(round(float(base_hp) * stage_factor)), 1)
	}

static func xp_reward(level: int) -> int:
	return maxi(int(stats_for_level(level).get("xp_reward", GameConfig.PLAYER_XP_PER_MONSTER)), 1)

static func gold_reward(level: int) -> int:
	var stats := stats_for_level(level)
	var explicit_gold := int(stats.get("gold_reward", 0))
	if explicit_gold > 0:
		return explicit_gold
	var mult := float(stats.get("reward_multiplier", 1.0))
	return maxi(int(round(float(GameConfig.monster_reward_for_level(level)) * mult)), 1)

static func loot_source_id(level: int) -> String:
	var stats := stats_for_level(level)
	var source := str(stats.get("loot_source", "")).strip_edges()
	if not source.is_empty():
		return source
	var cls := P0MonsterVisualSystem.monster_classification(level)
	match cls:
		"boss":
			return RegionProgressionSystem.loot_source_for("boss")
		"elite", "special":
			return RegionProgressionSystem.loot_source_for("elite")
		"tough":
			return RegionProgressionSystem.loot_source_for("tough")
		_:
			return RegionProgressionSystem.loot_source_for("normal")

static func loot_roll_chance(level: int) -> float:
	return clampf(float(stats_for_level(level).get("loot_roll_chance", 0.0)), 0.0, 1.0)

static func should_roll_loot(level: int) -> bool:
	if P0MonsterVisualSystem.is_boss(level):
		return true
	var chance := loot_roll_chance(level)
	if chance <= 0.0:
		return false
	return randf() <= chance

static func roll_loot_items(level: int) -> Array:
	if not should_roll_loot(level):
		return []
	return LootTableService.roll(loot_source_id(level))

static func presentation(level: int) -> Dictionary:
	var def := P0MonsterVisualSystem.encounter_definition(level)
	var visual: Dictionary = def.get("visual", {})
	var anchors: Dictionary = def.get("anchors", {})
	return {
		"display_scale": float(visual.get("display_scale", P0MonsterVisualSystem.display_scale(level))),
		"display_offset": Vector2(
			float(visual.get("offset_x", 0.0)),
			float(visual.get("offset_y", 0.0))
		),
		"hit_anchor": anchors.get("hit", visual.get("hit_anchor", {})),
		"damage_text_anchor": anchors.get("damage_text", visual.get("damage_text_anchor", {})),
		"vfx_anchor": anchors.get("vfx", visual.get("vfx_anchor", {}))
	}

static func attack_state_supported() -> bool:
	# No player-HP / monster-attack cadence pillar exists in V2.09 combat.
	return false

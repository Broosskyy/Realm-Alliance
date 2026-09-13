extends RefCounted
class_name CombatDamageResolver

## V2.07 — unified damage contract for TAP, Heroes, and future sources.

static var last_hit: Dictionary = {}
static var force_next_crit: bool = false

static func resolve_damage(request: Dictionary) -> Dictionary:
	var source_type := str(request.get("source_type", "tap"))
	var base_damage := maxi(int(request.get("base_damage", 0)), 0)
	var source_id := str(request.get("source_id", ""))
	var target_id := str(request.get("target_id", ""))
	if source_type == "tap":
		return resolve_tap(base_damage)
	if source_type == "hero":
		var mods := StatModifierService.get_hero_modifiers(source_id)
		var is_boss := P0MonsterVisualSystem.is_boss(PlayerData.monster_level)
		var damage := StatModifierService.apply_damage_modifiers(base_damage, mods, "hero_damage", is_boss)
		last_hit = {
			"damage": damage,
			"base_damage": base_damage,
			"source": "hero",
			"source_type": "hero",
			"source_id": source_id,
			"target_id": target_id,
			"critical": false,
			"crit_chance": 0.0,
			"crit_multiplier": 1.0,
			"momentum_multiplier": 1.0,
			"item_modifier_count": mods.size(),
			"timestamp_unix": ServerClockService.now_unix()
		}
		return last_hit.duplicate(true)
	last_hit = {
		"damage": maxi(1, base_damage),
		"base_damage": base_damage,
		"source": source_type,
		"source_type": source_type,
		"source_id": source_id,
		"target_id": target_id,
		"critical": false,
		"crit_chance": 0.0,
		"crit_multiplier": 1.0,
		"momentum_multiplier": 1.0,
		"timestamp_unix": ServerClockService.now_unix()
	}
	return last_hit.duplicate(true)

static func resolve_tap(base_damage: int) -> Dictionary:
	var synergy_base := CoreProgressionSynergySystem.apply_tap_synergy(base_damage)
	var mods := StatModifierService.get_deployed_hero_modifiers()
	var item_flat := StatModifierService.aggregate_flat(mods, "tap_damage")
	var item_pct := StatModifierService.aggregate_percent(mods, "tap_damage")
	var boosted := int(round(float(synergy_base + item_flat) * (1.0 + item_pct / 100.0)))
	var crit_chance := GameConfig.effective_crit_chance() + StatModifierService.aggregate_flat(mods, "crit_chance") / 100.0
	crit_chance = clampf(crit_chance, 0.0, 0.95)
	var critical := force_next_crit or randf() < crit_chance
	force_next_crit = false
	var crit_mult := GameConfig.effective_crit_multiplier()
	if StatModifierService.aggregate_flat(mods, "crit_damage") > 0.0:
		crit_mult += StatModifierService.aggregate_flat(mods, "crit_damage") / 100.0
	crit_mult = crit_mult if critical else 1.0
	var momentum := CombatMomentumSystem.damage_multiplier()
	var damage := maxi(1, int(round(float(boosted) * momentum * crit_mult)))
	last_hit = {
		"damage": damage,
		"base_damage": base_damage,
		"synergy_base": synergy_base,
		"boosted_base": boosted,
		"critical": critical,
		"crit_chance": crit_chance,
		"crit_multiplier": crit_mult,
		"momentum_multiplier": momentum,
		"source": "tap",
		"source_type": "tap",
		"source_id": "player_tap",
		"target_id": P0MonsterVisualSystem.encounter_id_for_level(PlayerData.monster_level),
		"item_modifier_count": mods.size(),
		"timestamp_unix": ServerClockService.now_unix()
	}
	return last_hit.duplicate(true)

static func preview_tap(base_damage: int) -> Dictionary:
	var synergy_base := CoreProgressionSynergySystem.apply_tap_synergy(base_damage)
	var mods := StatModifierService.get_deployed_hero_modifiers()
	var item_flat := StatModifierService.aggregate_flat(mods, "tap_damage")
	var item_pct := StatModifierService.aggregate_percent(mods, "tap_damage")
	var boosted := int(round(float(synergy_base + item_flat) * (1.0 + item_pct / 100.0)))
	var momentum := CombatMomentumSystem.damage_multiplier()
	var normal := maxi(1, int(round(float(boosted) * momentum)))
	var crit_mult := GameConfig.effective_crit_multiplier()
	if StatModifierService.aggregate_flat(mods, "crit_damage") > 0.0:
		crit_mult += StatModifierService.aggregate_flat(mods, "crit_damage") / 100.0
	var crit := maxi(1, int(round(float(boosted) * momentum * crit_mult)))
	var crit_chance := GameConfig.effective_crit_chance() + StatModifierService.aggregate_flat(mods, "crit_chance") / 100.0
	return {
		"normal": normal,
		"crit": crit,
		"crit_chance_pct": int(round(clampf(crit_chance, 0.0, 0.95) * 100.0)),
		"crit_multiplier": crit_mult,
		"item_tap_bonus": int(item_flat)
	}

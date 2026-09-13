extends Node

signal heroes_changed
signal auto_damage_done(amount: int)
signal hero_unlocked(hero_id: String)
signal hero_deployed(hero_id: String)

const CombatDamageResolver = preload("res://CombatDamageResolver.gd")

var hero_defs: Dictionary = {}
var hero_levels: Dictionary = {
	"knight": 1,
	"archer": 1,
	"mage": 1
}
var hero_owned: Dictionary = {
	"knight": false,
	"archer": false,
	"mage": false
}
var hero_equipment: Dictionary = {
	"knight": {"weapon": 0, "charm": 0},
	"archer": {"weapon": 0, "charm": 0},
	"mage": {"weapon": 0, "charm": 0}
}
var _auto_timer: float = 0.0
var selected_hero_id: String = "knight"
var deployed_hero_id: String = ""

func _ready() -> void:
	_load_hero_defs()
	set_process(FeatureFlags.ENABLE_HERO_AUTODPS)
	_refresh_unlocks()

func _process(delta: float) -> void:
	if not FeatureFlags.ENABLE_HERO_AUTODPS:
		return
	_refresh_unlocks()
	var hero_id := get_deployed_hero_id()
	if hero_id.is_empty():
		return
	var interval := get_attack_interval(hero_id)
	if interval <= 0.0:
		return
	_auto_timer += delta
	if _auto_timer < interval:
		return
	_auto_timer -= interval
	if PlayerData.current_monster_hp <= 0:
		return
	var base_power := get_base_power(hero_id)
	if base_power <= 0:
		return
	var target_id := P0MonsterVisualSystem.encounter_id_for_level(PlayerData.monster_level)
	var hit := CombatDamageResolver.resolve_damage({
		"source_type": "hero",
		"source_id": hero_id,
		"base_damage": base_power,
		"target_id": target_id
	})
	var damage := maxi(int(hit.get("damage", base_power)), 1)
	var killed := PlayerData.damage_monster(damage)
	auto_damage_done.emit(damage)
	GameplayEventService.publish(GameplayEventService.EVENT_HERO_ATTACK, 1, {
		"hero_id": hero_id,
		"damage": damage,
		"target_id": target_id
	})
	if killed:
		MonsterDefeatService.commit_defeat("hero_auto")

func _load_hero_defs() -> void:
	var path := "res://data/heroes.json"
	if not FileAccess.file_exists(path):
		return
	var file := FileAccess.open(path, FileAccess.READ)
	if not file:
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		return
	for hero in parsed.get("heroes", []):
		hero_defs[str(hero.id)] = hero

func _refresh_unlocks() -> void:
	var changed := false
	for hero_id in hero_defs.keys():
		var hero: Dictionary = hero_defs[hero_id]
		var required := int(hero.get("unlock_account_level", 999))
		if PlayerData.player_level >= required and not bool(hero_owned.get(hero_id, false)):
			hero_owned[hero_id] = true
			changed = true
			hero_unlocked.emit(str(hero_id))
			GameplayEventService.publish(GameplayEventService.EVENT_HERO_UNLOCKED, 1, {"hero_id": str(hero_id)})
	if changed:
		if deployed_hero_id.is_empty() or not is_unlocked(deployed_hero_id):
			for hero_id in hero_defs.keys():
				if is_unlocked(str(hero_id)):
					deploy_hero(str(hero_id), false)
					break
		heroes_changed.emit()

func is_unlocked(hero_id: String) -> bool:
	return bool(hero_owned.get(hero_id, false))

func is_deployed(hero_id: String) -> bool:
	return deployed_hero_id == hero_id and is_unlocked(hero_id)

func deploy_hero(hero_id: String, save: bool = true) -> bool:
	if not is_unlocked(hero_id):
		return false
	deployed_hero_id = hero_id
	_auto_timer = 0.0
	hero_deployed.emit(hero_id)
	GameplayEventService.publish(GameplayEventService.EVENT_HERO_DEPLOYED, 1, {"hero_id": hero_id})
	heroes_changed.emit()
	if save:
		SaveGame.save_game()
	return true

func get_deployed_hero_id() -> String:
	if is_unlocked(deployed_hero_id):
		return deployed_hero_id
	return ""

func select_hero(hero_id: String) -> bool:
	if not is_unlocked(hero_id):
		return false
	selected_hero_id = hero_id
	heroes_changed.emit()
	SaveGame.save_game()
	return true

func get_selected_hero_id() -> String:
	if is_unlocked(selected_hero_id):
		return selected_hero_id
	for hero_id in hero_defs.keys():
		if is_unlocked(str(hero_id)):
			selected_hero_id = str(hero_id)
			return selected_hero_id
	return "knight"

func get_attack_interval(hero_id: String) -> float:
	var hero: Dictionary = hero_defs.get(hero_id, {})
	return maxf(float(hero.get("attack_interval", GameConfig.AUTO_ATTACK_INTERVAL)), 0.1)

func get_level(hero_id: String) -> int:
	return int(hero_levels.get(hero_id, 1))

func get_base_power(hero_id: String) -> int:
	if not is_unlocked(hero_id):
		return 0
	var hero: Dictionary = hero_defs.get(hero_id, {})
	if hero.is_empty():
		return 0
	var level := get_level(hero_id)
	var scaling := int(hero.get("power_scaling", hero.get("power_per_level", 0)))
	var base_power := int(hero.get("base_power", 0)) + scaling * (level - 1)
	return base_power + get_legacy_tier_power(hero_id) + HeroProgressionSystem.specialization_power_bonus(hero_id)

func get_power(hero_id: String) -> int:
	return get_base_power(hero_id)

func get_effective_attack_damage(hero_id: String) -> int:
	if not is_unlocked(hero_id):
		return 0
	var base := get_base_power(hero_id)
	var mods := StatModifierService.get_hero_modifiers(hero_id)
	var is_boss := P0MonsterVisualSystem.is_boss(PlayerData.monster_level)
	return StatModifierService.apply_damage_modifiers(base, mods, "hero_damage", is_boss)

func get_power_breakdown(hero_id: String) -> Dictionary:
	if not is_unlocked(hero_id):
		return {}
	var hero: Dictionary = hero_defs.get(hero_id, {})
	if hero.is_empty():
		return {}
	var level := get_level(hero_id)
	var scaling := int(hero.get("power_scaling", hero.get("power_per_level", 0)))
	var base_power := int(hero.get("base_power", 0)) + scaling * (level - 1)
	var legacy_tier_power := get_legacy_tier_power(hero_id)
	var specialization_power := HeroProgressionSystem.specialization_power_bonus(hero_id)
	var item_power := StatModifierService.hero_damage_bonus(hero_id)
	var mods := StatModifierService.get_hero_modifiers(hero_id)
	var is_boss := P0MonsterVisualSystem.is_boss(PlayerData.monster_level)
	return {
		"hero_id": hero_id,
		"level": level,
		"base_power": base_power,
		"legacy_tier_power": legacy_tier_power,
		"specialization_power": specialization_power,
		"item_equipment_power": item_power,
		"combat_damage": StatModifierService.apply_damage_modifiers(get_base_power(hero_id), mods, "hero_damage", is_boss)
	}

func get_dps(hero_id: String) -> float:
	if not is_unlocked(hero_id):
		return 0.0
	var interval := get_attack_interval(hero_id)
	if interval <= 0.0:
		return 0.0
	return float(get_effective_attack_damage(hero_id)) / interval

func get_total_auto_dps() -> float:
	var hero_id := get_deployed_hero_id()
	if hero_id.is_empty():
		return 0.0
	return get_dps(hero_id)

func get_equipment_power(hero_id: String) -> int:
	return get_legacy_tier_power(hero_id)

func get_legacy_tier_power(hero_id: String) -> int:
	var eq: Dictionary = hero_equipment.get(hero_id, {})
	var bonus_table: Array = [0, 2, 5, 9]
	var total := 0
	for slot in ["weapon", "charm"]:
		var tier := clampi(int(eq.get(slot, 0)), 0, 3)
		total += int(bonus_table[tier])
	return total

func get_item_equipment_power(hero_id: String) -> int:
	return StatModifierService.hero_damage_bonus(hero_id)

func equipment_upgrade_cost(hero_id: String, slot: String) -> int:
	if slot not in ["weapon", "charm"] or not is_unlocked(hero_id):
		return 0
	var tier := int(hero_equipment.get(hero_id, {}).get(slot, 0))
	if tier >= 3:
		return 0
	return 240 * (tier + 1) * (tier + 1)

func upgrade_equipment(hero_id: String, slot: String) -> bool:
	if not is_unlocked(hero_id) or slot not in ["weapon", "charm"]:
		return false
	var eq: Dictionary = hero_equipment.get(hero_id, {"weapon": 0, "charm": 0})
	var tier := int(eq.get(slot, 0))
	if tier >= 3:
		return false
	var cost := equipment_upgrade_cost(hero_id, slot)
	if cost <= 0:
		return false
	var authority_intent := OnlineAuthorityService.build_intent("hero_equipment_upgrade", {
		"hero_id": hero_id,
		"slot": slot,
		"from_tier": tier,
		"to_tier": tier + 1,
		"cost": cost
	})
	var economy_result := EconomyAuthorityService.commit_gold_spend_local(
		authority_intent,
		cost,
		{"hero_id": hero_id, "slot": slot, "to_tier": tier + 1}
	)
	if not bool(economy_result.get("ok", false)):
		return false
	eq[slot] = tier + 1
	hero_equipment[hero_id] = eq
	heroes_changed.emit()
	SaveGame.save_game()
	return true

func get_upgrade_cost(hero_id: String) -> int:
	var hero: Dictionary = hero_defs.get(hero_id, {})
	if hero.is_empty():
		return 0
	return GameConfig.hero_upgrade_cost(
		get_level(hero_id),
		float(hero.get("cost_modifier", 1.0))
	)

func upgrade(hero_id: String) -> bool:
	if not is_unlocked(hero_id):
		return false
	var level := get_level(hero_id)
	if level >= GameConfig.HERO_LEVEL_CAP:
		return false
	var cost := get_upgrade_cost(hero_id)
	var authority_intent := OnlineAuthorityService.build_intent("hero_upgrade", {
		"hero_id": hero_id,
		"from_level": level,
		"to_level": level + 1,
		"cost": cost
	})
	var economy_result := EconomyAuthorityService.commit_gold_spend_local(
		authority_intent,
		cost,
		{"hero_id": hero_id, "to_level": level + 1}
	)
	if not bool(economy_result.get("ok", false)):
		return false
	hero_levels[hero_id] = level + 1
	GameplayEventService.publish(GameplayEventService.EVENT_HERO_LEVELED, 1, {
		"hero_id": hero_id,
		"level": level + 1
	})
	heroes_changed.emit()
	SaveGame.save_game()
	return true

func get_card_data(hero_id: String) -> Dictionary:
	var hero: Dictionary = hero_defs.get(hero_id, {})
	if hero.is_empty():
		return {}
	var unlocked := is_unlocked(hero_id)
	return {
		"id": hero_id,
		"name": str(hero.get("name", hero_id)),
		"role": str(hero.get("role", "")),
		"rarity": str(hero.get("rarity", "common")),
		"description": str(hero.get("description", "")),
		"unlock_level": int(hero.get("unlock_account_level", 999)),
		"unlocked": unlocked,
		"owned": unlocked,
		"deployed": is_deployed(hero_id),
		"level": get_level(hero_id),
		"power": get_power(hero_id),
		"effective_damage": get_effective_attack_damage(hero_id),
		"dps": snapped(get_dps(hero_id), 0.1),
		"attack_interval": get_attack_interval(hero_id),
		"equipment_power": get_equipment_power(hero_id),
		"legacy_tier_power": get_legacy_tier_power(hero_id),
		"item_equipment_power": get_item_equipment_power(hero_id),
		"power_breakdown": get_power_breakdown(hero_id),
		"weapon_tier": int(hero_equipment.get(hero_id, {}).get("weapon", 0)),
		"charm_tier": int(hero_equipment.get(hero_id, {}).get("charm", 0)),
		"upgrade_cost": get_upgrade_cost(hero_id),
		"mastery_level": int(HeroProgressionSystem.mastery_level.get(hero_id, 1)),
		"mastery_xp": int(HeroProgressionSystem.mastery_xp.get(hero_id, 0)),
		"specialization": HeroProgressionSystem.specialization_text(hero_id),
		"specialization_enabled": bool(HeroProgressionSystem.specialization_enabled.get(hero_id, false))
	}

func sync_progression_unlocks() -> void:
	_refresh_unlocks()

func force_attack_tick() -> Dictionary:
	if not FeatureFlags.ENABLE_HERO_AUTODPS:
		return {"ok": false, "message": "auto dps disabled"}
	var hero_id := get_deployed_hero_id()
	if hero_id.is_empty() or PlayerData.current_monster_hp <= 0:
		return {"ok": false, "message": "no deployed hero"}
	var base_power := get_base_power(hero_id)
	var target_id := P0MonsterVisualSystem.encounter_id_for_level(PlayerData.monster_level)
	var hit := CombatDamageResolver.resolve_damage({
		"source_type": "hero",
		"source_id": hero_id,
		"base_damage": base_power,
		"target_id": target_id
	})
	var damage := maxi(int(hit.get("damage", base_power)), 1)
	var hp_before := PlayerData.current_monster_hp
	var killed := PlayerData.damage_monster(damage)
	auto_damage_done.emit(damage)
	GameplayEventService.publish(GameplayEventService.EVENT_HERO_ATTACK, 1, {
		"hero_id": hero_id,
		"damage": damage,
		"target_id": target_id
	})
	if killed:
		MonsterDefeatService.commit_defeat("hero_auto")
	return {
		"ok": true,
		"hero_id": hero_id,
		"damage": damage,
		"hp_before": hp_before,
		"hp_after": PlayerData.current_monster_hp,
		"hit": hit
	}

func reset_runtime() -> void:
	hero_levels = {"knight": 1, "archer": 1, "mage": 1}
	hero_owned = {"knight": false, "archer": false, "mage": false}
	hero_equipment = {
		"knight": {"weapon": 0, "charm": 0},
		"archer": {"weapon": 0, "charm": 0},
		"mage": {"weapon": 0, "charm": 0}
	}
	selected_hero_id = "knight"
	deployed_hero_id = ""
	_auto_timer = 0.0
	_load_hero_defs()
	_refresh_unlocks()
	heroes_changed.emit()

func export_save_data() -> Dictionary:
	return {
		"levels": hero_levels.duplicate(true),
		"owned": hero_owned.duplicate(true),
		"equipment": hero_equipment.duplicate(true),
		"selected_hero_id": selected_hero_id,
		"deployed_hero_id": deployed_hero_id
	}

func apply_save_data(data: Dictionary) -> void:
	selected_hero_id = str(data.get("selected_hero_id", selected_hero_id))
	deployed_hero_id = str(data.get("deployed_hero_id", deployed_hero_id))
	var levels = data.get("levels", {})
	var owned = data.get("owned", {})
	var equipment = data.get("equipment", {})
	if typeof(levels) == TYPE_DICTIONARY:
		for id in levels:
			hero_levels[str(id)] = int(levels[id])
	if typeof(owned) == TYPE_DICTIONARY:
		for id in owned:
			hero_owned[str(id)] = bool(owned[id])
	if typeof(equipment) == TYPE_DICTIONARY:
		for id in equipment:
			if typeof(equipment[id]) == TYPE_DICTIONARY:
				hero_equipment[str(id)] = equipment[id].duplicate(true)
	_refresh_unlocks()
	heroes_changed.emit()

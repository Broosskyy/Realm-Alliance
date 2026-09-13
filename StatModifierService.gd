extends Node
## V2.07 Phase 2 — runtime source of truth for equipment stat modifiers.

const CONFIG_VERSION := "v2.07-stat-modifier-02"

const VALID_STATS := [
	"tap_damage",
	"hero_damage",
	"crit_chance",
	"crit_damage",
	"gold_reward",
	"boss_damage",
	"attack_speed"
]

const VALID_OPERATIONS := ["flat", "percent"]

var _modifiers_by_hero: Dictionary = {}

func _ready() -> void:
	if not ItemInventoryService.inventory_changed.is_connected(_rebuild_all):
		ItemInventoryService.inventory_changed.connect(_rebuild_all)
	call_deferred("rebuild_all")

func rebuild_all() -> void:
	_rebuild_all()

func _rebuild_all() -> void:
	_modifiers_by_hero.clear()
	for hero_id in ItemInventoryService.equipped_by_hero.keys():
		var hero_map: Dictionary = ItemInventoryService.equipped_by_hero[hero_id]
		var mods: Array = []
		for slot in hero_map.keys():
			var instance_id := str(hero_map.get(slot, ""))
			if instance_id.is_empty():
				continue
			var inst := ItemInventoryService.get_instance(instance_id)
			var item_id := str(inst.get("item_id", ""))
			if item_id.is_empty():
				continue
			var def := ItemInventoryService.get_item_definition(item_id)
			if def.is_empty():
				continue
			mods.append_array(modifiers_from_item_definition(def, instance_id))
		_modifiers_by_hero[str(hero_id)] = mods

func get_hero_modifiers(hero_id: String) -> Array:
	return (_modifiers_by_hero.get(hero_id, []) as Array).duplicate(true)

func get_deployed_hero_modifiers() -> Array:
	var hero_id := HeroSystem.get_deployed_hero_id()
	if hero_id.is_empty():
		return []
	return get_hero_modifiers(hero_id)

func build_modifier(source_type: String, source_id: String, stat: String, operation: String, value: float) -> Dictionary:
	return {
		"source_type": source_type,
		"source_id": source_id,
		"stat": stat,
		"operation": operation if operation in VALID_OPERATIONS else "flat",
		"value": float(value)
	}

func modifiers_from_item_definition(item_def: Dictionary, instance_id: String) -> Array:
	var out: Array = []
	for entry in item_def.get("modifiers", []):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var stat := str(entry.get("stat", ""))
		if stat not in VALID_STATS:
			continue
		out.append(build_modifier(
			"item",
			instance_id,
			stat,
			str(entry.get("operation", "flat")),
			float(entry.get("value", 0))
		))
	return out

func aggregate_flat(modifiers: Array, stat: String) -> float:
	var total := 0.0
	for mod in modifiers:
		if typeof(mod) != TYPE_DICTIONARY:
			continue
		if str(mod.get("stat", "")) != stat:
			continue
		if str(mod.get("operation", "flat")) == "flat":
			total += float(mod.get("value", 0))
	return total

func aggregate_percent(modifiers: Array, stat: String) -> float:
	var total := 0.0
	for mod in modifiers:
		if typeof(mod) != TYPE_DICTIONARY:
			continue
		if str(mod.get("stat", "")) != stat:
			continue
		if str(mod.get("operation", "flat")) == "percent":
			total += float(mod.get("value", 0))
	return total

func apply_damage_modifiers(base_damage: int, modifiers: Array, stat: String, is_boss: bool = false) -> int:
	var flat := aggregate_flat(modifiers, stat)
	var pct := aggregate_percent(modifiers, stat)
	var damage := float(maxi(base_damage, 0) + flat) * (1.0 + pct / 100.0)
	if is_boss:
		damage *= 1.0 + aggregate_percent(modifiers, "boss_damage") / 100.0
	return maxi(1, int(round(damage)))

func hero_damage_bonus(hero_id: String) -> int:
	return int(aggregate_flat(get_hero_modifiers(hero_id), "hero_damage"))

func tap_damage_bonus() -> int:
	return int(aggregate_flat(get_deployed_hero_modifiers(), "tap_damage"))

func export_debug_state() -> Dictionary:
	return {
		"config_version": CONFIG_VERSION,
		"heroes": _modifiers_by_hero.duplicate(true)
	}

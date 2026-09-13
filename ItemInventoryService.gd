extends Node
## V2.07 — authoritative local item instance inventory (RPG bag, separate from IAP entitlements).

signal inventory_changed

const DATA_PATH := "res://data/items_v207.json"
const CONFIG_VERSION := "v2.07-item-inventory-01"

var catalog: Dictionary = {}
var catalog_meta: Dictionary = {}
var instances: Dictionary = {}
var equipped_by_hero: Dictionary = {}
var validation_errors: Array[String] = []

var _sequence: int = 0
var _granted_transactions: Dictionary = {}

func _ready() -> void:
	_load_and_validate_catalog()

func _load_and_validate_catalog() -> void:
	validation_errors.clear()
	catalog.clear()
	var file := FileAccess.open(DATA_PATH, FileAccess.READ)
	if file == null:
		validation_errors.append("item catalog missing: %s" % DATA_PATH)
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		validation_errors.append("item catalog parse failed")
		return
	catalog_meta = {
		"version": str(parsed.get("version", "")),
		"valid_rarities": parsed.get("valid_rarities", []),
		"valid_slots": parsed.get("valid_slots", []),
		"valid_stats": parsed.get("valid_stats", []),
		"valid_operations": parsed.get("valid_operations", [])
	}
	var seen_ids: Dictionary = {}
	for entry in parsed.get("items", []):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var item_id := str(entry.get("item_id", ""))
		if item_id.is_empty():
			validation_errors.append("item missing item_id")
			continue
		if seen_ids.has(item_id):
			validation_errors.append("duplicate item_id: %s" % item_id)
			continue
		seen_ids[item_id] = true
		var errors := _validate_item_definition(entry)
		for err in errors:
			validation_errors.append("%s: %s" % [item_id, err])
		catalog[item_id] = entry.duplicate(true)
	if not validation_errors.is_empty():
		for err in validation_errors:
			push_error("[ItemInventoryService] %s" % err)

func _validate_item_definition(definition: Dictionary) -> Array[String]:
	var errors: Array[String] = []
	var rarity := str(definition.get("rarity", ""))
	if rarity.is_empty() or not _valid_rarities().has(rarity):
		errors.append("invalid rarity: %s" % rarity)
	var slot := str(definition.get("slot", ""))
	if slot.is_empty() or not _valid_slots().has(slot):
		errors.append("invalid slot: %s" % slot)
	var icon_role := str(definition.get("icon_asset", ""))
	if icon_role.is_empty() or AssetRegistry.production_texture_for(icon_role, false) == null:
		errors.append("icon asset not resolved: %s" % icon_role)
	for mod in definition.get("modifiers", []):
		if typeof(mod) != TYPE_DICTIONARY:
			errors.append("invalid modifier entry")
			continue
		var stat := str(mod.get("stat", ""))
		if stat not in _valid_stats():
			errors.append("invalid modifier stat: %s" % stat)
		var op := str(mod.get("operation", "flat"))
		if op not in _valid_operations():
			errors.append("invalid modifier operation: %s" % op)
	return errors

func _valid_rarities() -> Array:
	return catalog_meta.get("valid_rarities", ["common", "uncommon", "rare", "epic"])

func _valid_slots() -> Array:
	return catalog_meta.get("valid_slots", ["weapon", "accessory"])

func _valid_stats() -> Array:
	return catalog_meta.get("valid_stats", StatModifierService.VALID_STATS)

func _valid_operations() -> Array:
	return catalog_meta.get("valid_operations", StatModifierService.VALID_OPERATIONS)

func has_item_definition(item_id: String) -> bool:
	return catalog.has(item_id)

func get_item_definition(item_id: String) -> Dictionary:
	return catalog.get(item_id, {}).duplicate(true)

func catalog_count() -> int:
	return catalog.size()

func catalog_item_ids() -> Array:
	return catalog.keys()

func get_owned_instances() -> Array:
	var out: Array = []
	for instance_id in instances.keys():
		out.append(get_instance(instance_id))
	return out

func get_instance(instance_id: String) -> Dictionary:
	var inst: Dictionary = instances.get(instance_id, {})
	if inst.is_empty():
		return {}
	var item_id := str(inst.get("item_id", ""))
	var def := get_item_definition(item_id)
	return inst.duplicate(true).merged({
		"name": str(def.get("name", item_id)),
		"rarity": str(def.get("rarity", "common")),
		"slot": str(def.get("slot", "")),
		"icon_asset": str(def.get("icon_asset", ""))
	})

func snapshot_instance_count() -> int:
	return instances.size()

func grant_from_transaction(transaction_id: String, source: String, items: Array, metadata: Dictionary = {}) -> Dictionary:
	if transaction_id.is_empty():
		return {"ok": false, "error_code": "MISSING_TRANSACTION_ID"}
	if _granted_transactions.has(transaction_id):
		var cached: Dictionary = _granted_transactions[transaction_id].duplicate(true)
		cached["duplicate"] = true
		return cached
	var granted: Array = []
	for entry in items:
		if typeof(entry) != TYPE_DICTIONARY:
			return {"ok": false, "error_code": "INVALID_ITEM_ENTRY"}
		var item_id := str(entry.get("item_id", ""))
		var quantity := maxi(int(entry.get("quantity", 1)), 1)
		if not has_item_definition(item_id):
			return {"ok": false, "error_code": "UNKNOWN_ITEM", "item_id": item_id}
		var def := get_item_definition(item_id)
		if bool(def.get("stackable", false)):
			return {"ok": false, "error_code": "STACKABLE_NOT_IMPLEMENTED", "item_id": item_id}
		for _i in range(quantity):
			var created := _create_instance(item_id, source, metadata)
			if not bool(created.get("ok", false)):
				return created
			granted.append(created.get("instance", {}))
			GameplayEventService.publish(
				GameplayEventService.EVENT_ITEM_ACQUIRED,
				1,
				{
					"item_id": item_id,
					"instance_id": str(created.get("instance", {}).get("instance_id", "")),
					"source": source,
					"transaction_id": transaction_id,
					"rarity": str(def.get("rarity", ""))
				}
			)
	var result := {
		"ok": true,
		"duplicate": false,
		"transaction_id": transaction_id,
		"source": source,
		"granted_items": granted,
		"instance_ids": granted.map(func(inst): return str(inst.get("instance_id", ""))),
		"inventory_count": instances.size()
	}
	_granted_transactions[transaction_id] = result.duplicate(true)
	inventory_changed.emit()
	return result

func _create_instance(item_id: String, source: String, metadata: Dictionary) -> Dictionary:
	var def := get_item_definition(item_id)
	_sequence += 1
	var instance_id := "itm_%d_%d" % [ServerClockService.now_unix(), _sequence]
	var instance := {
		"instance_id": instance_id,
		"item_id": item_id,
		"acquired_source": source,
		"acquired_at": ServerClockService.now_unix(),
		"equipped": false,
		"equipped_to": "",
		"slot": str(def.get("slot", "")),
		"enhancement_level": 0,
		"metadata": metadata.duplicate(true)
	}
	instances[instance_id] = instance
	return {"ok": true, "instance": instance.duplicate(true)}

func can_equip_to_slot(instance_id: String, slot: String) -> bool:
	if not instances.has(instance_id):
		return false
	var inst := get_instance(instance_id)
	return str(inst.get("slot", "")) == slot

func equip(instance_id: String, hero_id: String, expected_slot: String = "") -> Dictionary:
	if hero_id.is_empty():
		return {"ok": false, "error_code": "MISSING_HERO_ID"}
	if not instances.has(instance_id):
		return {"ok": false, "error_code": "INSTANCE_NOT_FOUND"}
	var inst: Dictionary = instances[instance_id]
	var item_id := str(inst.get("item_id", ""))
	var def := get_item_definition(item_id)
	if def.is_empty():
		return {"ok": false, "error_code": "ITEM_DEFINITION_MISSING"}
	var slot := str(def.get("slot", ""))
	if slot.is_empty() or slot not in _valid_slots():
		return {"ok": false, "error_code": "INVALID_SLOT"}
	if not expected_slot.is_empty() and expected_slot != slot:
		return {"ok": false, "error_code": "WRONG_SLOT", "slot": slot, "expected_slot": expected_slot}
	if bool(inst.get("equipped", false)) and str(inst.get("equipped_to", "")) == hero_id:
		return {"ok": true, "instance_id": instance_id, "hero_id": hero_id, "slot": slot, "already_equipped": true}
	var hero_map: Dictionary = equipped_by_hero.get(hero_id, {})
	var previous_id := str(hero_map.get(slot, ""))
	if not previous_id.is_empty() and instances.has(previous_id) and previous_id != instance_id:
		instances[previous_id]["equipped"] = false
		instances[previous_id]["equipped_to"] = ""
	inst["equipped"] = true
	inst["equipped_to"] = hero_id
	inst["slot"] = slot
	instances[instance_id] = inst
	hero_map[slot] = instance_id
	equipped_by_hero[hero_id] = hero_map
	var rarity := str(def.get("rarity", "common"))
	GameplayEventService.publish(
		GameplayEventService.EVENT_ITEM_EQUIPPED,
		1,
		{
			"instance_id": instance_id,
			"item_id": item_id,
			"hero_id": hero_id,
			"slot": slot,
			"rarity": rarity,
			"previous_instance_id": previous_id
		}
	)
	inventory_changed.emit()
	StatModifierService.rebuild_all()
	SaveGame.save_game()
	return {
		"ok": true,
		"instance_id": instance_id,
		"item_id": item_id,
		"hero_id": hero_id,
		"slot": slot,
		"rarity": rarity,
		"previous_instance_id": previous_id
	}

func equip_for_deployed_hero(instance_id: String, expected_slot: String = "") -> Dictionary:
	var hero_id := HeroSystem.get_deployed_hero_id()
	if hero_id.is_empty():
		hero_id = HeroSystem.get_selected_hero_id()
	return equip(instance_id, hero_id, expected_slot)

func unequip(instance_id: String) -> Dictionary:
	if not instances.has(instance_id):
		return {"ok": false, "error_code": "INSTANCE_NOT_FOUND"}
	var inst: Dictionary = instances[instance_id]
	var hero_id := str(inst.get("equipped_to", ""))
	var slot := str(inst.get("slot", ""))
	inst["equipped"] = false
	inst["equipped_to"] = ""
	instances[instance_id] = inst
	if not hero_id.is_empty() and equipped_by_hero.has(hero_id):
		var hero_map: Dictionary = equipped_by_hero[hero_id]
		if str(hero_map.get(slot, "")) == instance_id:
			hero_map.erase(slot)
		equipped_by_hero[hero_id] = hero_map
	var item_id := str(inst.get("item_id", ""))
	var def := get_item_definition(item_id)
	GameplayEventService.publish(
		GameplayEventService.EVENT_ITEM_UNEQUIPPED,
		1,
		{
			"instance_id": instance_id,
			"item_id": item_id,
			"hero_id": hero_id,
			"slot": slot,
			"rarity": str(def.get("rarity", "common"))
		}
	)
	inventory_changed.emit()
	StatModifierService.rebuild_all()
	SaveGame.save_game()
	return {"ok": true, "instance_id": instance_id, "item_id": item_id, "hero_id": hero_id, "slot": slot}

func get_equipped_instance(hero_id: String, slot: String) -> Dictionary:
	var hero_map: Dictionary = equipped_by_hero.get(hero_id, {})
	var instance_id := str(hero_map.get(slot, ""))
	if instance_id.is_empty():
		return {}
	return get_instance(instance_id)

func normalize_item_grants(raw_items: Array) -> Dictionary:
	var normalized: Array = []
	var errors: Array[String] = []
	for entry in raw_items:
		if typeof(entry) != TYPE_DICTIONARY:
			errors.append("item entry must be dictionary")
			continue
		var item_id := str(entry.get("item_id", ""))
		if item_id.is_empty():
			errors.append("item entry missing item_id")
			continue
		if not has_item_definition(item_id):
			errors.append("unknown item_id: %s" % item_id)
			continue
		normalized.append({
			"item_id": item_id,
			"quantity": maxi(int(entry.get("quantity", 1)), 1)
		})
	return {"items": normalized, "valid": errors.is_empty(), "errors": errors}

func export_save_data() -> Dictionary:
	return {
		"config_version": CONFIG_VERSION,
		"instances": instances.duplicate(true),
		"equipped_by_hero": equipped_by_hero.duplicate(true),
		"sequence": _sequence,
		"granted_transactions": _granted_transactions.duplicate(true)
	}

func apply_save_data(data: Dictionary) -> void:
	instances.clear()
	equipped_by_hero.clear()
	_granted_transactions.clear()
	var raw_instances: Dictionary = data.get("instances", {})
	for key in raw_instances.keys():
		var entry = raw_instances[key]
		if typeof(entry) == TYPE_DICTIONARY:
			instances[str(key)] = entry.duplicate(true)
	var raw_equipped: Dictionary = data.get("equipped_by_hero", {})
	for hero_id in raw_equipped.keys():
		if typeof(raw_equipped[hero_id]) == TYPE_DICTIONARY:
			equipped_by_hero[str(hero_id)] = raw_equipped[hero_id].duplicate(true)
	_sequence = maxi(int(data.get("sequence", 0)), 0)
	var raw_txn: Dictionary = data.get("granted_transactions", {})
	for txn_id in raw_txn.keys():
		if typeof(raw_txn[txn_id]) == TYPE_DICTIONARY:
			_granted_transactions[str(txn_id)] = raw_txn[txn_id].duplicate(true)
	inventory_changed.emit()

func reset_runtime() -> void:
	instances.clear()
	equipped_by_hero.clear()
	_granted_transactions.clear()
	_sequence = 0
	inventory_changed.emit()

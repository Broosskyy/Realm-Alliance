extends RefCounted
class_name ItemUiPresentation

const ProductionUiBinder = preload("res://ProductionUiBinder.gd")

const RARITY_FRAME_ROLES := {
	"common": "ui.slot.rarity.1",
	"uncommon": "ui.slot.rarity.2",
	"rare": "ui.slot.rarity.3",
	"epic": "ui.slot.rarity.4"
}

const RARITY_LABELS := {
	"common": "GEWÖHNLICH",
	"uncommon": "UNGEWÖHNLICH",
	"rare": "SELTEN",
	"epic": "EPISCH"
}

const SLOT_LABELS := {
	"weapon": "WAFFE",
	"accessory": "ACCESSOIRE"
}

static func rarity_frame_role(rarity: String) -> String:
	return str(RARITY_FRAME_ROLES.get(rarity, "ui.slot.rarity.1"))

static func rarity_label(rarity: String) -> String:
	return str(RARITY_LABELS.get(rarity, rarity.to_upper()))

static func slot_label(slot: String) -> String:
	return str(SLOT_LABELS.get(slot, slot.to_upper()))

static func apply_icon(target: TextureRect, icon_role: String) -> void:
	var tex := AssetRegistry.production_texture_for(icon_role, false)
	if tex != null:
		target.texture = tex
		target.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		target.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED

static func apply_rarity_backdrop(target: Control, rarity: String, stretch: bool = true) -> void:
	ProductionUiBinder.apply_backdrop(target, rarity_frame_role(rarity), false, 0.12, stretch)

static func modifier_lines(definition: Dictionary) -> Array[String]:
	var lines: Array[String] = []
	for entry in definition.get("modifiers", []):
		if typeof(entry) != TYPE_DICTIONARY:
			continue
		var stat := str(entry.get("stat", ""))
		var op := str(entry.get("operation", "flat"))
		var value := float(entry.get("value", 0))
		var label := _stat_label(stat)
		if op == "percent":
			lines.append("%s +%.0f%%" % [label, value])
		else:
			lines.append("%s +%.0f" % [label, value])
	return lines

static func _stat_label(stat: String) -> String:
	match stat:
		"tap_damage":
			return "TAP-Schaden"
		"hero_damage":
			return "Helden-Schaden"
		"crit_chance":
			return "Krit-Chance"
		"crit_damage":
			return "Krit-Schaden"
		"boss_damage":
			return "Boss-Schaden"
		"gold_reward":
			return "Gold"
		"attack_speed":
			return "Angriffstempo"
		_:
			return stat

static func instance_card_summary(instance: Dictionary) -> Dictionary:
	var item_id := str(instance.get("item_id", ""))
	var def := ItemInventoryService.get_item_definition(item_id)
	return {
		"instance_id": str(instance.get("instance_id", "")),
		"item_id": item_id,
		"name": str(instance.get("name", def.get("name", item_id))),
		"rarity": str(instance.get("rarity", def.get("rarity", "common"))),
		"slot": str(instance.get("slot", def.get("slot", ""))),
		"icon_asset": str(instance.get("icon_asset", def.get("icon_asset", ""))),
		"equipped": bool(instance.get("equipped", false)),
		"equipped_to": str(instance.get("equipped_to", "")),
		"modifiers": modifier_lines(def)
	}

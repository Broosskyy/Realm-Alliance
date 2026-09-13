extends RefCounted

const ProductionUiBinder = preload("res://ProductionUiBinder.gd")

const HUD_ROLE_BY_PILL := {
	"GoldPillP0": "ui.hud.resource.gold",
	"SpinPillP0": "ui.hud.resource.spin",
	"ShieldPillP0": "ui.hud.resource.shield",
}

const LABEL_BY_PILL := {
	"GoldPillP0": "GoldLabel",
	"SpinPillP0": "SpinsLabel",
	"ShieldPillP0": "ShieldsLabel",
}

const HERO_PORTRAIT_ROLES := {
	"HeroKnight": "hero.knight.portrait",
	"HeroArcher": "hero.archer.portrait",
	"HeroMage": "hero.mage.portrait",
}

const HERO_IDS := {
	"HeroKnight": "knight",
	"HeroArcher": "archer",
	"HeroMage": "mage",
}

static func apply(root: Node) -> Dictionary:
	var applied := 0
	var skipped := 0
	for pill_name in HUD_ROLE_BY_PILL:
		var pill := root.find_child(pill_name, true, false) as TextureRect
		if pill == null:
			skipped += 1
			continue
		if ProductionUiBinder.apply_texture(pill, HUD_ROLE_BY_PILL[pill_name], false):
			pill.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			pill.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
			_style_hud_label(pill, LABEL_BY_PILL[pill_name])
			applied += 1
		else:
			skipped += 1
	for node_name in HERO_PORTRAIT_ROLES:
		var button := root.find_child(node_name, true, false) as Button
		if button == null:
			skipped += 1
			continue
		if _apply_hero_portrait_slot(button, HERO_PORTRAIT_ROLES[node_name], str(HERO_IDS.get(node_name, ""))):
			applied += 1
		else:
			skipped += 1
	return {"applied": applied, "skipped": skipped, "milestone": "V2.06.1"}

static func _style_hud_label(pill: TextureRect, label_name: String) -> void:
	var label := pill.find_child(label_name, false, false) as Label
	if label == null:
		return
	label.anchor_left = 0.38
	label.anchor_right = 0.90
	label.offset_left = 0.0
	label.offset_right = 0.0
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

static func _apply_hero_portrait_slot(button: Button, role_id: String, hero_id: String) -> bool:
	var tex := ProductionAssetRegistry.bound_texture(role_id, true)
	if tex == null:
		return false
	var portrait := button.get_node_or_null("HeroPortraitV2061") as TextureRect
	if portrait == null:
		portrait = TextureRect.new()
		portrait.name = "HeroPortraitV2061"
		portrait.mouse_filter = Control.MOUSE_FILTER_IGNORE
		portrait.set_anchors_preset(Control.PRESET_TOP_WIDE)
		portrait.anchor_bottom = 0.52
		portrait.offset_left = 10.0
		portrait.offset_right = -10.0
		portrait.offset_top = 10.0
		portrait.offset_bottom = 0.0
		portrait.z_index = 1
		button.add_child(portrait)
		button.move_child(portrait, 0)
	portrait.texture = tex
	portrait.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	portrait.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
	if not hero_id.is_empty():
		var mastery_tex := ProductionAssetRegistry.bound_texture("hero.%s.mastery" % hero_id, false)
		var mastery := button.get_node_or_null("HeroMasteryBadgeV2061") as TextureRect
		if mastery_tex != null:
			if mastery == null:
				mastery = TextureRect.new()
				mastery.name = "HeroMasteryBadgeV2061"
				mastery.mouse_filter = Control.MOUSE_FILTER_IGNORE
				mastery.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
				mastery.offset_left = -58.0
				mastery.offset_top = -58.0
				mastery.offset_right = -6.0
				mastery.offset_bottom = -6.0
				mastery.z_index = 2
				button.add_child(mastery)
			mastery.texture = mastery_tex
			mastery.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			mastery.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			mastery.visible = true
		elif mastery != null:
			mastery.visible = false
	button.icon = null
	button.expand_icon = false
	return true

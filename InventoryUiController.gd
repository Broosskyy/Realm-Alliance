extends RefCounted
class_name InventoryUiController

const ProductionUiBinder = preload("res://ProductionUiBinder.gd")
const ItemUiPresentation = preload("res://ItemUiPresentation.gd")

var _root: Control
var _view: Control
var _title: Label
var _count_label: Label
var _filter_all: Button
var _filter_weapon: Button
var _filter_accessory: Button
var _sort_button: Button
var _list: VBoxContainer
var _detail_panel: PanelContainer
var _detail_icon: TextureRect
var _detail_name: Label
var _detail_meta: Label
var _detail_stats: Label
var _detail_equipped: Label
var _equip_button: Button
var _unequip_button: Button
var _close_button: Button
var _empty_label: Label

var _slot_filter: String = "all"
var _sort_mode: String = "acquired"
var _selected_instance_id: String = ""
var _open_slot_hint: String = ""

func attach(root: Control, gameplay_parent: Control) -> void:
	_root = root
	if gameplay_parent.find_child("View_Inventory", true, false) != null:
		_view = gameplay_parent.find_child("View_Inventory", true, false) as Control
		_bind_existing_nodes()
		return
	_view = Control.new()
	_view.name = "View_Inventory"
	_view.visible = false
	_view.set_anchors_preset(Control.PRESET_FULL_RECT)
	gameplay_parent.add_child(_view)
	_build_layout()
	if not ItemInventoryService.inventory_changed.is_connected(_on_inventory_changed):
		ItemInventoryService.inventory_changed.connect(_on_inventory_changed)

func _bind_existing_nodes() -> void:
	_title = _view.find_child("InventoryTitle", true, false) as Label
	_count_label = _view.find_child("InventoryCountLabel", true, false) as Label
	_filter_all = _view.find_child("InventoryFilterAll", true, false) as Button
	_filter_weapon = _view.find_child("InventoryFilterWeapon", true, false) as Button
	_filter_accessory = _view.find_child("InventoryFilterAccessory", true, false) as Button
	_sort_button = _view.find_child("InventorySortButton", true, false) as Button
	_list = _view.find_child("InventoryList", true, false) as VBoxContainer
	_detail_panel = _view.find_child("InventoryDetailPanel", true, false) as PanelContainer
	_close_button = _view.find_child("InventoryCloseButton", true, false) as Button
	_equip_button = _view.find_child("InventoryEquipButton", true, false) as Button
	_unequip_button = _view.find_child("InventoryUnequipButton", true, false) as Button
	_empty_label = _view.find_child("InventoryEmptyLabel", true, false) as Label
	_detail_icon = _view.find_child("InventoryDetailIcon", true, false) as TextureRect
	_detail_name = _view.find_child("InventoryDetailName", true, false) as Label
	_detail_meta = _view.find_child("InventoryDetailMeta", true, false) as Label
	_detail_stats = _view.find_child("InventoryDetailStats", true, false) as Label
	_detail_equipped = _view.find_child("InventoryDetailEquipped", true, false) as Label

func _build_layout() -> void:
	var shell := VBoxContainer.new()
	shell.set_anchors_preset(Control.PRESET_FULL_RECT)
	shell.offset_left = 18
	shell.offset_right = -18
	shell.offset_top = 12
	shell.offset_bottom = -12
	shell.add_theme_constant_override("separation", 10)
	_view.add_child(shell)

	_title = Label.new()
	_title.name = "InventoryTitle"
	_title.text = "INVENTAR"
	_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ProductionUiBinder.apply_backdrop(_title, "ui.panel.banner", false, 0.13)
	shell.add_child(_title)

	_count_label = Label.new()
	_count_label.name = "InventoryCountLabel"
	_count_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ProductionUiBinder.apply_backdrop(_count_label, "ui.panel.info.dark", false, 0.12)
	shell.add_child(_count_label)

	var filter_row := HBoxContainer.new()
	filter_row.add_theme_constant_override("separation", 8)
	_filter_all = _make_filter_button("InventoryFilterAll", "ALLE")
	_filter_weapon = _make_filter_button("InventoryFilterWeapon", "WAFFEN")
	_filter_accessory = _make_filter_button("InventoryFilterAccessory", "ACCESSOIRES")
	filter_row.add_child(_filter_all)
	filter_row.add_child(_filter_weapon)
	filter_row.add_child(_filter_accessory)
	shell.add_child(filter_row)

	_sort_button = Button.new()
	_sort_button.name = "InventorySortButton"
	_sort_button.text = "SORTIERUNG · ERHALTEN"
	ProductionUiBinder.apply_backdrop(_sort_button, "ui.button.secondary", false, 0.18, true)
	_sort_button.pressed.connect(_cycle_sort_mode)
	shell.add_child(_sort_button)

	var body := HBoxContainer.new()
	body.size_flags_vertical = Control.SIZE_EXPAND_FILL
	body.add_theme_constant_override("separation", 12)
	shell.add_child(body)

	var scroll := ScrollContainer.new()
	scroll.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	scroll.size_flags_vertical = Control.SIZE_EXPAND_FILL
	scroll.custom_minimum_size = Vector2(0, 420)
	body.add_child(scroll)

	_list = VBoxContainer.new()
	_list.name = "InventoryList"
	_list.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	_list.add_theme_constant_override("separation", 8)
	scroll.add_child(_list)

	_empty_label = Label.new()
	_empty_label.name = "InventoryEmptyLabel"
	_empty_label.text = "Noch keine Ausrüstung.\nBesiege Bosse oder öffne Truhen."
	_empty_label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	_empty_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_empty_label.visible = false
	_list.add_child(_empty_label)

	_detail_panel = PanelContainer.new()
	_detail_panel.name = "InventoryDetailPanel"
	_detail_panel.custom_minimum_size = Vector2(360, 0)
	_detail_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	ProductionUiBinder.apply_backdrop(_detail_panel, "ui.panel.tall.dark", false, 0.14)
	body.add_child(_detail_panel)

	var detail_vbox := VBoxContainer.new()
	detail_vbox.add_theme_constant_override("separation", 8)
	_detail_panel.add_child(detail_vbox)

	_detail_icon = TextureRect.new()
	_detail_icon.name = "InventoryDetailIcon"
	_detail_icon.custom_minimum_size = Vector2(120, 120)
	_detail_icon.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	detail_vbox.add_child(_detail_icon)

	_detail_name = Label.new()
	_detail_name.name = "InventoryDetailName"
	_detail_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_vbox.add_child(_detail_name)

	_detail_meta = Label.new()
	_detail_meta.name = "InventoryDetailMeta"
	_detail_meta.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	_detail_meta.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_vbox.add_child(_detail_meta)

	_detail_stats = Label.new()
	_detail_stats.name = "InventoryDetailStats"
	_detail_stats.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_vbox.add_child(_detail_stats)

	_detail_equipped = Label.new()
	_detail_equipped.name = "InventoryDetailEquipped"
	_detail_equipped.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	detail_vbox.add_child(_detail_equipped)

	_equip_button = Button.new()
	_equip_button.name = "InventoryEquipButton"
	_equip_button.text = "AUSRÜSTEN"
	ProductionUiBinder.apply_backdrop(_equip_button, "ui.button.primary", false, 0.18, true)
	_equip_button.pressed.connect(_on_equip_pressed)
	detail_vbox.add_child(_equip_button)

	_unequip_button = Button.new()
	_unequip_button.name = "InventoryUnequipButton"
	_unequip_button.text = "ABLEGEN"
	ProductionUiBinder.apply_backdrop(_unequip_button, "ui.button.secondary", false, 0.18, true)
	_unequip_button.pressed.connect(_on_unequip_pressed)
	detail_vbox.add_child(_unequip_button)

	_close_button = Button.new()
	_close_button.name = "InventoryCloseButton"
	_close_button.text = "ZURÜCK"
	ProductionUiBinder.apply_backdrop(_close_button, "ui.button.secondary", false, 0.18, true)
	shell.add_child(_close_button)

	_filter_all.pressed.connect(func(): _set_slot_filter("all"))
	_filter_weapon.pressed.connect(func(): _set_slot_filter("weapon"))
	_filter_accessory.pressed.connect(func(): _set_slot_filter("accessory"))

func _make_filter_button(node_name: String, text: String) -> Button:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ProductionUiBinder.apply_backdrop(button, "ui.button.secondary", false, 0.18, true)
	return button

func open(slot_hint: String = "") -> void:
	_open_slot_hint = slot_hint
	if slot_hint in ["weapon", "accessory"]:
		_slot_filter = slot_hint
	else:
		_slot_filter = "all"
	_view.visible = true
	refresh()

func close() -> void:
	_view.visible = false
	_selected_instance_id = ""
	_open_slot_hint = ""

func is_open() -> bool:
	return _view != null and _view.visible

func get_view() -> Control:
	return _view

func _on_inventory_changed() -> void:
	if is_open():
		refresh()

func _set_slot_filter(filter: String) -> void:
	_slot_filter = filter
	refresh()

func _cycle_sort_mode() -> void:
	match _sort_mode:
		"acquired":
			_sort_mode = "rarity"
		"rarity":
			_sort_mode = "equipped"
		_:
			_sort_mode = "acquired"
	_update_sort_button()
	refresh()

func _update_sort_button() -> void:
	var label := "ERHALTEN"
	if _sort_mode == "rarity":
		label = "SELTENHEIT"
	elif _sort_mode == "equipped":
		label = "AUSGERÜSTET"
	_sort_button.text = "SORTIERUNG · %s" % label

func refresh() -> void:
	if _view == null:
		return
	_update_sort_button()
	_update_filter_styles()
	var instances := _filtered_instances()
	_count_label.text = "%d Gegenstände im Besitz" % ItemInventoryService.snapshot_instance_count()
	_rebuild_list(instances)
	_refresh_detail()
	_empty_label.visible = instances.is_empty()

func _filtered_instances() -> Array:
	var out: Array = []
	for inst in ItemInventoryService.get_owned_instances():
		if typeof(inst) != TYPE_DICTIONARY:
			continue
		var slot := str(inst.get("slot", ""))
		if _slot_filter != "all" and slot != _slot_filter:
			continue
		out.append(inst)
	out.sort_custom(func(a, b): return _compare_instances(a, b))
	return out

func _compare_instances(a: Dictionary, b: Dictionary) -> bool:
	if _sort_mode == "equipped":
		var ae := 1 if bool(a.get("equipped", false)) else 0
		var be := 1 if bool(b.get("equipped", false)) else 0
		if ae != be:
			return ae > be
	elif _sort_mode == "rarity":
		var ar := _rarity_rank(str(a.get("rarity", "common")))
		var br := _rarity_rank(str(b.get("rarity", "common")))
		if ar != br:
			return ar > br
	return int(a.get("acquired_at", 0)) > int(b.get("acquired_at", 0))

func _rarity_rank(rarity: String) -> int:
	match rarity:
		"epic": return 4
		"rare": return 3
		"uncommon": return 2
		_: return 1

func _rebuild_list(instances: Array) -> void:
	for child in _list.get_children():
		if child == _empty_label:
			continue
		child.queue_free()
	for inst in instances:
		_list.add_child(_make_card(inst))

func _make_card(inst: Dictionary) -> Button:
	var summary := ItemUiPresentation.instance_card_summary(inst)
	var card := Button.new()
	card.custom_minimum_size = Vector2(0, 96)
	card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	ItemUiPresentation.apply_rarity_backdrop(card, str(summary.get("rarity", "common")), true)
	var row := HBoxContainer.new()
	row.set_anchors_preset(Control.PRESET_FULL_RECT)
	row.offset_left = 10
	row.offset_right = -10
	row.offset_top = 8
	row.offset_bottom = -8
	row.add_theme_constant_override("separation", 10)
	row.mouse_filter = Control.MOUSE_FILTER_IGNORE
	card.add_child(row)

	var icon := TextureRect.new()
	icon.custom_minimum_size = Vector2(72, 72)
	icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	ItemUiPresentation.apply_icon(icon, str(summary.get("icon_asset", "")))
	row.add_child(icon)

	var text_col := VBoxContainer.new()
	text_col.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	text_col.add_theme_constant_override("separation", 2)
	row.add_child(text_col)

	var name_label := Label.new()
	name_label.text = str(summary.get("name", ""))
	name_label.add_theme_font_size_override("font_size", 24)
	text_col.add_child(name_label)

	var meta := Label.new()
	var equipped_tag := " · AUSGERÜSTET" if bool(summary.get("equipped", false)) else ""
	meta.text = "%s · %s%s" % [
		ItemUiPresentation.rarity_label(str(summary.get("rarity", ""))),
		ItemUiPresentation.slot_label(str(summary.get("slot", ""))),
		equipped_tag
	]
	meta.add_theme_font_size_override("font_size", 18)
	text_col.add_child(meta)

	var instance_id := str(summary.get("instance_id", ""))
	card.pressed.connect(func(): _select_instance(instance_id))
	if instance_id == _selected_instance_id:
		card.modulate = Color(1.0, 0.95, 0.72, 1.0)
	return card

func select_instance(instance_id: String) -> void:
	_selected_instance_id = instance_id
	refresh()

func _select_instance(instance_id: String) -> void:
	select_instance(instance_id)

func _refresh_detail() -> void:
	var has_selection := not _selected_instance_id.is_empty() and ItemInventoryService.instances.has(_selected_instance_id)
	_detail_panel.visible = has_selection
	if not has_selection:
		return
	var inst := ItemInventoryService.get_instance(_selected_instance_id)
	var summary := ItemUiPresentation.instance_card_summary(inst)
	var def := ItemInventoryService.get_item_definition(str(summary.get("item_id", "")))
	ItemUiPresentation.apply_rarity_backdrop(_detail_icon.get_parent() if _detail_icon.get_parent() is Control else _detail_icon, str(summary.get("rarity", "common")), false)
	ItemUiPresentation.apply_icon(_detail_icon, str(summary.get("icon_asset", "")))
	_detail_name.text = str(summary.get("name", ""))
	_detail_meta.text = "%s · %s" % [
		ItemUiPresentation.rarity_label(str(summary.get("rarity", ""))),
		ItemUiPresentation.slot_label(str(summary.get("slot", "")))
	]
	_detail_stats.text = "\n".join(ItemUiPresentation.modifier_lines(def))
	var equipped_to := str(summary.get("equipped_to", ""))
	if equipped_to.is_empty():
		_detail_equipped.text = "Nicht ausgerüstet"
	else:
		var hero := HeroSystem.get_card_data(equipped_to)
		_detail_equipped.text = "Ausgerüstet bei %s" % str(hero.get("name", equipped_to))
	_equip_button.visible = not bool(summary.get("equipped", false))
	_unequip_button.visible = bool(summary.get("equipped", false))
	var hero_id := HeroSystem.get_deployed_hero_id()
	if hero_id.is_empty():
		hero_id = HeroSystem.get_selected_hero_id()
	_equip_button.disabled = hero_id.is_empty()
	_equip_button.text = "AUSRÜSTEN · %s" % str(HeroSystem.get_card_data(hero_id).get("name", hero_id))

func _on_equip_pressed() -> void:
	if _selected_instance_id.is_empty():
		return
	var slot_hint := _open_slot_hint if _open_slot_hint in ["weapon", "accessory"] else ""
	var result := ItemInventoryService.equip_for_deployed_hero(_selected_instance_id, slot_hint)
	if bool(result.get("ok", false)):
		HapticsService.success()
		HeroSystem.heroes_changed.emit()
		refresh()
	elif str(result.get("error_code", "")) == "WRONG_SLOT":
		if _root != null and _root.has_method("_show_inventory_feedback"):
			_root.call("_show_inventory_feedback", "Falscher Slot für dieses Item")

func _on_unequip_pressed() -> void:
	if _selected_instance_id.is_empty():
		return
	var result := ItemInventoryService.unequip(_selected_instance_id)
	if bool(result.get("ok", false)):
		HapticsService.light()
		HeroSystem.heroes_changed.emit()
		refresh()

func _update_filter_styles() -> void:
	_style_filter_button(_filter_all, _slot_filter == "all")
	_style_filter_button(_filter_weapon, _slot_filter == "weapon")
	_style_filter_button(_filter_accessory, _slot_filter == "accessory")

func _style_filter_button(button: Button, active: bool) -> void:
	if button == null:
		return
	var role := "ui.button.primary" if active else "ui.button.secondary"
	ProductionUiBinder.apply_backdrop(button, role, false, 0.18, true)

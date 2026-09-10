extends RefCounted
class_name HomeNavigationRewardPolishV195

const VERSION := "v1.95-home-navigation-reward-polish-01"

static func apply(root: Control) -> void:
	if root == null:
		return
	var vp := root.get_viewport_rect().size
	var compact := vp.x < 520.0 or vp.y < 820.0
	_polish_home(root, compact)
	_polish_nav(root, compact)
	_polish_rewards(root, compact)

static func _polish_home(root: Control, compact: bool) -> void:
	var monster := root.find_child("MonsterButton", true, false) as Control
	if monster:
		monster.pivot_offset = monster.size * 0.5
		monster.scale = Vector2(0.94, 0.94) if compact else Vector2.ONE
	var hp := root.find_child("MonsterHP", true, false) as Control
	if hp:
		hp.custom_minimum_size.y = 34.0 if compact else 42.0
	var upgrade := root.find_child("TapUpgradeButton", true, false) as Button
	if upgrade:
		upgrade.custom_minimum_size.y = 86.0 if compact else 100.0
		upgrade.add_theme_font_size_override("font_size", 18 if compact else 20)
	var prompt := root.find_child("TapPrompt", true, false) as Control
	if prompt:
		prompt.modulate = Color(1.0,1.0,1.0,0.92)

static func _polish_nav(root: Control, compact: bool) -> void:
	var menu := root.find_child("BottomMenu", true, false) as HBoxContainer
	if menu:
		menu.add_theme_constant_override("separation", 6 if compact else 10)
	for name in ["Btn_Tap","Btn_Rad","Btn_Dorf","MoreFeaturesButtonP0"]:
		var b := root.find_child(name, true, false) as Button
		if b:
			b.custom_minimum_size.y = 82.0 if compact else 96.0
			b.pivot_offset = b.size * 0.5

static func _polish_rewards(root: Control, compact: bool) -> void:
	var reward := root.find_child("RewardBurst", true, false) as TextureRect
	if reward:
		reward.mouse_filter = Control.MOUSE_FILTER_IGNORE
		reward.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		reward.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var level := root.find_child("LevelUpOverlayP0", true, false) as TextureRect
	if level:
		level.mouse_filter = Control.MOUSE_FILTER_IGNORE
	var damage := root.find_child("DamageLabel", true, false) as Label
	if damage:
		damage.add_theme_font_size_override("font_size", 32 if compact else 38)

static func transition_out(root: Control, target_view: Control, reduced_motion: bool) -> void:
	if root == null or target_view == null or reduced_motion:
		return
	var current := _visible_primary_view(root)
	if current == null or current == target_view:
		return
	current.pivot_offset = current.size * 0.5
	var tween := current.create_tween().set_parallel(true)
	tween.tween_property(current, "modulate:a", 0.82, 0.075)
	tween.tween_property(current, "scale", Vector2(0.992,0.992), 0.075)

static func transition_in(root: Control, target_view: Control, reduced_motion: bool) -> void:
	if root == null or target_view == null:
		return
	target_view.modulate = Color.WHITE
	target_view.scale = Vector2.ONE
	if reduced_motion:
		return
	target_view.pivot_offset = target_view.size * 0.5
	target_view.modulate.a = 0.88
	target_view.scale = Vector2(1.008,1.008)
	var tween := target_view.create_tween().set_parallel(true)
	tween.tween_property(target_view, "modulate:a", 1.0, 0.13)
	tween.tween_property(target_view, "scale", Vector2.ONE, 0.16)
	_pulse_active_nav(root, target_view)

static func reward_punch(root: Control, reduced_motion: bool) -> void:
	if root == null or reduced_motion:
		return
	var reward := root.find_child("RewardBurst", true, false) as TextureRect
	if reward:
		reward.pivot_offset = reward.size * 0.5
		var tween := reward.create_tween()
		tween.tween_property(reward, "rotation", 0.025, 0.08)
		tween.tween_property(reward, "rotation", -0.018, 0.08)
		tween.tween_property(reward, "rotation", 0.0, 0.10)

static func _pulse_active_nav(root: Control, target_view: Control) -> void:
	var pairs := [
		["View_Tap", "Btn_Tap"],
		["View_CoinMaster", "Btn_Rad"],
		["View_Dorf", "Btn_Dorf"]
	]
	for pair in pairs:
		var view := root.find_child(pair[0], true, false) as Control
		if view == target_view:
			var b := root.find_child(pair[1], true, false) as Button
			if b:
				b.pivot_offset = b.size * 0.5
				var tween := b.create_tween()
				tween.tween_property(b, "scale", Vector2(1.035,1.035), 0.07)
				tween.tween_property(b, "scale", Vector2.ONE, 0.11)
			return

static func _visible_primary_view(root: Control) -> Control:
	for name in ["View_Tap","View_CoinMaster","View_Dorf","View_Journey","View_Meta","View_Puzzle","View_TowerDefense","View_Heroes","View_Attack","View_Defense","View_Daily","View_Quests"]:
		var view := root.find_child(name, true, false) as Control
		if view and view.visible:
			return view
	return null

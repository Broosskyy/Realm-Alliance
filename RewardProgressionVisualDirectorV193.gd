extends RefCounted

# Presentation-only reward/progression polish. It never grants currency, XP, unlocks or items.
static func reward(root: Control, anchor: Control, kind: String, reduced_motion: bool) -> void:
	var effect := "reward_gold"
	if kind == "blue": effect = "reward_blue"
	elif kind == "special": effect = "reward_rainbow"
	GameplayVfxService.play_overlay(root,anchor,effect,reduced_motion,1.0 if kind != "special" else 1.15,0.34 if kind != "special" else 0.46)

static func level_up(root: Control, anchor: Control, reduced_motion: bool, major_unlock: bool) -> void:
	GameplayVfxService.play_overlay(root,anchor,"level_up_major" if major_unlock else "level_up",reduced_motion,1.14 if major_unlock else 1.0,0.52 if major_unlock else 0.42)
	if major_unlock:
		GameplayVfxService.play_overlay(root,anchor,"unlock_vortex",reduced_motion,0.88,0.46)

static func chest_sequence(root: Control, chest: TextureRect, reduced_motion: bool) -> void:
	if root == null or chest == null:
		return
	var closed := ProductionAssetRegistry.bound_texture("reward.chest.closed",false)
	var opening := ProductionAssetRegistry.bound_texture("reward.chest.opening",false)
	var glow := ProductionAssetRegistry.bound_texture("reward.chest.open_glow",false)
	var opened := ProductionAssetRegistry.bound_texture("reward.chest.open",false)
	if closed != null: chest.texture = closed
	chest.visible = true
	if reduced_motion:
		if opened != null: chest.texture = opened
		return
	chest.pivot_offset = chest.size * 0.5
	chest.scale = Vector2(0.94,0.94)
	var tw := root.create_tween()
	tw.tween_property(chest,"scale",Vector2(1.05,1.05),0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_callback(func():
		if is_instance_valid(chest) and opening != null: chest.texture = opening
	)
	tw.tween_interval(0.09)
	tw.tween_callback(func():
		if is_instance_valid(chest) and glow != null: chest.texture = glow
	)
	tw.tween_interval(0.13)
	tw.tween_callback(func():
		if is_instance_valid(chest) and opened != null: chest.texture = opened
	)
	tw.tween_property(chest,"scale",Vector2.ONE,0.10)

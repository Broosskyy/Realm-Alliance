extends RefCounted

# Presentation-only TAP feedback. Strength is derived from already-authoritative damage; no damage is modified here.
static func hit(root: Control, monster: Control, damage: int, base_damage: int, reduced_motion: bool) -> void:
	if root == null or monster == null:
		return
	var strong := damage >= maxi(base_damage * 2, base_damage + 8)
	GameplayVfxService.play_overlay(root, monster, "tap_hit_strong" if strong else "tap_hit", reduced_motion, 1.04 if strong else 0.82, 0.28 if strong else 0.22)
	if reduced_motion:
		return
	monster.pivot_offset = monster.size * 0.5
	var base_scale := monster.scale
	var tw := root.create_tween()
	tw.tween_property(monster,"scale",base_scale * (Vector2(0.92,1.07) if strong else Vector2(0.96,1.04)),0.055)
	tw.tween_property(monster,"scale",base_scale * (1.08 if strong else 1.035),0.07).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	tw.tween_property(monster,"scale",base_scale,0.09)

static func defeat(root: Control, monster: Control, boss: bool, reduced_motion: bool) -> void:
	if root == null or monster == null:
		return
	GameplayVfxService.play_overlay(root,monster,"monster_defeat",reduced_motion,1.18 if boss else 0.98,0.42 if boss else 0.32)
	if reduced_motion:
		return
	monster.pivot_offset = monster.size * 0.5
	var tw := root.create_tween().set_parallel(true)
	tw.tween_property(monster,"modulate:a",0.72,0.16)
	tw.tween_property(monster,"scale",monster.scale * Vector2(1.10,0.86),0.16).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)

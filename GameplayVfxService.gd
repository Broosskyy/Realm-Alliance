extends RefCounted

# Presentation-only VFX helper. It never decides damage, rewards, odds, timing authority or economy state.
const ROLE := {
	"tap_hit": "fx.tap.hit",
	"tap_hit_strong": "fx.tap.hit.strong",
	"monster_defeat": "fx.monster.defeat",
	"level_up": "fx.level_up",
	"unlock": "ui.unlock.banner",
	"level_up_major": "fx.level_up.major",
	"unlock_vortex": "fx.unlock.vortex",
	"reward_gold": "fx.reward.gold",
	"reward_blue": "fx.reward.blue",
	"reward_rainbow": "fx.reward.rainbow",
	"chest_open": "fx.chest.open",
	"spin_motion": "fx.spin.motion",
	"spin_stop": "fx.spin.stop",
	"spin_win": "fx.spin.win",
	"spin_jackpot": "fx.spin.jackpot",
	"td_archer_projectile": "fx.td.projectile.archer",
	"td_mage_projectile": "fx.td.projectile.mage",
	"td_cannon_projectile": "fx.td.projectile.cannon",
	"td_nature_projectile": "fx.td.projectile.nature",
	"td_archer_impact": "fx.td.impact.archer",
	"td_mage_impact": "fx.td.impact.mage",
	"td_cannon_impact": "fx.td.impact.cannon",
	"td_nature_impact": "fx.td.impact.nature"
}

static func texture(effect_id: String) -> Texture2D:
	var role := str(ROLE.get(effect_id, ""))
	if role.is_empty():
		return null
	return ProductionAssetRegistry.bound_texture(role, false)

static func play_overlay(root: Control, anchor: Control, effect_id: String, reduced_motion := false, scale_mul := 1.0, duration := 0.32) -> TextureRect:
	var tex := texture(effect_id)
	if root == null or anchor == null or tex == null:
		return null
	var fx := TextureRect.new()
	fx.name = "Vfx_%s" % effect_id.replace(".", "_")
	fx.texture = tex
	fx.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fx.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx.z_index = 80
	var side := maxf(96.0, minf(maxf(anchor.size.x, anchor.size.y) * 1.35 * scale_mul, 420.0))
	fx.size = Vector2(side, side)
	var anchor_center := anchor.get_global_rect().get_center()
	var local_center := root.get_global_transform_with_canvas().affine_inverse() * anchor_center
	fx.position = local_center - fx.size * 0.5
	fx.pivot_offset = fx.size * 0.5
	root.add_child(fx)
	if reduced_motion:
		fx.modulate = Color(1,1,1,0.9)
		var hold := root.get_tree().create_timer(minf(duration,0.14))
		hold.timeout.connect(func():
			if is_instance_valid(fx): fx.queue_free()
		)
		return fx
	fx.modulate = Color(1,1,1,0)
	fx.scale = Vector2(0.72,0.72)
	var tween := root.create_tween().set_parallel(true)
	tween.tween_property(fx,"modulate:a",1.0,minf(0.09,duration*0.28))
	tween.tween_property(fx,"scale",Vector2(1.08,1.08),duration*0.55).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	tween.chain().tween_property(fx,"modulate:a",0.0,duration*0.45)
	tween.finished.connect(func():
		if is_instance_valid(fx): fx.queue_free()
	)
	return fx

static func play_projectile(root: Control, from_anchor: Control, to_anchor: Control, projectile_id: String, impact_id: String, reduced_motion := false, duration := 0.24) -> void:
	if root == null or from_anchor == null or to_anchor == null:
		return
	if reduced_motion:
		play_overlay(root,to_anchor,impact_id,true,0.55,0.12)
		return
	var tex := texture(projectile_id)
	if tex == null:
		play_overlay(root,to_anchor,impact_id,false,0.65,0.22)
		return
	var fx := TextureRect.new()
	fx.texture = tex
	fx.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	fx.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	fx.mouse_filter = Control.MOUSE_FILTER_IGNORE
	fx.z_index = 82
	fx.size = Vector2(76,76)
	fx.pivot_offset = fx.size * 0.5
	var inv := root.get_global_transform_with_canvas().affine_inverse()
	var start := inv * from_anchor.get_global_rect().get_center() - fx.size * 0.5
	var finish := inv * to_anchor.get_global_rect().get_center() - fx.size * 0.5
	fx.position = start
	root.add_child(fx)
	var tween := root.create_tween().set_parallel(true)
	tween.tween_property(fx,"position",finish,duration).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	tween.tween_property(fx,"scale",Vector2(1.12,1.12),duration)
	tween.finished.connect(func():
		if is_instance_valid(fx): fx.queue_free()
		play_overlay(root,to_anchor,impact_id,false,0.7,0.24)
	)

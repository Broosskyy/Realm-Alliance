extends RefCounted
class_name CoreLoopProductionReadinessV198

const VERSION := "v1.98-core-loop-production-readiness-01"

static func apply(root: Control) -> void:
	if root == null:
		return
	_refresh_core_guidance(root)
	_refresh_mode_readiness(root)
	_refresh_resume_cue(root)
	_polish_compact_session(root)

static func refresh(root: Control) -> void:
	apply(root)

static func _refresh_core_guidance(root: Control) -> void:
	var hint := root.find_child("FirstSessionHintP0", true, false) as Label
	if hint == null:
		return
	var encounter := PlayerData.monster_level
	if encounter > 10:
		return
	if encounter == 1 and PlayerData.current_monster_hp == PlayerData.monster_max_hp:
		hint.text = "TIPPE AUF DAS MONSTER · GOLD TREIBT DEIN REALM AN"
		hint.visible = true
	elif encounter <= 3:
		hint.text = "KÄMPFEN → GOLD → TAP ODER DORF VERBESSERN"
		hint.visible = true
	elif encounter <= 6 and PlayerData.spins > 0:
		hint.text = "SPIN NUTZT DEINE SPINS · DORF STÄRKT DEN FORTSCHRITT"
		hint.visible = true

static func _refresh_mode_readiness(root: Control) -> void:
	var status := root.find_child("FeatureHubStatusV154", true, false) as Label
	if status == null:
		return
	var pending := RuntimeFlowService.pending_kind()
	if not pending.is_empty():
		status.text = "FORTSETZEN · %s · ERGEBNIS ZUERST ABSCHLIESSEN" % RuntimeFlowService.display_name(pending)
		return
	var attention := RuntimeFlowService.attention_count()
	if attention > 0:
		status.text = "%d BEREIT · BELOHNUNGEN ABHOLEN ODER SPIELSÄULE WÄHLEN" % attention
	else:
		status.text = "REALM BEREIT · TAP, SPIN, DORF UND MODI GREIFEN INEINANDER"

static func _refresh_resume_cue(root: Control) -> void:
	var more := root.find_child("MoreFeaturesButtonP0", true, false) as Button
	if more == null:
		return
	var pending := RuntimeFlowService.pending_kind()
	if not pending.is_empty():
		more.text = "MODI · FORTSETZEN"
	else:
		more.text = "MODI"

static func _polish_compact_session(root: Control) -> void:
	var vp := root.get_viewport_rect().size
	var compact := vp.x < 520.0 or vp.y < 820.0
	for name in ["TapUpgradeButton","SpinButton","GoldmineClaimButtonP0","VillageForgeActionV153","VillageTempleActionV153","VillageProsperityClaimV153","DiceRollButton","PuzzleMasteryClaimP0","TDBuildButton","TDFightButton","LaneLeftButton","LaneRightButton"]:
		var button := root.find_child(name, true, false) as Button
		if button:
			button.custom_minimum_size.y = max(button.custom_minimum_size.y, 72.0 if compact else 78.0)
			button.pivot_offset = button.size * 0.5

static func action_feedback(anchor: Control, reduced_motion: bool) -> void:
	if anchor == null or reduced_motion:
		return
	anchor.pivot_offset = anchor.size * 0.5
	anchor.scale = Vector2.ONE
	var t := anchor.create_tween()
	t.tween_property(anchor, "scale", Vector2(1.025,1.025), 0.07)
	t.tween_property(anchor, "scale", Vector2.ONE, 0.09)

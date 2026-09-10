extends RefCounted
class_name RuntimeGuidanceService

## V2.01 — player-facing copy/state cues (no geometry).

static func refresh(root: Control) -> void:
	if root == null:
		return
	_refresh_core_guidance(root)
	_refresh_mode_readiness(root)
	_refresh_resume_cue(root)
	_refresh_first_session_copy(root)

static func _refresh_core_guidance(root: Control) -> void:
	var hint := root.find_child("FirstSessionHintP0", true, false) as Label
	if hint == null:
		return
	var encounter := PlayerData.monster_level
	if encounter > 10:
		hint.visible = false
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
	else:
		hint.visible = false

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

static func _refresh_first_session_copy(root: Control) -> void:
	var hint := root.find_child("FirstSessionHintP0", true, false) as Label
	if hint == null or not hint.visible:
		return
	hint.text = hint.text.replace("RAD", "SPIN")

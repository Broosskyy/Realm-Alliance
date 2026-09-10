extends RefCounted
class_name PreAlphaClosureV199

const VERSION := "v1.99-pre-alpha-closure-01"

# Presentation-only closure layer. It may inspect authoritative runtime state,
# but never grants rewards, changes progression, writes saves or resolves results.
static func apply(root: Control) -> void:
	if root == null:
		return
	_refresh_pending_recovery(root)
	_refresh_first_session_copy(root)
	_enforce_mobile_targets(root)

static func refresh(root: Control) -> void:
	apply(root)

static func _refresh_pending_recovery(root: Control) -> void:
	var more := root.find_child("MoreFeaturesButtonP0", true, false) as Button
	var status := root.find_child("FeatureHubStatusV154", true, false) as Label
	var pending := RuntimeFlowService.pending_kind()
	var count := RuntimeFlowService.pending_count()
	if more:
		more.text = "MODI · FORTSETZEN" if not pending.is_empty() else "MODI"
	if status and count > 1:
		status.text = "%d ERGEBNISSE OFFEN · %s WIRD ZUERST FORTGESETZT" % [count, RuntimeFlowService.display_name(pending)]

static func _refresh_first_session_copy(root: Control) -> void:
	var hint := root.find_child("FirstSessionHintP0", true, false) as Label
	if hint == null or not hint.visible:
		return
	# Final player-facing terminology: REALM SPIN/SPIN, never legacy wheel copy.
	hint.text = hint.text.replace("RAD", "SPIN")

static func _enforce_mobile_targets(root: Control) -> void:
	var vp := root.get_viewport_rect().size
	var compact := vp.x < 520.0 or vp.y < 820.0
	var min_h := 72.0 if compact else 78.0
	for name in [
		"Btn_Tap", "Btn_Rad", "Btn_Dorf", "MoreFeaturesButtonP0",
		"TapUpgradeButton", "SpinButton", "GoldmineClaimButtonP0",
		"DiceRollButton", "PuzzleMasteryClaimP0", "TDBuildButton", "TDFightButton",
		"LaneLeftButton", "LaneRightButton"
	]:
		var button := root.find_child(name, true, false) as Button
		if button:
			button.custom_minimum_size.y = max(button.custom_minimum_size.y, min_h)

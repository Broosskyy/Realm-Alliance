extends RefCounted
const V192 = preload("res://ProductionAssetConvergenceV192.gd")
const GreenvaleWorldVisualDirectorV193 = preload("res://GreenvaleWorldVisualDirectorV193.gd")

static func apply(root: Node) -> Dictionary:
	var result := V192.apply(root)
	if root is Control:
		result["greenvale_world_v193"] = GreenvaleWorldVisualDirectorV193.apply(root as Control)
	return result

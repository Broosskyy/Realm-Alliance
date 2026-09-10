extends RefCounted
const V191 = preload("res://ProductionAssetConvergenceV191.gd")
const TowerDefenseVisualDirectorV192 = preload("res://TowerDefenseVisualDirectorV192.gd")

static func apply(root: Node) -> Dictionary:
	var result := V191.apply(root)
	if root is Control:
		result["td_visuals"] = TowerDefenseVisualDirectorV192.refresh(root as Control)
	return result

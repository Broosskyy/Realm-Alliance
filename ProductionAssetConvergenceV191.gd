extends RefCounted

const V190 = preload("res://ProductionAssetConvergenceV190.gd")
const GreenvaleWorldDecorationV191 = preload("res://GreenvaleWorldDecorationV191.gd")

# V1.91 preserves V1.90 production bindings, then deepens presentation with safe world composition.
static func apply(root: Node) -> Dictionary:
	var result := V190.apply(root)
	var decor := 0
	if root is Control:
		decor = GreenvaleWorldDecorationV191.apply(root as Control)
	result["greenvale_decor"] = decor
	return result

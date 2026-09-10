extends RefCounted

const ProductionUiBinder = preload("res://ProductionUiBinder.gd")

# V1.90 binds only high-confidence production art. Gameplay authority remains untouched.
static func apply(root: Node) -> Dictionary:
	var applied := 0
	applied += _texture(root, "MonsterHitOverlay", "fx.tap.hit")
	applied += _texture(root, "UnlockBanner", "ui.unlock.banner")
	applied += _texture(root, "VillageAmbient", "world.greenvale.ambient")
	applied += _texture(root, "TDEnemyMarker", "td.enemy.default")
	applied += _backdrop(root, "LevelUpOverlayP0", "fx.level_up", 0.10)
	applied += _backdrop(root, "PuzzleResultLabel", "fx.puzzle.match", 0.10)
	return {"applied": applied}

static func _texture(root: Node, node_name: String, role: String) -> int:
	var node := root.find_child(node_name, true, false)
	if node is TextureRect and ProductionUiBinder.apply_texture(node as TextureRect, role, false):
		return 1
	return 0

static func _backdrop(root: Node, node_name: String, role: String, patch := 0.12) -> int:
	var node := root.find_child(node_name, true, false)
	if node is Control and ProductionUiBinder.apply_backdrop(node as Control, role, false, patch, false):
		return 1
	return 0

extends RefCounted

# Presentation-only director for the four production tower families.
const ROLES := ["archer","mage","cannon","nature"]

static func _tower(root: Node, name: String) -> TextureRect:
	return root.find_child(name,true,false) as TextureRect

static func refresh(root: Control) -> Dictionary:
	if root == null: return {"ok":false}
	var a := _tower(root,"TowerA")
	var b := _tower(root,"TowerB")
	var enemy := _tower(root,"TDEnemyMarker")
	var built := TowerDefenseSystem.towers
	var tech := TowerDefenseProgressionSystem.tower_tech_level
	var wave := TowerDefenseSystem.wave
	var primary := ROLES[posmod(tech - 1,ROLES.size())]
	var secondary := ROLES[posmod(tech + wave - 1,ROLES.size())]
	_apply_tower(a,primary,built >= 1,"idle")
	_apply_tower(b,secondary,built >= 2,"idle")
	if enemy != null:
		var enemy_role := ["forest_a","mushroom","crystal","forest_b"][posmod(wave-1,4)]
		var tex := ProductionAssetRegistry.bound_texture("td.enemy.%s.idle" % enemy_role,false)
		if tex != null: enemy.texture = tex
	return {"ok":true,"primary":primary,"secondary":secondary,"built":built}

static func attack(root: Control, slot: int, role: String) -> void:
	var node := _tower(root,"TowerA" if slot == 0 else "TowerB")
	if node == null or not node.visible: return
	var tex := ProductionAssetRegistry.bound_texture("td.tower.%s.attack" % role,false)
	if tex != null: node.texture = tex
	var tree := root.get_tree()
	if tree == null: return
	var timer := tree.create_timer(0.16)
	timer.timeout.connect(func():
		if is_instance_valid(node):
			var ready := ProductionAssetRegistry.bound_texture("td.tower.%s.ready" % role,false)
			if ready != null: node.texture = ready
	)

static func enemy_hit(root: Control) -> void:
	var enemy := _tower(root,"TDEnemyMarker")
	if enemy == null: return
	var tw := root.create_tween()
	tw.tween_property(enemy,"modulate",Color(1.0,0.55,0.55,1.0),0.06)
	tw.tween_property(enemy,"modulate",Color.WHITE,0.10)

static func _apply_tower(node: TextureRect, role: String, shown: bool, state: String) -> void:
	if node == null: return
	node.visible = shown
	if not shown: return
	var tex := ProductionAssetRegistry.bound_texture("td.tower.%s.%s" % [role,state],false)
	if tex != null: node.texture = tex

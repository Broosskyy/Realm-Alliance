extends RefCounted

# Presentation-only Greenvale composition pass. No harvestables, collisions or progression authority.
const ITEMS := [
	["v190.world.greenvale_props_b.lantern_post", Vector2(0.055,0.18), Vector2(82,116), 0.95],
	["v190.world.greenvale_props_b.signpost", Vector2(0.84,0.18), Vector2(94,124), 0.95],
	["v190.world.greenvale_nature_b.tree_stump", Vector2(0.08,0.70), Vector2(98,82), 0.92],
	["v190.world.greenvale_props_b.tool_crates", Vector2(0.81,0.68), Vector2(112,94), 0.94],
	["v190.world.greenvale_nature_a.mushrooms", Vector2(0.57,0.79), Vector2(78,64), 0.92],
	["v190.world.greenvale_props_b.camp_cauldron", Vector2(0.20,0.58), Vector2(104,92), 0.90],
	["v190.world.greenvale_nature_b.bluebell_patch", Vector2(0.70,0.77), Vector2(82,66), 0.88],
	["v190.world.greenvale_props_b.banner_gate", Vector2(0.50,0.12), Vector2(106,126), 0.86]
]

static func apply(root: Control) -> Dictionary:
	if root == null:
		return {"ok":false,"count":0}
	var village := root.find_child("View_ClashDorf", true, false) as Control
	if village == null:
		return {"ok":false,"count":0}
	var old := village.get_node_or_null("ProductionDecorV191")
	if old != null:
		old.queue_free()
	var layer := village.get_node_or_null("ProductionDecorV193") as Control
	if layer == null:
		layer = Control.new()
		layer.name = "ProductionDecorV193"
		layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
		layer.z_index = -1
		village.add_child(layer)
	var existing := {}
	for c in layer.get_children():
		existing[c.name] = c
	var count := 0
	for i in range(ITEMS.size()):
		var item = ITEMS[i]
		var tex := ProductionAssetRegistry.texture_for(str(item[0]))
		if tex == null:
			continue
		var node_name := "Decor_%02d" % i
		var node := existing.get(node_name,null) as TextureRect
		if node == null:
			node = TextureRect.new()
			node.name = node_name
			node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			node.mouse_filter = Control.MOUSE_FILTER_IGNORE
			layer.add_child(node)
		node.texture = tex
		var base_size: Vector2 = item[2]
		var scale_factor := clampf(village.size.x / 1080.0,0.72,1.12)
		node.size = base_size * scale_factor
		node.position = Vector2(
			clampf(village.size.x * item[1].x - node.size.x*0.5, 6.0, maxf(6.0,village.size.x-node.size.x-6.0)),
			clampf(village.size.y * item[1].y - node.size.y*0.5, 6.0, maxf(6.0,village.size.y-node.size.y-6.0))
		)
		node.modulate = Color(1,1,1,float(item[3]))
		count += 1
	return {"ok":true,"count":count}

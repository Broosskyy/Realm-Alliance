extends RefCounted

# V1.91 adds lightweight production props to the village/world view without touching gameplay state.
const DECOR := [
	["v190.world.greenvale_props_b.lantern_post", Vector2(0.07,0.21), Vector2(92,128)],
	["v190.world.greenvale_props_b.signpost", Vector2(0.82,0.21), Vector2(102,134)],
	["v190.world.greenvale_nature_b.tree_stump", Vector2(0.09,0.70), Vector2(110,92)],
	["v190.world.greenvale_props_b.tool_crates", Vector2(0.80,0.69), Vector2(126,104)],
	["v190.world.greenvale_nature_a.mushrooms", Vector2(0.56,0.78), Vector2(88,72)]
]

static func apply(root: Control) -> int:
	if root == null:
		return 0
	var village := root.find_child("View_ClashDorf", true, false) as Control
	if village == null:
		return 0
	var existing := village.get_node_or_null("ProductionDecorV191") as Control
	if existing != null:
		return existing.get_child_count()
	var layer := Control.new()
	layer.name = "ProductionDecorV191"
	layer.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	layer.mouse_filter = Control.MOUSE_FILTER_IGNORE
	layer.z_index = -1
	village.add_child(layer)
	var count := 0
	for item in DECOR:
		var tex := ProductionAssetRegistry.texture_for(str(item[0]))
		if tex == null:
			continue
		var node := TextureRect.new()
		node.texture = tex
		node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		node.mouse_filter = Control.MOUSE_FILTER_IGNORE
		node.size = item[2]
		node.position = Vector2(maxf(0.0,village.size.x * item[1].x - node.size.x*0.5), maxf(0.0,village.size.y * item[1].y - node.size.y*0.5))
		node.modulate = Color(1,1,1,0.92)
		layer.add_child(node)
		count += 1
	return count

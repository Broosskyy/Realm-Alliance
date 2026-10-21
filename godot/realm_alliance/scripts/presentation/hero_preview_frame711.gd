extends RefCounted
# Fit the complete worn silhouette across its six poses, including the separate sword.
# Bounds use source alpha extents, not the large transparent body canvas.
static var alpha_bounds:Dictionary={}
static func bounds(rig) -> Rect2:
    if alpha_bounds.is_empty():alpha_bounds=JSON.parse_string(FileAccess.get_file_as_string("res://assets/work711/wardrobe/texture_bounds.json"))
    var result=Rect2();var first=true
    for node in rig._art.find_children("*","CanvasItem",true,false):
        if not node.is_visible_in_tree():continue
        var points=PackedVector2Array()
        if node is Sprite2D and node.texture:
            var rect=node.get_rect()
            if not node.region_enabled and alpha_bounds.has(node.texture.resource_path):
                var a:Array=alpha_bounds[node.texture.resource_path]
                rect=Rect2(rect.position+Vector2(a[0],a[1]),Vector2(a[2],a[3]))
            points=PackedVector2Array([rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)])
        elif node is Polygon2D and node.texture:points=node.polygon
        elif node.has_method("visual_bounds"):
            var rect:Rect2=node.visual_bounds()
            points=PackedVector2Array([rect.position,rect.end])
        for p in points:
            var at=rig.to_local(node.to_global(p))
            if first:result=Rect2(at,Vector2.ZERO);first=false
            else:result=result.expand(at)
    return result
static func fit(rig,area:Rect2) -> void:
    if area.size.x<10 or area.size.y<10:return
    var original=rig._pose;var combined=Rect2();var first=true
    for pose in rig.Gate.HERO_STATES:
        rig._set_pose(pose)
        var frame=bounds(rig)
        combined=frame if first else combined.merge(frame);first=false
    rig._set_pose(original)
    if combined.size.x<=0 or combined.size.y<=0:return
    var factor=minf(.92,minf(area.size.x/combined.size.x,area.size.y/combined.size.y))
    rig.scale=Vector2.ONE*factor
    rig.position=area.position+Vector2((area.size.x-combined.size.x*factor)*.5,area.size.y-combined.size.y*factor)-combined.position*factor

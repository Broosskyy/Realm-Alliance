extends RefCounted
# Thumbnail crop metadata; combat textures and their calibrated pivots stay intact.
const RECTS={"steel":Rect2(62,81,1027,221),"crystal":Rect2(56,59,1039,266),"ember":Rect2(55,53,1042,278),"rune_gold":Rect2(56,60,1040,263),"shadow_violet":Rect2(51,63,1049,257)}
static func thumbnail(path:String) -> Texture2D:
    var source=load(path) as Texture2D
    var key=path.get_file().get_basename()
    if path.contains("/weapons/") and RECTS.has(key):
        var crop=AtlasTexture.new();crop.atlas=source;crop.region=RECTS[key];return crop
    if path=="res://assets/expansion702/schattenjager/portrait.png":
        var crop=AtlasTexture.new();crop.atlas=source;crop.region=Rect2(48,50,159,155);return crop
    return source
static func paint(canvas:CanvasItem,texture:Texture2D,center:Vector2,limit:Vector2,weapon:bool,tint:Color=Color.WHITE) -> void:
    var turn=-PI/4 if weapon else 0.0
    var bounds=texture.get_size()
    if weapon:bounds=Vector2.ONE*(bounds.x+bounds.y)*.707107
    var factor=minf(limit.x/bounds.x,limit.y/bounds.y)
    var extent=texture.get_size()*factor
    canvas.draw_set_transform(center,turn)
    canvas.draw_texture_rect(texture,Rect2(-extent/2,extent),false,tint)
    canvas.draw_set_transform(Vector2.ZERO)

extends Node2D
class_name RAArmorDetails710
# Pose-fitted, texture-backed shoulder plates/tassets. Never a floating item icon.
var corners=PackedVector2Array()
var armor_id=""
var level=1
var source:Texture2D
func configure(points:PackedVector2Array,id:String,upgrade:int,texture:Texture2D) -> void:
    corners=points;armor_id=id;level=upgrade;source=texture
    visible=source!=null and corners.size()==4;queue_redraw()
func _surface(points:PackedVector2Array,tint:Color) -> void:
    var uv=PackedVector2Array([Vector2(0,0),Vector2(1,0),Vector2(1,1),Vector2(0,1)])
    draw_polygon(points,PackedColorArray([tint]),uv,source)
    var outline=points.duplicate();outline.append(points[0])
    draw_polyline(outline,Color("#c3a36c") if armor_id=="astral_plate" else Color("#b199da"),1.7,true)
func _draw() -> void:
    if not visible or corners.size()!=4:return
    var epic=armor_id=="eclipse_plate"
    var left=corners[0];var right=corners[1]
    var reach=23.0 if epic else 14.0
    _surface(PackedVector2Array([left+Vector2(-reach,-6),left+Vector2(19,0),left+Vector2(10,18),left+Vector2(-reach-5,17)]),Color("#c5a4ed") if epic else Color("#cad7e3"))
    _surface(PackedVector2Array([right+Vector2(-15,0),right+Vector2(reach,-7),right+Vector2(reach+4,15),right+Vector2(-5,19)]),Color("#ad8bd0") if epic else Color("#a3b7c8"))
    if epic:
        var base=corners[3]
        _surface(PackedVector2Array([base+Vector2(-3,-8),base+Vector2(29,-2),base+Vector2(18,31),base+Vector2(-8,17)]),Color("#9788bf"))
    for i in mini(4,int((level-1)/2)):
        var at=left.lerp(right,(i+1.0)/5.0)+Vector2(0,7)
        draw_circle(at,2.0,Color("#ffe0a0"))

extends Node2D
class_name RAWardrobeVisual711
const Wardrobe=preload("res://scripts/systems/wardrobe711.gd")
const Gear=preload("res://scripts/systems/hero_equipment.gd")
const FAMILIES=["wander_leather","silver_guard","forest_path","sand_traveler"]
const PARTS=["torso","shoulder_left","shoulder_right","hips","boot_left","boot_right","cape"]
const ROOT="res://assets/work711/wardrobe/"
const TILT={"idle":-9.0,"ready":6.0,"windup":-14.0,"attack_contact":15.0,"recovery":16.0,"hit":-14.0}
var active_id=""
var armor_plus=0
var pieces:Dictionary={}
var textures:Dictionary={}
var feet:Dictionary={}
var ornaments:Node2D
var cloth:ShaderMaterial
var hero
var fx=1.0
func attach(value) -> void:
    hero=value;name="ModularOutfit711";hero._art.add_child(self)
    feet=JSON.parse_string(FileAccess.get_file_as_string(ROOT+"foot_anchors.json"))
    cloth=ShaderMaterial.new();cloth.shader=preload("res://assets/work711/wardrobe/cloth711.gdshader")
    for part in PARTS:
        var mesh=Polygon2D.new();mesh.name="Outfit_"+part;mesh.z_index=3 if part.begins_with("shoulder") else (-1 if part=="cape" else 1)
        if part=="cape":mesh.material=cloth
        add_child(mesh);pieces[part]=mesh
    ornaments=Node2D.new();ornaments.name="RefinementInlays711";ornaments.z_index=4;add_child(ornaments);ornaments.draw.connect(_draw_refinement)
    visible=false
func configure(profile:Dictionary) -> void:
    active_id=Wardrobe.active(profile)
    var armor=Gear.visible_id(profile,"chest") if profile.has("hero_equipment") else ""
    if active_id=="" and armor in ["wander_leather","silver_guard"]:active_id=armor
    armor_plus=Gear.item_level(profile,armor)-1 if active_id==armor else 0
    fx=hero.fx_intensity
    visible=active_id in FAMILIES
    hero._palette.set_shader_parameter("modular_outfit",visible)
    var colors={"wander_leather":Color("#a78d60"),"silver_guard":Color("#243f65"),"forest_path":Color("#4a6533"),"sand_traveler":Color("#d4b387")}
    hero._palette.set_shader_parameter("modular_cloth_color",colors.get(active_id,Color.WHITE))
    if visible and not textures.has(active_id):
        var set={}
        for part in PARTS:set[part]=load(ROOT+active_id+"/"+part+".png")
        textures[active_id]=set
    for part in PARTS:pieces[part].texture=textures[active_id][part] if visible else null
    cloth.set_shader_parameter("motion_strength",2.2*clampf(fx,0,1) if visible else 0.0)
    sync_pose(hero._pose)
    if ornaments:ornaments.queue_redraw()
func _quad(part:String,rect:Rect2,origin:Vector2,angle:float=0.0) -> void:
    var mesh:Polygon2D=pieces[part]
    var points=PackedVector2Array()
    for point in [rect.position,rect.position+Vector2(rect.size.x,0),rect.end,rect.position+Vector2(0,rect.size.y)]:
        points.append(origin+point.rotated(deg_to_rad(angle))-hero.PIVOT)
    mesh.polygon=points
    if mesh.texture:
        var extent=mesh.texture.get_size()
        mesh.uv=PackedVector2Array([Vector2.ZERO,Vector2(extent.x,0),extent,Vector2(0,extent.y)])
func sync_pose(pose:String) -> void:
    if not visible or hero==null:return
    var socket:Vector2=hero.sockets(pose).chest
    var tilt=float(TILT.get(pose,0))
    var center=socket+Vector2(-15,-7) if hero.hero_id=="realmwachter" else socket+Vector2(9,5)
    if hero.hero_id=="schattenjager":center=socket+Vector2(-8,9)
    var fabric=active_id in ["forest_path","sand_traveler"]
    _quad("torso",Rect2(-40,-44,80,94),center,tilt)
    _quad("shoulder_left",Rect2(-57,-40,42,45 if not fabric else 57),center,tilt-7)
    _quad("shoulder_right",Rect2(20,-32,37,43 if not fabric else 53),center,tilt+7)
    _quad("hips",Rect2(-42,33,86,76 if fabric else 57),center,tilt*.5)
    var back:Vector2=hero.sockets(pose).back
    hero._palette.set_shader_parameter("modular_rear_cut",(back.x+18.0)/640.0)
    var cape_size=Vector2(208,180) if fabric else Vector2(165,140)
    var folded=hero.attachments!=null and hero.attachments.wings.visible
    if folded:cape_size.x*=.63
    _quad("cape",Rect2(-cape_size.x+20,-26,cape_size.x,cape_size.y),back,float(TILT.get(pose,0))*.3)
    var frames:Dictionary=feet.get(hero.hero_id,feet.realmwachter)
    var boots:Array=frames.get(pose,frames.idle)
    for i in 2:
        var b:Array=boots[i]
        _quad("boot_left" if i==0 else "boot_right",Rect2(float(b[0])-3,float(b[1])-9,float(b[2])+6,float(b[3])+12),Vector2.ZERO)
    if ornaments:ornaments.queue_redraw()
func _draw_refinement() -> void:
    if not visible or armor_plus<4 or fx<=0 or active_id not in ["wander_leather","silver_guard"]:return
    var socket:Vector2=hero.sockets(hero._pose).chest-hero.PIVOT
    var color=Color("#e8c38c") if active_id=="wander_leather" else Color("#9de4ff")
    for i in 1+int((armor_plus-4)/2):
        var at=socket+Vector2(-21+i*13,-7)
        ornaments.draw_circle(at,3.2,color.darkened(.4))
        ornaments.draw_circle(at,1.5,color)

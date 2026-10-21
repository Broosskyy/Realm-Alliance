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
var fits:Dictionary={}
var forearm:Polygon2D
var ornaments:Node2D
var cloth:ShaderMaterial
var hero
var fx=1.0
func attach(value) -> void:
    hero=value;name="ModularOutfit711";hero._art.add_child(self)
    feet=JSON.parse_string(FileAccess.get_file_as_string(ROOT+"foot_anchors.json"))
    fits=JSON.parse_string(FileAccess.get_file_as_string(ROOT+"fit_anchors.json")).heroes
    cloth=ShaderMaterial.new();cloth.shader=preload("res://assets/work711/wardrobe/cloth711.gdshader")
    for part in PARTS:
        var mesh=Polygon2D.new();mesh.name="Outfit_"+part;mesh.z_index=3 if part.begins_with("shoulder") else (-1 if part=="cape" else 1)
        if part=="cape":mesh.material=cloth
        add_child(mesh);pieces[part]=mesh
    ornaments=Node2D.new();ornaments.name="RefinementInlays711";ornaments.z_index=4;add_child(ornaments);ornaments.draw.connect(_draw_refinement)
    forearm=Polygon2D.new();forearm.name="PoseFittedGlove711";forearm.z_index=4;add_child(forearm)
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
func set_effects(value:float) -> void:
    fx=clampf(value,0.0,1.0)
    if cloth:cloth.set_shader_parameter("motion_strength",2.2*fx if visible else 0.0)
    if ornaments:ornaments.queue_redraw()
func sync_pose(pose:String) -> void:
    if not visible or hero==null:return
    var frames:Dictionary=fits.get(hero.hero_id,fits.realmwachter)
    var fit:Dictionary=frames.get(pose,frames.idle)
    var head_center=Vector2(fit.head[0],fit.head[1])
    hero._palette.set_shader_parameter("modular_head_region",Vector4((head_center.x-100.0)/640.0,(head_center.y-90.0)/512.0,(head_center.x+100.0)/640.0,(head_center.y+90.0)/512.0))
    hero._palette.set_shader_parameter("modular_leg_start",(minf(fit.hips[0][1],fit.hips[1][1])+24.0)/512.0)
    var fabric=active_id in ["forest_path","sand_traveler"]
    _surface("torso",fit.torso,.68)
    _surface("hips",fit.hips)
    for part in ["shoulder_left","shoulder_right"]:
        var p:Array=fit[part]
        _quad(part,Rect2(-float(p[2])*.5,-float(p[3])*.5,float(p[2]),float(p[3])),Vector2(float(p[0])+float(p[2])*.5,float(p[1])+float(p[3])*.5),float(p[4]))
    var back=Vector2(fit.torso[0][0],fit.torso[0][1])+Vector2(0,12)
    var cape_size=Vector2(172,178) if fabric else Vector2(144,153)
    var folded=hero.attachments!=null and hero.attachments.wings.visible
    if folded:cape_size.x*=.63
    _quad("cape",Rect2(-cape_size.x+28,-16,cape_size.x,cape_size.y),back)
    var boots:Array=fit.boots
    for i in 2:
        var b:Array=boots[i]
        _quad("boot_left" if i==0 else "boot_right",Rect2(float(b[0]),float(b[1]),float(b[2]),float(b[3])),Vector2.ZERO)
    var vertices=PackedVector2Array();var uv=PackedVector2Array()
    for p in fit.forearm:
        var v=Vector2(p[0],p[1]);vertices.append(v-hero.PIVOT);uv.append(v)
    forearm.texture=hero._body.texture;forearm.polygon=vertices;forearm.uv=uv
    if ornaments:ornaments.queue_redraw()
func _surface(part:String,corners:Array,bottom:float=1.0) -> void:
    var mesh:Polygon2D=pieces[part];var vertices=PackedVector2Array()
    for p in corners:vertices.append(Vector2(p[0],p[1])-hero.PIVOT)
    mesh.polygon=vertices
    var extent=mesh.texture.get_size();extent.y*=bottom
    mesh.uv=PackedVector2Array([Vector2.ZERO,Vector2(extent.x,0),extent,Vector2(0,extent.y)])
func cape_mask(pose:String) -> PackedVector2Array:
    var frames:Dictionary=fits.get(hero.hero_id,fits.realmwachter);var fit:Dictionary=frames.get(pose,frames.idle)
    var upper=Vector2(fit.torso[0][0],fit.torso[0][1]);var lower=Vector2(fit.hips[3][0],fit.hips[3][1])
    return PackedVector2Array([Vector2(0,160),Vector2(upper.x-55,160),upper+Vector2(-18,-20),upper+Vector2(-10,45),lower+Vector2(-5,-8),lower+Vector2(0,80),Vector2(0,512),Vector2(0,300)])
func _draw_refinement() -> void:
    if not visible or armor_plus<4 or fx<=0 or active_id not in ["wander_leather","silver_guard"]:return
    var surface:PackedVector2Array=pieces.torso.polygon
    var socket=(surface[0]+surface[1]+surface[2]+surface[3])*.25
    var color=Color("#e8c38c") if active_id=="wander_leather" else Color("#9de4ff")
    for i in 1+int((armor_plus-4)/2):
        var at=socket+Vector2(-21+i*13,-7)
        ornaments.draw_circle(at,3.2,color.darkened(.4))
        ornaments.draw_circle(at,1.5,color)

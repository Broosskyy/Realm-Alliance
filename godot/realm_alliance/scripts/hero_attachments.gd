extends RefCounted
class_name RAHeroAttachments
const Gear=preload("res://scripts/systems/hero_equipment.gd")
const TEXTURES={"astral_plate":preload("res://assets/equipment/astral_plate.png"),"eclipse_plate":preload("res://assets/equipment/eclipse_plate.png"),"sentinel_circlet":preload("res://assets/equipment/sentinel_circlet.png"),"sky_wings":preload("res://assets/equipment/sky_wings.png")}
const Evolution=preload("res://scripts/systems/hero_evolution.gd")
# Pose-local transforms, in the canonical 640x512 coordinate space. The foreground
# arm is a region of the same body texture; it correctly occludes the breastplate.
const POSES={
    "idle":{"angle":0.0,"arm":Rect2(476,295,55,75)},
    "ready":{"angle":-3.0,"arm":Rect2(478,290,60,80)},
    "windup":{"angle":-10.0,"arm":Rect2(425,208,75,92)},
    "attack_contact":{"angle":35.0,"arm":Rect2(440,286,140,82)},
    "recovery":{"angle":20.0,"arm":Rect2(416,365,65,80)},
    "hit":{"angle":-12.0,"arm":Rect2(454,303,65,76)}
}
var plate: Sprite2D
var foreground_arm: Sprite2D
var active_id: String=""
var head: Sprite2D
var wings: Sprite2D
var head_mount: Node2D
var wing_mount: Node2D
var visible_items: Dictionary={}
func attach(hero) -> void:
    plate=Sprite2D.new();plate.name="ReplaceableBreastplate";plate.z_index=1
    plate.scale=Vector2.ONE*.40;plate.position=Vector2(-4,5)
    hero.layer_sockets.chest.add_child(plate)
    foreground_arm=Sprite2D.new();foreground_arm.name="ForegroundArmOccluder"
    foreground_arm.region_enabled=true;foreground_arm.centered=false;foreground_arm.z_index=2
    foreground_arm.material=hero._palette;hero._art.add_child(foreground_arm)
    head_mount=Node2D.new();head_mount.name="DiademPivot";head_mount.position=Vector2(44,-8);head_mount.z_index=3
    hero.layer_sockets.head.add_child(head_mount)
    head=Sprite2D.new();head.name="ReplaceableDiadem";head.centered=false
    head.scale=Vector2.ONE*.50
    head.position=-Vector2(258.687,85.907)*.50
    head_mount.add_child(head)
    wing_mount=Node2D.new();wing_mount.name="BackClaspPivot";wing_mount.z_index=-2
    hero.layer_sockets.wings.add_child(wing_mount)
    wings=Sprite2D.new();wings.name="ReplaceableWings";wings.centered=false
    wings.scale=Vector2.ONE*.76;wings.position=-Vector2(403.357,261.561)*.76
    wing_mount.add_child(wings)
    apply(hero,{})
func apply(hero,profile: Dictionary) -> void:
    active_id=Gear.visible_id(profile,"chest") if profile.has("hero_equipment") else ""
    plate.texture=TEXTURES.get(active_id)
    plate.visible=plate.texture!=null
    visible_items.clear()
    for slot in Gear.SLOTS:visible_items[slot]=Gear.visible_id(profile,slot) if profile.has("hero_equipment") else ""
    head.texture=TEXTURES.get(visible_items.head);head.visible=head.texture!=null
    wings.texture=TEXTURES.get(visible_items.wings);wings.visible=wings.texture!=null
    if hero.cape:hero.cape.set_folded(hero,wings.visible)
    if hero.aura:hero.aura.awakened=Evolution.active(profile) if profile.has("hero_evolution") else false
    sync_pose(hero,hero._pose)
func sync_pose(hero,pose: String) -> void:
    if plate==null:return
    var d:Dictionary=POSES[pose]
    plate.rotation_degrees=float(d.angle)
    head_mount.rotation_degrees={"idle":0,"ready":-2,"windup":-5,"attack_contact":15,"recovery":8,"hit":8}[pose]
    wing_mount.rotation_degrees=float(d.angle)*.5
    foreground_arm.visible=plate.visible
    foreground_arm.texture=hero._body.texture
    foreground_arm.region_rect=d.arm
    foreground_arm.position=d.arm.position-hero.PIVOT

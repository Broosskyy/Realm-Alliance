extends RefCounted
class_name RAHeroAttachments
const Gear=preload("res://scripts/systems/hero_equipment.gd")
const TEXTURES={"astral_plate":preload("res://assets/equipment/astral_plate.png"),"eclipse_plate":preload("res://assets/equipment/eclipse_plate.png")}
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
func attach(hero) -> void:
    plate=Sprite2D.new();plate.name="ReplaceableBreastplate";plate.z_index=1
    plate.scale=Vector2.ONE*.40;plate.position=Vector2(-4,5)
    hero.layer_sockets.chest.add_child(plate)
    foreground_arm=Sprite2D.new();foreground_arm.name="ForegroundArmOccluder"
    foreground_arm.region_enabled=true;foreground_arm.centered=false;foreground_arm.z_index=2
    foreground_arm.material=hero._palette;hero._art.add_child(foreground_arm)
    apply(hero,{})
func apply(hero,profile: Dictionary) -> void:
    active_id=Gear.visible_id(profile,"chest") if profile.has("hero_equipment") else ""
    plate.texture=TEXTURES.get(active_id)
    plate.visible=plate.texture!=null
    sync_pose(hero,hero._pose)
func sync_pose(hero,pose: String) -> void:
    if plate==null:return
    var d:Dictionary=POSES[pose]
    plate.rotation_degrees=float(d.angle)
    foreground_arm.visible=plate.visible
    foreground_arm.texture=hero._body.texture
    foreground_arm.region_rect=d.arm
    foreground_arm.position=d.arm.position-hero.PIVOT

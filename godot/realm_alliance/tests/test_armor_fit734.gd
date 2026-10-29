extends SceneTree
# Body-specific armor fitting regression tests for six poses, dynamic equipment
# previews and exact equipped-item selection. No changes to player saves.
const Rig=preload("res://scripts/production_hero.gd")
const Session=preload("res://scripts/systems/combat_session.gd")
const Page=preload("res://scripts/ui/equipment_page.gd")
var passed=0
var failed=0
func verify(value:bool,description:String) -> void:
    if value:passed+=1
    else:
        failed+=1
        push_error("734 "+description)
func _initialize() -> void:call_deferred("run")
func near(a:Vector2,b:Vector2) -> bool:
    return a.distance_to(b)<0.1
func run() -> void:
    var rig=Rig.new()
    root.add_child(rig)
    var state=Session.new()
    state.profile.hero_equipment.owned.astral_plate={"level":3}
    state.profile.hero_equipment.equipped.chest="astral_plate"
    var original=JSON.stringify(state.snapshot())
    for character in ["runenpaladin","schattenjager","adventurer_male","adventurer_female","realmwachter"]:
        rig.set_hero(character)
        rig.set_gear(state.profile)
        for pose in ["idle","ready","windup","attack_contact","recovery","hit"]:
            rig._set_pose(pose)
            var table:Dictionary=rig.attachments.fits[character][pose]
            var corners=rig.attachments.plate.polygon
            verify(corners.size()==4,character+" "+pose+" polygon has four corners")
            if corners.size()==4:
                for i in 4:
                    var point=table.torso[i]
                    var target=Vector2(point[0],point[1])-rig.PIVOT-rig.layer_sockets.chest.position
                    verify(near(corners[i],target),character+" "+pose+" correct body anchor "+str(i))
            var mask=rig.attachments.fitted_forearm
            verify(mask.visible==(character!="realmwachter"),character+" "+pose+" no duplicate arm")
            if mask.visible:
                verify(mask.polygon.size()==table.forearm.size(),character+" "+pose+" forearm outline matches body")
                verify(not rig.attachments.foreground_arm.visible,character+" "+pose+" no duplicate rectangular arm")
    verify(JSON.stringify(state.snapshot())==original,"visual equipment changes do not mutate profile")
    rig.set_hero("runenpaladin")
    state.profile.wardrobe.owned.forest_path={}
    state.profile.wardrobe.active="forest_path"
    rig.set_gear(state.profile)
    verify(rig.wardrobe_visual.visible,"costume visible")
    verify(not rig.attachments.plate.visible and not rig.attachments.fitted_forearm.visible,"cosmetic hides original armor and occluder")
    var page=Page.new()
    root.add_child(page)
    state.profile.wardrobe.active=""
    page.configure(state,"chest")
    var tab=page.find_child("EquipmentTab_chest",true,false)
    verify(tab is Button and tab.button_pressed,"current category visually selected")
    verify(page.selected=="astral_plate","equipped item selected before locked ones")
    verify(page.find_child("EquipmentScroll",true,false)!=null,"mobile equipment page scrolls")
    page.queue_free()
    rig.queue_free()
    await process_frame
    print("REALM 734 ARMOR FIT %d/%d" % [passed,passed+failed])
    quit(1 if failed else 0)

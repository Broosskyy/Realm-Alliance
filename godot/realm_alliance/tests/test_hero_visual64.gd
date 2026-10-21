extends SceneTree
const Scene=preload("res://scenes/main.tscn")
const Session=preload("res://scripts/systems/combat_session.gd")
const Dialog=preload("res://scripts/ui/hero_equipment_dialog.gd")
var checks=0
var failures=0
func check(ok: bool,label: String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func _initialize() -> void:call_deferred("run")
func find_dialog(scene):
    for child in scene.get_children():
        if child is Dialog:return child
    return null
func run() -> void:
    var scene=Scene.instantiate();scene.initial_creation_enabled=false;root.add_child(scene);scene.hud.collection_page.category="Helden";scene.set_process(false);scene.auto_enabled=false;scene.audio.enabled=false
    scene.model=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());scene.hud.model=scene.model;scene._sync_hero();scene._refresh();scene._on_hud_action("Wesen")
    scene._open_gear("eclipse_plate")
    var dialog=find_dialog(scene)
    check(dialog!=null and dialog.get_ok_button().disabled,"unaffordable locked equipment has a real disabled confirm")
    dialog.queue_free();await process_frame
    scene.model.profile.xp=1000;scene.model.gold=1000;scene.model.profile.shards=100
    var sword=scene.hero._weapon.texture
    for id in ["astral_plate","eclipse_plate"]:
        scene._open_gear(id);dialog=find_dialog(scene)
        check(not dialog.get_ok_button().disabled,"actual requirements enable purchase: "+id)
        dialog.get_ok_button().pressed.emit();await process_frame
        check(scene.model.profile.hero_equipment.owned.has(id),"native dialog purchases real saved item: "+id)
        check(scene.hero.attachments.active_id==id and scene.hud.preview.attachments.active_id==id,"combat and preview share equipped layer: "+id)
        check(scene.hero._weapon.texture==sword,"armor cannot replace separate sword texture")
        for pose in scene.hero.Gate.HERO_STATES:
            scene.hero._set_pose(pose)
            check(scene.hero._body.texture==scene.hero._outfit_poses[pose] and not scene.hero.attachments.plate.visible,"authored worn outfit replaces inventory thumbnail in "+pose)
            check(scene.hero.attachments.plate.get_parent()==scene.hero.layer_sockets.chest,"armor follows chest socket in "+pose)
            check(scene.hero.attachments.foreground_arm.texture==scene.hero._body.texture,"correct same-pose arm occlusion: "+pose)
        scene.hero._set_pose("idle")
    scene._open_gear("eclipse_plate");dialog=find_dialog(scene)
    var before=scene.model.defense
    for b in dialog.find_children("*","Button",true,false):
        if b.text=="Stufe +1":b.pressed.emit();break
    await process_frame
    check(scene.model.defense==before+1,"dialog upgrade changes actual defense")
    scene._open_gear("eclipse_plate");dialog=find_dialog(scene);dialog.get_ok_button().pressed.emit();await process_frame
    check(scene.hero.attachments.active_id=="" and scene.model.defense==0,"native unequip removes art and real armor stats")
    scene._on_hud_action("look");scene._on_hud_action("look")
    check(scene.model.profile.look=="astral" and scene.hero._palette.get_shader_parameter("astral"),"additional cape palette is a real separate look")
    for viewport in [Vector2i(360,800),Vector2i(720,1280),Vector2i(720,1560),Vector2i(1280,720)]:
        root.size=viewport;await process_frame;scene._layout();scene._refresh()
        var pixels=root.get_final_transform().get_scale().x*scene.hud.scale.x
        for id in ["gear_astral_plate","gear_sentinel_circlet","gear_sky_wings"]:
            var size=scene.hud.buttons[id].size*pixels
            check(size.x>=44 and size.y>=44,"equipment touch target >=44 physical pixels: "+str(viewport)+id)
    var data=scene.model.snapshot();data.profile.hero_equipment="future_format";scene.model=Session.new(data);scene.hud.model=scene.model
    scene._sync_hero();scene._refresh()
    check(scene.model.read_only,"unknown equipment shape remains safely readable without UI crash")
    scene.queue_free();await process_frame
    print("Hero visual 6.4: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)

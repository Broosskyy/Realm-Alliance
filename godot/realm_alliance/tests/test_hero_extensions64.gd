extends SceneTree
const Scene=preload("res://scenes/main.tscn")
const Session=preload("res://scripts/systems/combat_session.gd")
const Gear=preload("res://scripts/systems/hero_equipment.gd")
const Evo=preload("res://scripts/systems/hero_evolution.gd")
const GearDialog=preload("res://scripts/ui/hero_equipment_dialog.gd")
const EvoDialog=preload("res://scripts/ui/hero_development708.gd")
var checks=0
var failures=0
func check(ok: bool,label: String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func _initialize() -> void:call_deferred("run")
func run() -> void:
    var bare=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());bare.gold=1000;bare.profile.shards=100
    check(not bare.change_evolution(),"evolution level requirement enforced")
    check(bare.gold==1000 and bare.profile.shards==100,"failed unlock never spends currency")
    bare.profile.xp=440;bare.player_hp=100
    check(bare.level==5 and bare.change_evolution(),"first evolution unlocks at actual XP level five")
    check(bare.gold==850 and bare.profile.shards==92,"one unlock spends exact resources")
    check(bare.player_max_hp==218 and bare.hero_damage()==28 and bare.player_hp==120,"permanent progression bonuses preserve missing health")
    check(not Evo.unlock(bare.profile) and bare.gold==850,"duplicate unlock is idempotent")
    for i in 6:check(bare.change_evolution() and bare.player_hp==120 and bare.hero_damage()==28,"form switch cannot heal or change permanent power")
    var resumed=Session.new(bare.snapshot())
    check(Evo.active(resumed.profile) and resumed.player_max_hp==218,"evolution round-trip keeps owned and active form")
    var future=bare.snapshot();future.profile.hero_evolution.schema=8
    var protected_save=Session.new(future)
    check(protected_save.read_only and protected_save.profile.hero_evolution.schema==8,"future evolution domain preserved")
    check(not protected_save.change_evolution(),"future evolution cannot mutate")
    var scene=Scene.instantiate();scene.initial_creation_enabled=false;root.add_child(scene);scene.hud.collection_page.category="Helden";scene.set_process(false);scene.auto_enabled=false;scene.audio.enabled=false
    scene.model=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());scene.model.profile.xp=1000;scene.model.gold=1500;scene.model.profile.shards=100;scene.hud.model=scene.model
    scene._on_hud_action("Wesen")
    for id in Gear.IDS:
        if bool(Gear.CATALOG[id].get("event",false)):continue
        scene._open_gear(id)
        var dialog
        for child in scene.get_children():
            if child is GearDialog:dialog=child
        check(dialog!=null and not dialog.get_ok_button().disabled,"native equipment detail accepts real acquisition: "+id)
        dialog.get_ok_button().pressed.emit();await process_frame
        check(scene.model.profile.hero_equipment.owned.has(id),"acquired item persisted in domain: "+id)
        check(scene.hero.attachments.visible_items[Gear.CATALOG[id].slot]==id,"combat rig receives correct slot: "+id)
    check(scene.model.defense==8,"armor, head, wings and the two-piece set contribute independently")
    scene.model.profile.economy.materials.forge_dust=10
    scene.hud.buttons.evolve.pressed.emit()
    var evo_dialog
    for child in scene.get_children():
        if child is EvoDialog:evo_dialog=child
    var ascend=evo_dialog.find_child("HeroAscend",true,false) if evo_dialog else null
    check(ascend!=null and not ascend.disabled,"native individual ascension has a real validated action")
    if not ascend:scene.queue_free();quit(1);return
    ascend.pressed.emit();await process_frame
    check(scene.hero.aura.mastery_rank==1 and scene.hud.preview.aura.mastery_rank==1,"both hero instances show the individually earned rank")
    evo_dialog.queue_free();await process_frame
    for actor in [scene.hero,scene.hud.preview]:
        for pose in actor.Gate.HERO_STATES:
            actor._set_pose(pose)
            var rig=actor.attachments
            var head_point=rig.head.position+rig.head.texture.get_size()*.5*rig.head.scale
            var back_point=rig.wings.position+Vector2(403.357,261.561)*rig.wings.scale
            check(head_point.length()<.01,"diadem pivots around its physical forehead anchor: "+pose)
            check(back_point.length()<.01,"wings pivot around the clasp: "+pose)
            check(rig.wing_mount.z_index<0 and rig.head_mount.z_index>0,"body/wing/head draw ordering: "+pose)
            check(rig.head.visible and rig.wings.visible and actor.weapon_is_modular(),"independent attachments and sword remain active: "+pose)
    var defense=scene.model.defense
    check(Gear.set_cosmetic(scene.model.profile,"head",""),"cosmetic override accepts owned head layer")
    scene._sync_hero();scene._refresh()
    check(not scene.hero.attachments.head.visible and scene.model.defense==defense,"hiding head art cannot remove real equipped stats")
    for v in [Vector2i(360,800),Vector2i(720,1280),Vector2i(720,1560),Vector2i(1280,720)]:
        root.size=v;await process_frame;scene._layout();scene._refresh()
        var scale=root.get_final_transform().get_scale().x*scene.hud.scale.x
        for id in ["gear_sentinel_circlet","gear_sky_wings","evolve","hero_skill_0","hero_skill_3","equip_shadow_violet"]:
            var b=scene.hud.buttons[id]
            check(b.visible and b.size.x*scale>=44 and b.size.y*scale>=44,"real mobile target: "+id+str(v))
        check(scene.hud.buttons.hero_skill_3.position.y+scene.hud.buttons.hero_skill_3.size.y<scene.hud.buttons["return"].position.y,"skill info stays above return navigation")
    scene.preferences.effects=2;scene._apply_preferences();scene.hud.update_buttons()
    check(scene.hero.aura.fx_intensity==0 and scene.hud.preview.aura.fx_intensity==0,"effects-off reaches both evolution presentation layers")
    scene.queue_free();await process_frame
    print("Hero extensions 6.4: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)

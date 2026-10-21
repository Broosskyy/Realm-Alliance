extends SceneTree
const Session=preload("res://scripts/systems/combat_session.gd")
const Main=preload("res://scenes/main.tscn")
const QA=preload("res://scripts/systems/admin_qa.gd")
const Timeline=preload("res://scripts/presentation/animation_timeline.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func prepared():
    var m=Session.new(preload("res://tests/legacy_fixture709.gd").guardian())
    for op in ["gold","shards","level","world"]:QA.apply(m,op)
    return m
func _initialize():call_deferred("run")
func run():
    var m=prepared()
    check(m.unlock_hero("schattenjager"),"new playable hero obeys real unlock command")
    var enemy=m.enemy_hp;var wave=m.wave;var run_id=m.run_id;var gold=m.gold
    check(m.select_hero("schattenjager") and m.enemy_hp==enemy and m.wave==wave and m.run_id==run_id,"new hero switch preserves encounter")
    var restored=Session.new(JSON.parse_string(JSON.stringify(m.snapshot())))
    check(not restored.read_only and restored.hero_id=="schattenjager" and restored.gold==gold,"new hero round-trips through JSON save")
    check(restored.select_hero("realmwachter") and restored.enemy_hp==enemy,"switch back preserves enemy HP")
    m=prepared();m.profile.companions.owned.lanternwisp={"xp":0,"evolution":0,"source":"event_shop"};m.select_companion("lanternwisp");m.behavior.deadline=1000
    m.tick(1.0/60)
    check(not m.companion.pending.is_empty(),"event pet starts delayed attack")
    restored=Session.new(JSON.parse_string(JSON.stringify(m.snapshot())))
    check(not restored.read_only and restored.companion.pending.get("id","")=="lanternwisp","pending event-pet attack remains writable after reload")
    m.drain_events();restored.drain_events();m.tick(.46);restored.tick(.46)
    check(m.enemy_hp==restored.enemy_hp and m.drain_events()==restored.drain_events(),"event-pet pending attack resolves identically after reload")
    m=prepared();m.unlock_hero("runenpaladin");m.select_hero("runenpaladin");m.player_hp=30
    m.hero_status.active.shield={"expires":100.0,"amount":1000,"counter":false}
    m._enemy_strike(1,false)
    check(m.player_hp>30 and m.player_hp<=m.player_max_hp,"paladin's advertised block heal executes and is bounded")
    for step in 3:
        var before=Timeline.sample("chain_%d_1"%step,.2799,.28,.35)
        var after=Timeline.sample("chain_%d_1"%step,.2801,.28,.35)
        check(before.offset.distance_to(after.offset)<.2,"no root teleport at chain impact "+str(step))
        check(after.pose=="attack_contact","impact uses contact pose "+str(step))
    var scene=Main.instantiate();scene.initial_creation_enabled=false;root.add_child(scene);scene.hud.collection_page.category="Helden";scene.set_process(false);scene.auto_enabled=false;scene.audio.enabled=false
    scene.model=prepared();scene.hud.model=scene.model;scene._sync_hero();scene._show_encounter();scene._refresh()
    for intensity in [0.0,.4,1.0]:
        scene.model.clock=0;scene.camera_feedback.intensity=intensity;scene.camera_feedback.impact(4,.08);scene._process(1.0/30)
        check(absf(scene.model.clock-1.0/30)<.00001,"presentation FX cannot slow simulation: "+str(intensity))
    scene._on_hud_action("Wesen")
    check(not scene.hud.buttons.gear_eclipse_plate.visible and scene.hud.buttons.gear_astral_plate.visible,"one visible armor category slot")
    scene.hud.buttons.gear_astral_plate.pressed.emit()
    var browser
    for child in scene.get_children():
        if child is RARosterDialog:check(false,"armor opens equipment browser, not hero collection")
        if child.get_script() and child.get_script().resource_path.ends_with("equipment_page.gd"):browser=child
    check(browser!=null,"armor slot opens real item selection")
    if browser:browser.queue_free()
    scene.hero.set_hero("schattenjager")
    for pose in scene.hero.Gate.HERO_STATES+["defeated","run"]:
        scene.hero._set_pose(pose)
        check(scene.hero._body.texture!=null and scene.hero.weapon_is_modular(),"new pose and separate weapon: "+pose)
        var im=scene.hero._body.texture.get_image()
        check(im.get_size()==Vector2i(640,512) and im.get_pixel(0,0).a==0,"normalized transparent sprite: "+pose)
    for id in ["stone_sentry","cinder_colossus"]:
        scene.enemy.configure_enemy({"visual":id,"kind":"normal"})
        for pose in ["idle","attack","hit","defeated"]:
            scene.enemy._set_pose(pose)
            check(scene.enemy._sprite.texture.resource_path.contains("expansion702/"+id+"/"+pose),"real distinct monster pose "+id+pose)
    scene.queue_free();await process_frame
    print("Polish 7.0.2: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)

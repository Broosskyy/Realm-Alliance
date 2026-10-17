extends SceneTree
const Session=preload("res://scripts/systems/combat_session.gd")
const Layout=preload("res://scripts/combat_layout.gd")
var scene
var checks=0
var failures=0
var capture=false
func check(ok: bool,message: String) -> void:
    checks+=1
    if not ok: failures+=1;push_error("FAIL "+message)
func _initialize() -> void:
    call_deferred("_run")
func _run() -> void:
    capture="--capture-ui" in OS.get_cmdline_user_args()
    scene=load("res://scenes/main.tscn").instantiate()
    root.size=Vector2i(720,1280)
    root.add_child(scene)
    scene.set_process(false)
    scene.auto_enabled=false
    scene.model=Session.new()
    scene.hud.model=scene.model
    scene._show_encounter();scene._sync_hero();scene._refresh()
    check(scene._production_enabled,"canonical assets active")
    check(scene.hero.weapon_is_modular(),"arena sword remains independent")
    check(scene.hud.preview.weapon_is_modular(),"Wesen uses actual separate weapon rig")
    for tab in ["Abenteuer","Wesen","Beute","Mehr","Kampf"]:
        scene.hud.buttons[tab].pressed.emit()
        check(scene.active_tab==tab,"navigation opens "+tab)
        if tab!="Kampf":check(not scene._on_tap(),"shell blocks combat input")
    scene._on_hud_action("Wesen")
    scene.hud.buttons.look.pressed.emit()
    check(scene.model.profile.look=="emerald","real cape palette toggle persists in model")
    check(scene.hero._palette.get_shader_parameter("emerald")==true,"arena cape shader updated")
    check(scene.hud.preview._palette.get_shader_parameter("emerald")==true,"preview and arena share look")
    for pose in scene.hero.Gate.HERO_STATES:
        scene.hero._set_pose(pose)
        check(scene.hero.layer_sockets.head.position==scene.hero.VISUAL_SOCKETS[pose].head-scene.hero.PIVOT,"pose-compatible head socket "+pose)
        check(scene.hero._weapon.material==null,"sword excluded from cape palette")
    scene.hero._set_pose("idle")
    scene.model.gold=100
    var before=scene.model.hero_damage()
    scene.hud.buttons.upgrade.pressed.emit()
    check(scene.model.hero_damage()>before and scene.model.gold==80,"upgrade changes real stats and spends gold")
    scene._on_hud_action("Kampf")
    check(scene._on_skill(1),"arcane skill accepted through input layer")
    scene.model.tick(0.6);scene._consume_events();scene._refresh()
    check(scene.model.enemy_status.has("mark",scene.model.clock),"mark reaches live scene")
    await create_timer(0.6).timeout
    await snap("slime-mark")
    scene.model.profile.xp=180
    scene.model.momentum=100
    scene._refresh()
    check(not scene.hud.buttons.locked.disabled,"defensive skill unlocked in HUD")
    scene._on_skill(3)
    scene.model.behavior.state="windup";scene.model.behavior.deadline=scene.model.clock+0.1
    scene.model.tick(0.2);scene._consume_events();scene._refresh()
    check(scene.hero.aura.shielded,"shield state visible on real hero rig")
    await snap("shield-counter")
    scene._on_hud_action("Wesen");scene._on_hud_action("aura")
    check(scene.model.profile.aura and scene.hud.preview.aura.evolution,"unlocked evolution aura has a real layer")
    await snap("hero-emerald")
    scene._on_hud_action("Kampf")
    scene.model=Session.new();scene.hud.model=scene.model
    scene.hero.revive();scene._show_encounter()
    var elapsed=0.0
    var seen={}
    while scene.model.outcome not in ["victory","defeat"] and elapsed<120:
        if scene.model.outcome=="fighting":
            if not scene.model.request_action("sky_blade"):scene.model.request_action()
        scene.model.tick(0.1)
        scene._consume_events();scene._refresh()
        elapsed+=0.1
        if not seen.has(scene.model.encounter):
            seen[scene.model.encounter]=true
            if scene.model.encounter in [2,4]:
                await create_timer(0.8).timeout
                await snap("elite" if scene.model.encounter==2 else "boss")
        await process_frame
    check(scene.model.outcome=="victory","complete live-scene run reaches victory")
    check(scene.hud.buttons.restart.visible,"victory offers working restart")
    await create_timer(0.4).timeout
    await snap("victory")
    scene._on_hud_action("Beute")
    check(scene.model.profile.inventory.size()==5,"all five sword items in live loot loop")
    await snap("loot")
    scene.hud.buttons.equip_shadow_violet.pressed.emit()
    check(scene.model.profile.equipped=="shadow_violet","loot item button equips real weapon")
    scene._on_hud_action("Wesen")
    await snap("hero-equipped")
    scene._on_hud_action("Kampf")
    scene.hud.buttons.restart.pressed.emit()
    check(scene.model.outcome=="fighting" and scene.model.tier==1,"victory restart advances tier")
    scene.model.tick(150);scene._consume_events();scene._refresh()
    check(scene.model.outcome=="defeat","actual scene supports defeat")
    await create_timer(0.6).timeout
    await snap("defeat")
    scene.hud.buttons.restart.pressed.emit()
    check(scene.model.player_hp==scene.model.player_max_hp,"defeat restart restores health")
    scene._on_hud_action("Mehr")
    check(scene.hud.buttons.save_export.visible and scene.hud.buttons.save_import.visible,"save transfer actions visible in More")
    scene._pending_import={"version":1,"wave":3,"gold":777,"weapon_index":1,"upgrade_level":2,"total_kills":2}
    check(scene._apply_import(),"confirmed legacy import loads into actual scene")
    check(scene.model.gold==777 and scene.model.weapon_index==1 and scene.model.wave==3,"imported legacy state is actually playable")
    scene.auto_enabled=false
    scene._on_hud_action("Kampf")
    for v in [Vector2i(720,1560),Vector2i(360,800),Vector2i(1280,720)]:
        root.size=v;await process_frame;scene._layout();scene._refresh()
        var m=Layout.solve(v)
        for id in ["skill0","skill1","skill2","locked"]:
            var b:Button=scene.hud.buttons[id]
            check(b.position.y+b.size.y<=scene.hud.buttons.Kampf.position.y,"skills above navigation")
            check(b.size.x*m.ui_scale>=44,"minimum 44px target")
        await snap("combat-%dx%d"%[v.x,v.y])
    print("Combat UI 6.2: %d/%d checks"%[checks-failures,checks])
    scene.queue_free();await process_frame
    quit(1 if failures else 0)
func snap(name: String) -> void:
    if not capture:return
    await process_frame
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png("/tmp/realm62-"+name+".png")

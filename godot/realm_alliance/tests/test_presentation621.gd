extends SceneTree
const Scene=preload("res://scenes/main.tscn")
const Session=preload("res://scripts/systems/combat_session.gd")
const Hero=preload("res://scripts/production_hero.gd")
const Timeline=preload("res://scripts/presentation/animation_timeline.gd")
var checks=0
var failures=0
var capture=false
func check(ok: bool, label: String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func _initialize() -> void:call_deferred("run")
func run() -> void:
    capture="--capture-ui" in OS.get_cmdline_user_args()
    root.size=Vector2i(720,1560)
    var scene=Scene.instantiate();root.add_child(scene);scene.set_process(false);scene.auto_enabled=false
    await process_frame
    var hero=scene.hero
    for index in 5:
        hero.equip_weapon(index)
        for pose in hero.Gate.HERO_STATES:
            hero._set_pose(pose)
            check(hero._socket.z_index>scene.enemy.z_index,"blade in foreground: %d %s"%[index,pose])
            check((hero._weapon.position+Hero.BLADE_GRIP*hero._weapon.scale).length()<0.01,"grip invariant")
    scene._on_hud_action("Wesen")
    check(scene.hud.preview._socket.z_index>scene.hud.z_index+scene.hud.preview.z_index,"preview weapon remains above UI backing")
    await snap("hero-rig")
    scene._on_hud_action("Kampf")
    for id in Session.SKILL_IDS:
        scene.model=Session.new();scene.model.profile.xp=180;scene.model.momentum=100;scene.model.rage=100
        scene.model.enemy_hp=10000;scene.model.enemy_max_hp=10000;scene.model.player_hp=scene.model.player_max_hp
        scene.hud.model=scene.model;scene.hero.revive();scene._show_encounter();scene._sync_hero()
        var d:Dictionary=scene.model.Definitions.all()[id]
        var before=scene.model.enemy_hp
        check(scene.model.request_action(id),"start "+id);scene._consume_events()
        if id!="guardian_wall":
            scene.model.tick(ceilf(float(d.windup)/Session.STEP)*Session.STEP-Session.STEP);scene._consume_events()
            check(scene.model.enemy_hp==before,"no early damage "+id)
            check(scene.hero._pose==("ready" if id=="arcane_eye" else "attack_contact"),"correct preparation pose "+id)
            scene.model.tick(1.0/60.0);scene._consume_events()
            check(scene.model.enemy_hp<before,"damage on exact impact "+id)
            check(absf(scene.hero._action_elapsed-float(d.windup))<=Session.STEP,"visual/model impact agreement "+id)
        else:
            scene.model.behavior.state="windup";scene.model.behavior.deadline=0.1
            scene.model.tick(0.1);scene._consume_events()
            check(scene.model.player_hp==scene.model.player_max_hp,"defensive cast absorbs and counters")
            check(scene.vfx.status.shielded,"shield has persistent VFX")
        check(scene.vfx.get_child_count()>1,"real effect nodes exist "+id)
        await create_timer(0.08).timeout
        scene._refresh();await snap(id)
    var anchor=scene.enemy.position
    scene.enemy.play_telegraph(0.3,"heavy");await create_timer(0.15).timeout
    scene.enemy.play_hit();await create_timer(0.1).timeout
    check(scene.enemy.position==anchor,"hit cannot alter enemy layout anchor or cancel telegraph")
    scene.hero.revive();var hpos=scene.hero.position;scene.hero.play_hit();await create_timer(0.25).timeout
    check(scene.hero.position==hpos,"hero reaction cannot move layout slot")
    scene.vfx.clear();await process_frame
    for i in 60:scene.vfx.emit_effect("sky_impact",Vector2.ZERO)
    var active=0
    for node in scene.vfx.get_children():
        if node is RASkillVFX and not node.is_queued_for_deletion():active+=1
    check(active<=24,"bounded simultaneous VFX")
    scene.vfx.intensity=0
    check(scene.vfx.emit_effect("fire_impact",Vector2.ZERO)==null,"optional VFX can be disabled")
    scene.camera_feedback.intensity=0;scene.camera_feedback.reset();scene.camera_feedback.impact(7,0.1)
    check(scene.camera_feedback.hold==0 and scene.camera_feedback.offset()==Vector2.ZERO,"reduced effects remove hitstop and shake")
    for texture in scene.vfx.TEX.values():
        var im=texture.get_image()
        check(im.get_size()==Vector2i(512,512) and im.get_pixel(0,0).a==0,"VFX alpha and common canvas")
    scene._on_hud_action("Mehr")
    check(scene.hud.buttons.sound.visible and scene.hud.buttons.effects.visible,"accessible audio/VFX controls")
    scene.queue_free();await process_frame
    print("Presentation 6.2.1: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)
func snap(id: String) -> void:
    if not capture:return
    await process_frame;await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png("/tmp/realm621-"+id+".png")

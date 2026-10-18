extends SceneTree
const Scene=preload("res://scenes/main.tscn")
const Session=preload("res://scripts/systems/combat_session.gd")
func _initialize() -> void:call_deferred("run")
func run() -> void:
    if not "realm62-test" in OS.get_environment("XDG_DATA_HOME"):quit(2);return
    DirAccess.make_dir_recursive_absolute("/tmp/realm64-complete-captures")
    var scene=Scene.instantiate();root.add_child(scene);scene.set_process(false);scene.auto_enabled=false;scene.audio.enabled=false
    scene.model=Session.new();scene.model.profile.xp=1000;scene.model.gold=1500;scene.model.profile.shards=100;scene.hud.model=scene.model
    for id in scene.model.HeroEquipment.IDS:
        scene.model.change_gear(id,"acquire");scene.model.change_gear(id)
    scene.model.change_evolution();scene.model.player_hp=scene.model.player_max_hp
    scene._on_hud_action("Wesen");scene.hud.preview.set_process(false);scene.hud.preview.aura.set_process(false);scene.hud.preview.aura.clock=1
    for size in [Vector2i(360,800),Vector2i(720,1280),Vector2i(720,1560),Vector2i(1280,720)]:
        root.size=size;await process_frame;scene._layout();scene._sync_hero();scene._refresh();await create_timer(.2).timeout
        scene.hud.preview._set_pose("idle");await snap("complete-%dx%d"%[size.x,size.y])
    root.size=Vector2i(720,1560);await process_frame;scene._layout();scene._refresh()
    for id in ["astral_plate","eclipse_plate"]:
        scene.model.change_gear(id);scene._sync_hero();scene._refresh()
        for pose in scene.hud.preview.Gate.HERO_STATES:
            scene.hud.preview._set_pose(pose);await snap(id+"-"+pose)
    scene.hud.preview._set_pose("idle")
    scene._open_evolution();await create_timer(.2).timeout;await snap("evolution-dialog")
    for child in scene.get_children():
        if child is Window:child.queue_free()
    await process_frame;scene._on_hud_action("Kampf")
    scene.model.encounter=4;scene.model._spawn();scene._show_encounter();scene._sync_hero();scene._refresh()
    await create_timer(.2).timeout;scene._on_skill(0);scene.model.tick(.42);scene._consume_events();scene._refresh();await create_timer(.05).timeout;await snap("equipped-combat-skill")
    scene.queue_free();await process_frame
    print("Complete 6.4 rig captures: genuine Godot scenes, seeded level-8 equipment fixture, both armor variants and six poses; actual model-timed combat skill.");quit()
func snap(name: String) -> void:
    await process_frame;await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png("/tmp/realm64-complete-captures/"+name+".png")

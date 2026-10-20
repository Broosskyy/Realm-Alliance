extends SceneTree
const Scene=preload("res://scenes/main.tscn")
const Session=preload("res://scripts/systems/combat_session.gd")
func _initialize() -> void:call_deferred("run")
func run() -> void:
    if not "realm62-test" in OS.get_environment("XDG_DATA_HOME"):quit(2);return
    DirAccess.make_dir_recursive_absolute("/tmp/realm64-captures")
    var scene=Scene.instantiate();root.add_child(scene);scene.set_process(false);scene.auto_enabled=false;scene.audio.enabled=false
    scene.model=Session.new();scene.model.profile.xp=1000;scene.model.gold=1000;scene.model.profile.shards=100;scene.hud.model=scene.model
    scene._on_hud_action("Wesen");scene.hud.preview.set_process(false)
    for id in ["astral_plate","eclipse_plate"]:
        scene.model.change_gear(id,"acquire");scene.model.change_gear(id);scene._sync_hero();scene._refresh()
        for size in [Vector2i(360,800),Vector2i(720,1280),Vector2i(720,1560),Vector2i(1280,720)]:
            root.size=size;await process_frame;scene._layout();scene._refresh();await create_timer(.2).timeout
            scene.hud.preview._set_pose("idle");await snap("%s-%dx%d"%[id,size.x,size.y])
        root.size=Vector2i(720,1560);await process_frame;scene._layout();scene._refresh()
        for pose in scene.hud.preview.Gate.HERO_STATES:
            scene.hud.preview._set_pose(pose);await snap(id+"-"+pose)
    root.size=Vector2i(720,1560);scene.model.set_look("astral");scene._sync_hero();await process_frame;scene._layout();scene._refresh();scene.hud.preview._set_pose("idle");await snap("astral-cloak")
    root.size=Vector2i(360,800);await process_frame;scene._layout();scene._refresh();scene._open_gear("eclipse_plate");await create_timer(.2).timeout;await snap("gear-dialog-360x800")
    scene.queue_free();await process_frame;print("Real hero/equipment scene captures complete; controlled saved-profile fixture, both authored armors, four viewports and six poses.");quit()
func snap(name: String) -> void:
    await process_frame;await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png("/tmp/realm64-captures/"+name+".png")

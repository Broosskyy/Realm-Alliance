extends SceneTree
const Scene=preload("res://scenes/main.tscn")
const Session=preload("res://scripts/systems/combat_session.gd")
func _initialize() -> void:call_deferred("run")
func run() -> void:
    if not "realm62-test" in OS.get_environment("XDG_DATA_HOME"):
        push_error("Capture requires isolated data directory");quit(2);return
    DirAccess.make_dir_recursive_absolute("/tmp/realm621-captures")
    for size in [Vector2i(360,800),Vector2i(720,1280),Vector2i(720,1560),Vector2i(1280,720)]:
        root.size=size
        for index in range(4 if size==Vector2i(720,1560) else 1):
            var scene=Scene.instantiate();root.add_child(scene);scene.auto_enabled=false
            scene.model=Session.new();scene.model.profile.xp=180;scene.model.player_hp=scene.model.player_max_hp
            scene.model.encounter=4;scene.model._spawn();scene.model.momentum=100;scene.model.rage=100
            scene.hud.model=scene.model;scene._last_visual_key="";scene._show_encounter();scene._sync_hero();scene._refresh()
            await create_timer(0.5).timeout
            scene._on_skill(index)
            await create_timer(float(scene.model.Definitions.all()[Session.SKILL_IDS[index]].windup)+0.12).timeout
            await RenderingServer.frame_post_draw
            root.get_texture().get_image().save_png("/tmp/realm621-captures/%dx%d-%s.png"%[size.x,size.y,Session.SKILL_IDS[index]])
            scene.queue_free();await process_frame
    print("Captured four real Godot viewports and four skills against the canonical boss fixture (normal catalog HP, no fake damage events).")
    quit()

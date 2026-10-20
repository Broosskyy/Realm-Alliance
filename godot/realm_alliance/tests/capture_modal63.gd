extends SceneTree
func _initialize() -> void:call_deferred("run")
func run() -> void:
    root.size=Vector2i(720,1560)
    var scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);scene.auto_enabled=false
    scene._on_hud_action("Mehr");await create_timer(.6).timeout
    scene._confirm_import({"version":1,"wave":3,"gold":777,"weapon_index":1,"upgrade_level":2,"total_kills":2})
    await create_timer(.4).timeout;await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png("/tmp/realm63-modal.png");quit()

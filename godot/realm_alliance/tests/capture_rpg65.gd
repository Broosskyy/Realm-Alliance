extends SceneTree
const Session=preload("res://scripts/systems/combat_session.gd")
var scene
var out="/tmp/realm65-captures"
func _initialize() -> void:call_deferred("run")
func capture(name: String) -> void:
    await process_frame;await process_frame
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(out+"/"+name+".png")
func run() -> void:
    DirAccess.make_dir_recursive_absolute(out)
    scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);scene.set_process(false);scene.auto_enabled=false;scene.audio.enabled=false
    scene.model=Session.new();scene.model.profile.xp=1000;scene.model.gold=2000;scene.model.profile.shards=100;scene.model.profile.kills=10
    for id in scene.model.Equipment.IDS:scene.model.profile.inventory[id]={"id":id,"level":2,"rarity":scene.model.Equipment.definition(id).rarity}
    for id in scene.model.HeroEquipment.IDS:scene.model.change_gear(id,"acquire");scene.model.change_gear(id)
    scene.model.change_evolution()
    for i in 5:scene.model.World.clear_stage(scene.model.profile,"wolkgarten",i,1)
    scene.model.Chests.grant(scene.model.profile,"capture-fixture-boss")
    scene.hud.model=scene.model;scene._sync_hero();scene._refresh()
    for v in [Vector2i(360,800),Vector2i(720,1280),Vector2i(720,1560),Vector2i(1280,720)]:
        root.size=v;await process_frame;scene._layout()
        for tab in ["Abenteuer","Beute","Wesen"]:
            scene._on_hud_action(tab);scene._refresh();await capture(tab.to_lower()+"-%dx%d"%[v.x,v.y])
    root.size=Vector2i(720,1560);await process_frame;scene._layout()
    scene.model.start_stage("glutkern");scene._on_hud_action("Kampf");scene._consume_events();scene._refresh();scene.hud.toast_until=0;scene.hud.update_buttons()
    await capture("glutkern-boar")
    for pose in ["attack","hit","defeated"]:
        scene.enemy._set_pose(pose);await capture("boar-"+pose)
    scene.model.World.clear_stage(scene.model.profile,"glutkern",3,1);scene.model.start_stage("glutkern",4);scene._consume_events();scene._refresh()
    scene.model.tick(2.12);scene._consume_events();scene._refresh();await capture("boss-eruption-warning")
    scene.model.tick(1.5);scene._consume_events();scene._refresh();await capture("boss-eruption-impact")
    scene._on_hud_action("Mehr");scene._open_quests(false);await capture("quests")
    for c in scene.get_children():
        if c is Window:c.queue_free()
    await process_frame
    scene._on_hud_action("Wesen");scene._open_skill_info(0);await capture("skill-upgrade")
    scene.queue_free();await process_frame;quit()

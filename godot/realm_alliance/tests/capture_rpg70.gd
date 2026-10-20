extends SceneTree
const Session=preload("res://scripts/systems/combat_session.gd")
var scene
var out="/tmp/realm70-captures"
func _initialize():call_deferred("run")
func capture(name:String) -> void:
    await process_frame;await process_frame
    await RenderingServer.frame_post_draw
    root.get_texture().get_image().save_png(out+"/"+name+".png")
func close_dialogs() -> void:
    for child in scene.get_children():
        if child is Window:child.queue_free()
    await process_frame
func run():
    DirAccess.make_dir_recursive_absolute(out)
    scene=load("res://scenes/main.tscn").instantiate();root.add_child(scene);scene.set_process(false);scene.auto_enabled=false;scene.audio.enabled=false;scene._qa_active=true
    var m=Session.new();m.profile.xp=5000;m.profile.gold=5000;m.profile.shards=500
    for region in m.World.IDS:
        for i in 5:m.World.clear_stage(m.profile,region,i,1)
    m.profile.economy.materials.forge_dust=200;m.profile.economy.materials.ember_core=20;m.profile.economy.materials.harvest_token=100
    m.unlock_hero("runenpaladin");m.select_hero("runenpaladin");m.acquire_companion("skyfox");m.select_companion("skyfox");m.economy_command("shop","harvest_pet",m.Economy.nonce(m.profile))
    m.economy_command("shop","harvest_wings",m.Economy.nonce(m.profile));m.change_gear("harvest_wings");m.player_hp=m.player_max_hp
    scene.model=m;scene.hud.model=m;scene._last_visual_key="";scene._sync_hero();scene._refresh()
    for size in [Vector2i(360,800),Vector2i(720,1280),Vector2i(720,1560),Vector2i(1280,720)]:
        root.size=size;await process_frame;scene._layout();scene._on_hud_action("Mehr");scene._refresh();scene.hud.toast_until=0
        for index in 4:
            scene._open_rpg_hub(index);await capture(["shop","forge","activities","journey"][index]+"-%dx%d"%[size.x,size.y]);await close_dialogs()
        scene._on_hud_action("Wesen");scene._on_hud_action("roster");await capture("roster-%dx%d"%[size.x,size.y]);await close_dialogs()
    root.size=Vector2i(720,1560);await process_frame;scene._layout()
    m.start_activity("harvest_abbey");scene._on_hud_action("Kampf");scene._consume_events();scene._refresh();scene.hud.toast_until=0
    await capture("harvest-pumpkin")
    m.encounter=1;m._spawn();scene._show_encounter();scene._refresh();scene.hud.toast_until=0;await capture("harvest-shadow")
    m.encounter=4;m._spawn();scene._show_encounter();scene._refresh();scene.hud.toast_until=0;await capture("harvest-king")
    for pose in m.Roster.playable_catalog():
        m.select_hero(pose);scene._last_visual_key="";scene._sync_hero()
        for state in scene.hero.Gate.HERO_STATES:
            scene.hero._set_pose(state);await capture(pose+"-"+state)
    scene.queue_free();await process_frame;quit()

extends SceneTree
const Scene=preload("res://scenes/main.tscn")
const Session=preload("res://scripts/systems/combat_session.gd")
const QA=preload("res://scripts/systems/admin_qa.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func settle():
    for i in 5:await process_frame
func _initialize():call_deferred("run")
func run():
    var scene=Scene.instantiate();root.add_child(scene);scene.set_process(false);scene.auto_enabled=false;scene.audio.enabled=false
    scene.model=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());scene.hud.model=scene.model
    for op in ["gold","shards","level","world"]:QA.apply(scene.model,op)
    scene.model.unlock_hero("runenpaladin");scene._sync_hero();scene._refresh()
    for viewport in [Vector2i(360,800),Vector2i(390,844),Vector2i(720,1280),Vector2i(1280,720)]:
        root.size=viewport;await settle();scene.model.start_stage("wolkgarten",4);scene._show_encounter();scene._layout()
        var enemy_height=scene.enemy.STANDING.golem.size.y*scene.enemy.scale.y
        check(enemy_height>420 and enemy_height<670,"boss keeps authored height on "+str(viewport))
        check(scene.enemy.position.y==0 and scene.hero.position.y==0,"actors share the floor on "+str(viewport))
        check(scene.enemy.position.x>scene.hero.position.x,"boss stays on the right")
        scene._on_hud_action("Wesen");await settle();var page=scene.hud.collection_page
        check(page.is_visible_in_tree() and not scene.hud.shell_scroll.visible,"collection is the actual page")
        var before=scene.model.run_id;var hp=scene.model.enemy_hp
        scene._on_hud_action("hero_select:runenpaladin")
        check(scene.model.hero_id=="runenpaladin" and scene.model.run_id==before and scene.model.enemy_hp==hp,"UI hero switch preserves live encounter")
        check(page.position.y+page.size.y<scene.hud.buttons.Kampf.position.y,"collection clears fixed navigation")
        scene._on_hud_action("hero_select:realmwachter")
    scene.model.change_gear("astral_plate","acquire");scene.model.change_gear("astral_plate");scene._sync_hero()
    for pose in scene.hero.Gate.HERO_STATES:
        scene.hero._set_pose(pose)
        check(scene.hero._body.texture.resource_path.contains("work704/guardian_astral/"),"full worn armor "+pose)
        check(not scene.hero.attachments.plate.visible and scene.hero.weapon_is_modular(),"inventory picture cannot cover torso "+pose)
        check(scene.hero._socket.position==scene.hero.hand(pose)-scene.hero.PIVOT,"outfit fist and independent sword match "+pose)
    scene.hero.revive();scene._on_hud_action("Kampf");scene.model.behavior.deadline=10000;scene.model.enemy_hp=100000;scene.model.enemy_max_hp=100000;scene.auto_enabled=true;scene._auto_clock=0
    var sequence=scene.model.action_sequence
    for i in 30:scene._process(.05)
    check(scene.model.action_sequence-sequence>=1 and scene.model.action_sequence-sequence<=2,"AUTO has a readable cadence while still attacking")
    scene._on_hud_action("Mehr");await settle()
    for id in ["quests","events","journey","economy","activities","more_forge","more_heroes","more_pets","more_talents"]:check(scene.hud.buttons[id].is_visible_in_tree(),"real menu tile "+id)
    scene.queue_free();await settle();print("Mockup 704: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)

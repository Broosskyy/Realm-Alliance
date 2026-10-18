extends SceneTree
const QA=preload("res://scripts/systems/admin_qa.gd")
const Scene=preload("res://scenes/main.tscn")
const Save=preload("res://scripts/save_store.gd")
var checks=0
var failures=0

func check(ok:bool,description:String) -> void:
    checks+=1
    if not ok:
        failures+=1
        push_error("FAIL QA: "+description)

func _initialize() -> void:
    call_deferred("run")

func run() -> void:
    check(QA.enabled(),"QA tools available in test/debug export")
    var scene=Scene.instantiate()
    root.add_child(scene)
    await process_frame
    scene.auto_enabled=false
    scene._on_hud_action("Mehr")
    check(scene.hud.buttons.admin.visible and scene.hud.buttons.admin.size.y*float(preload("res://scripts/combat_layout.gd").solve(Vector2i(360,800)).ui_scale)>=44,"QA access is visible and has physical 44px touch target")
    var original=scene.model
    var snapshot=original.snapshot()
    scene._on_hud_action("admin")
    check(scene._qa_active and scene.model!=original and scene.hud.qa_mode,"QA uses separate in-memory CombatSession")
    var dialog
    for child in scene.get_children():
        if child is RAAdminQADialog:dialog=child
    check(dialog!=null,"working QA dialog opened")
    if dialog!=null:dialog.operation_requested.emit("showcase")
    check(scene.model.hero_id=="realmwachter" and scene.model.profile.companions.active=="skyfox","showcase activates guardian and fox")
    scene._on_hud_action("Wesen")
    check(scene.hero.hero_id=="realmwachter" and scene.hud.preview.hero_id=="realmwachter","canonical guardian appears in arena and Wesen preview")
    scene._on_hud_action("Mehr")
    check(scene.model.hero_level>=12 and scene.model.World.can_enter(scene.model.profile,"glutkern",4),"QA bypasses grind only in its sandbox")
    var pet_before=scene.model.Companions.strength(scene.model.profile,"skyfox")
    if dialog!=null:dialog.operation_requested.emit("evolve")
    check(int(scene.model.profile.companions.owned.skyfox.evolution)==1 and scene.model.Companions.strength(scene.model.profile,"skyfox")>pet_before,"QA demonstrates evolved companion with real combat stats")
    var gold=scene.model.gold
    if dialog!=null:dialog.operation_requested.emit("gold")
    check(scene.model.gold>=gold+10000,"QA currency action changes sandbox")
    if dialog!=null:dialog.operation_requested.emit("boss")
    check(scene.model.encounter==4 and scene.model.enemy_definition.kind=="boss","QA enters real boss encounter")
    scene._persist()
    var disk=Save.load_state()
    var persisted:Dictionary=disk.get("profile",{})
    var expected:Dictionary=snapshot.profile
    check(int(persisted.get("gold",-1))==int(expected.gold) and int(persisted.get("shards",-1))==int(expected.shards) and int(persisted.get("xp",-1))==int(expected.xp),"QA never saves test currencies or XP")
    var on_disk_hero:Dictionary=persisted.get("hero_roster",{})
    var real_hero:Dictionary=expected.get("hero_roster",{})
    var on_disk_pets:Dictionary=persisted.get("companions",{})
    var real_pets:Dictionary=expected.get("companions",{})
    check(str(on_disk_hero.get("active",""))==str(real_hero.get("active","")) and on_disk_hero.get("owned",{}).size()==real_hero.get("owned",{}).size() and not on_disk_hero.get("owned",{}).has("kaela"),"QA cannot persist a Kaela hero unlock")
    check(str(on_disk_pets.get("active",""))==str(real_pets.get("active","")) and on_disk_pets.get("owned",{}).size()==real_pets.get("owned",{}).size() and not on_disk_pets.get("owned",{}).has("skyfox"),"QA cannot persist test pets or evolution")
    var saved_stars:Dictionary=persisted.get("world_progress",{}).get("stars",{})
    var real_stars:Dictionary=expected.get("world_progress",{}).get("stars",{})
    check(saved_stars.size()==real_stars.size() and saved_stars.get("glutkern:4",0)==real_stars.get("glutkern:4",0),"QA stage unlocks never reach the real save")
    check(str(disk.get("checkpoint",{}).get("region",""))==str(snapshot.checkpoint.region) and int(disk.get("checkpoint",{}).get("encounter",-1))==int(snapshot.checkpoint.encounter),"QA boss encounter never reaches the real checkpoint")
    check(not scene._apply_import(),"import cannot overwrite normal save from QA")
    if dialog!=null:dialog.operation_requested.emit("leave")
    check(not scene._qa_active and scene.model==original and not scene.hud.qa_mode,"leaving restores exact original in-memory session")
    check(scene.model.snapshot()==snapshot,"original inventory, region and combat state preserved")
    scene.queue_free()
    await process_frame
    print("Admin QA: %d/%d checks"%[checks-failures,checks])
    quit(1 if failures>0 else 0)

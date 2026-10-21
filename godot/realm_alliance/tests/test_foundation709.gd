extends SceneTree
const Session=preload("res://scripts/systems/combat_session.gd")
const Fixture=preload("res://tests/legacy_fixture709.gd")
const Scene=preload("res://scenes/main.tscn")
var checks=0
var failures=0
func check(ok:bool,label:String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func _initialize():call_deferred("run")
func run():
    var fresh=Session.new()
    check(not fresh.read_only and fresh.hero_id=="runenpaladin","fresh session starts with actual Runenpaladin")
    check(fresh.profile.hero_roster.owned.size()==1 and not fresh.profile.hero_roster.owned.has("realmwachter"),"legendary guardian is not a free starter")
    check(fresh.Mastery.rarity(fresh.profile,"runenpaladin")=="common","starter begins at normal rarity")
    check(fresh.Roster.catalog().realmwachter.unlock_level>fresh.Roster.catalog().schattenjager.unlock_level,"legendary guardian has later progression gate")
    check(not fresh.unlock_hero("realmwachter"),"fresh player cannot unlock legendary hero")
    fresh.gold=1000;fresh.profile.economy.materials.forge_dust=100
    check(fresh.train_hero("runenpaladin") and not fresh.read_only,"single Runenpaladin training works without guardian record")
    var store=preload("res://scripts/save_store.gd")
    check(store.save_state(fresh.snapshot()),"new starter saves through actual atomic writer")
    check(Session.new(store.load_state()).hero_id=="runenpaladin","new starter loads from real saved file")
    var saved=Session.new(JSON.parse_string(JSON.stringify(fresh.snapshot())))
    check(saved.hero_id=="runenpaladin" and not saved.read_only,"new starter survives disk-format roundtrip")
    var legacy=Session.new(Fixture.guardian());legacy.profile.xp=440;legacy.gold=321;legacy.profile.shards=17;legacy.player_hp=80;legacy.enemy_hp=41;var run_id=legacy.run_id;var account=legacy.profile.xp
    check(legacy.Roster.can_adopt_starter(legacy.profile),"old starter profile gets free transition")
    check(legacy.adopt_starter() and legacy.hero_id=="runenpaladin","transition activates actual Runenpaladin")
    check(legacy.gold==321 and legacy.profile.shards==17 and legacy.profile.xp==account,"transition never spends or changes account XP")
    check(legacy.Roster.xp(legacy.profile,"runenpaladin")==440 and legacy.Roster.xp(legacy.profile,"realmwachter")==440,"old earned XP retained for both preserved hero and new starter")
    check(legacy.enemy_hp==41 and legacy.run_id==run_id and legacy.player_hp<=80,"transition preserves run, opponent and cannot heal")
    check(not legacy.adopt_starter(),"transition cannot be repeated")
    var future=legacy.snapshot();future.profile.hero_roster.starter_revision=9
    check(Session.new(future).read_only,"unknown starter migration revision protects data")
    var natural=Session.new();natural.gold=1000;natural.profile.shards=100
    for i in 8000:
        if natural.outcome in ["victory","defeat"]:break
        for id in natural.SKILL_IDS:
            if natural.request_action(id):break
        natural.request_action();natural.tick(.05)
    check(natural.outcome=="victory","new starter naturally clears first region")
    check(natural.onward_region()=="glutkern","first region victory points to actual new world")
    var chest_count=natural.profile.chests.sealed.size()
    check(natural.continue_after_victory() and natural.region=="glutkern" and natural.encounter==0,"continue enters Glutkern instead of looping Wolkgarten")
    check(natural.profile.chests.sealed.size()==chest_count,"continuing cannot grant another boss chest")
    var scene=Scene.instantiate();scene.initial_creation_enabled=false;root.add_child(scene);scene.hud.collection_page.category="Helden";scene.set_process(false);scene.auto_enabled=false;scene.audio.enabled=false;scene._qa_active=true
    check(scene.model.hero_id=="runenpaladin" and scene.hero.hero_id=="runenpaladin","real first boot shows Runenpaladin in combat")
    scene.model=legacy;scene.hud.model=legacy;legacy.profile.hero_equipment.owned.sky_wings={"id":"sky_wings","level":1,"source":"test"};legacy.change_gear("sky_wings");scene._sync_hero();scene._on_hud_action("Wesen")
    var page=scene.hud.collection_page;page.detail="runenpaladin";page._reload();await process_frame;await process_frame
    var rigs=page.find_children("*","Node2D",true,false);var checked=false
    for rig in rigs:
        if rig is RAProductionHero:
            check(rig.attachments.wings.visible,"equipped wing texture present in collection rig")
            check(rig.z_index+rig.attachments.wing_mount.z_index>0,"wings render above zero-layer background")
            checked=true
    check(checked,"real collection preview was inspected")
    scene._open_gear_slot("wings");await process_frame;await process_frame
    var original=JSON.stringify(legacy.profile);var comparisons=scene.find_children("EquipmentComparisonHero","Node2D",true,false)
    check(comparisons.size()==2,"equipment page shows actual and candidate hero")
    for rig in comparisons:check(rig.z_index+rig.attachments.wing_mount.z_index>0,"comparison wings stay above background")
    check(JSON.stringify(legacy.profile)==original,"comparing equipment cannot mutate saved ownership or currency")
    scene.queue_free();await process_frame
    print("Foundation 709: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)

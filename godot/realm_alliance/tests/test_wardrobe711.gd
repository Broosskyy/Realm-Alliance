extends SceneTree
const Session=preload("res://scripts/systems/combat_session.gd")
const Wardrobe=preload("res://scripts/systems/wardrobe711.gd")
const Gear=preload("res://scripts/systems/hero_equipment.gd")
const Rig=preload("res://scripts/production_hero.gd")
const Legacy=preload("res://tests/legacy_fixture709.gd")
var checks=0
var failures=0
func check(ok:bool,label:String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func _initialize():call_deferred("run")
func run():
    var s=Session.new()
    check(not s.read_only and s.profile.wardrobe.owned.is_empty() and Wardrobe.active(s.profile)=="","fresh wardrobe is empty")
    check(not s.profile.has("character_identity"),"existing hero identity never converted")
    var pure={"custom":7};var before=JSON.stringify(pure)
    check(Wardrobe.active(pure)=="" and JSON.stringify(pure)==before,"query does not create a cosmetic domain")
    for id in Wardrobe.IDS:
        before=JSON.stringify(s.snapshot())
        check(not s.claim_costume(id) and JSON.stringify(s.snapshot())==before,"locked reward atomic "+id)
        check(not s.equip_costume(id) and JSON.stringify(s.snapshot())==before,"unowned costume atomic "+id)
    s.profile.kills=25;s.profile.best_wave=15;s.player_hp=31
    for id in Wardrobe.IDS:
        var gold=s.gold;var shards=s.profile.shards;var hp=s.player_hp;var power=s.power
        check(s.claim_costume(id),"free milestone claim "+id)
        check(s.gold==gold and s.profile.shards==shards and s.player_hp==hp and s.power==power,"claim has no stats, price or healing "+id)
        before=JSON.stringify(s.snapshot())
        check(not s.claim_costume(id) and JSON.stringify(s.snapshot())==before,"repeat claim atomic "+id)
        check(s.equip_costume(id) and Wardrobe.active(s.profile)==id,"equip owned costume "+id)
        check(s.gold==gold and s.profile.shards==shards and s.player_hp==hp and s.power==power,"equip purely cosmetic "+id)
        var loaded=Session.new(JSON.parse_string(JSON.stringify(s.snapshot())))
        check(not loaded.read_only and Wardrobe.active(loaded.profile)==id,"save roundtrip "+id)
        check(s.equip_costume("") and s.player_hp==hp and s.power==power,"remove purely cosmetic "+id)
    for bad in [null,[],true,{"schema":99,"owned":{},"active":""},{"schema":true,"owned":{},"active":""},{"schema":1,"owned":[],"active":""},{"schema":1,"owned":{},"active":"forest_path"},{"schema":1,"owned":{"unknown":{}},"active":""}]:
        var data=s.snapshot();data.profile.wardrobe=bad
        var loaded=Session.new(data)
        check(loaded.read_only,"invalid/future domain protected "+str(bad))
        before=JSON.stringify(loaded.snapshot())
        check(not loaded.claim_costume("forest_path") and not loaded.equip_costume("") and JSON.stringify(loaded.snapshot())==before,"protected save not rewritten")
        check(JSON.stringify(loaded.profile.wardrobe)==JSON.stringify(bad),"original invalid domain retained")
    var legacy=Session.new(Legacy.guardian())
    check(not legacy.read_only and legacy.profile.hero_roster.owned.has("realmwachter"),"legacy guardian retained")
    legacy.profile.wardrobe.custom={"keep":1};legacy.profile.wardrobe.owned.forest_path={"source":"legacy","custom":"keep"}
    var restored=Session.new(JSON.parse_string(JSON.stringify(legacy.snapshot())))
    check(not restored.read_only and restored.profile.wardrobe.custom.keep==1 and restored.profile.wardrobe.owned.forest_path.custom=="keep","unknown cosmetic metadata retained")
    for id in ["wander_leather","silver_guard"]:
        s=Session.new();s.profile.xp=440;s.gold=20000;s.profile.shards=2000
        var gold=s.gold;var shards=s.profile.shards;var d=Gear.CATALOG[id]
        check(s.change_gear(id,"acquire") and s.gold==gold-d.gold and s.profile.shards==shards-d.shards,"exact acquisition price "+id)
        before=JSON.stringify(s.snapshot())
        check(not s.change_gear(id,"acquire") and JSON.stringify(s.snapshot())==before,"duplicate purchase atomic "+id)
        s.player_hp=s.player_max_hp-12
        check(s.change_gear(id) and s.player_max_hp-s.player_hp==12,"equip preserves damage taken "+id)
        for level in range(1,11):
            check(Gear.item_level(s.profile,id)==level,"actual armor level "+id+str(level))
            var values=Gear.item_stats(s.profile,id)
            check(values.hp==d.hp+(level-1)*3 and values.defense==d.defense+level-1,"actual armor stats "+id+str(level))
            check(not Session.new(JSON.parse_string(JSON.stringify(s.snapshot()))).read_only,"armor saves remain valid")
            gold=s.gold;shards=s.profile.shards
            if level<10:
                check(s.change_gear(id,"upgrade") and gold-s.gold==25*level and shards-s.profile.shards==1,"upgrade cost "+id+str(level))
            else:
                before=JSON.stringify(s.snapshot())
                check(not s.change_gear(id,"upgrade") and JSON.stringify(s.snapshot())==before,"armor cap atomic")
    var hero=Rig.new();root.add_child(hero)
    for hero_id in ["runenpaladin","schattenjager","realmwachter"]:
        hero.set_hero(hero_id)
        for family in hero.wardrobe_visual.FAMILIES:
            s=Session.new()
            if family in Wardrobe.IDS:
                s.profile.wardrobe.owned[family]={};s.profile.wardrobe.active=family
            else:
                s.profile.hero_equipment.owned[family]={"level":5};s.profile.hero_equipment.equipped.chest=family
            hero.set_gear(s.profile)
            check(hero.wardrobe_visual.active_id==family and hero.wardrobe_visual.visible,"family visible "+hero_id+family)
            check(not hero.attachments.armor_details.visible,"legacy armor details suppressed")
            for pose in ["idle","ready","windup","attack_contact","recovery","hit"]:
                hero._set_pose(pose)
                check(hero.weapon_is_modular(),"independent weapon "+hero_id+family+pose)
                check(not hero._body.texture.resource_path.contains("outfit"),"base hero identity retained")
                for part in hero.wardrobe_visual.PARTS:
                    var mesh=hero.wardrobe_visual.pieces[part]
                    check(mesh.texture!=null and mesh.polygon.size()==4 and mesh.uv.size()==4,"textured part "+hero_id+family+pose+part)
            hero.fx_intensity=0;hero.set_upgrade_tier(8)
            check(is_zero_approx(float(hero.wardrobe_visual.cloth.get_shader_parameter("motion_strength"))),"actual settings path stops cloth "+family)
            hero.fx_intensity=1;hero.set_upgrade_tier(8)
            check(float(hero.wardrobe_visual.cloth.get_shader_parameter("motion_strength"))>0,"actual settings path restores cloth "+family)
        hero.set_gear(Session.new().profile)
        check(not hero.wardrobe_visual.visible,"removal restores base hero "+hero_id)
    var scene=preload("res://scenes/main.tscn").instantiate();root.add_child(scene)
    scene.set_process(false);scene.auto_enabled=false;scene.audio.enabled=false;scene._qa_active=true
    scene.model=Session.new();scene.hud.model=scene.model;scene._sync_hero()
    scene.model.profile.wardrobe.owned.forest_path={};scene.model.equip_costume("forest_path");scene._sync_hero()
    check(scene.hero.wardrobe_visual.active_id=="forest_path" and scene.hero.wardrobe_visual.visible,"main cache updates after equip")
    scene.model.equip_costume("");scene._sync_hero()
    check(not scene.hero.wardrobe_visual.visible,"main cache updates after removal")
    scene.queue_free();hero.queue_free();await process_frame
    print("Wardrobe 711: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)

extends SceneTree
const Session=preload("res://scripts/systems/combat_session.gd")
const Gear=preload("res://scripts/systems/hero_equipment.gd")
const Preview=preload("res://scripts/systems/equipment_preview707.gd")
const Appearance=preload("res://scripts/systems/character_appearance710.gd")
const Rig=preload("res://scripts/production_hero.gd")
var checks=0
var failures=0
func check(ok:bool,label:String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func _initialize():call_deferred("run")
func run():
    for id in ["sky_wings","harvest_wings"]:
        var s=Session.new()
        s.profile.hero_equipment.owned[id]={"id":id,"level":1,"source":"test"}
        check(s.change_gear(id),"owned wings equip "+id)
        var layouts=[]
        for plus in 16:
            check(Gear.plus(s.profile,id)==plus,"canonical plus "+id+str(plus))
            var values=Gear.item_stats(s.profile,id)
            check(values.hp==int(Gear.CATALOG[id].hp)+plus*3 and values.defense==int(Gear.CATALOG[id].defense)+plus,"real legacy-compatible values "+str(plus))
            var original=JSON.stringify(s.snapshot())
            var quote=Preview.gear(s.profile,id)
            check(JSON.stringify(s.snapshot())==original,"pure next-state preview "+str(plus))
            var layout=Gear.WingProgress.visual(plus)
            check(JSON.stringify(layout) not in layouts,"each of 16 visual states differs "+str(plus))
            layouts.append(JSON.stringify(layout))
            var restored=Session.new(JSON.parse_string(JSON.stringify(s.snapshot())))
            check(not restored.read_only and Gear.plus(restored.profile,id)==plus,"each state loads "+str(plus))
            if plus==15:
                s.gold=9999;s.profile.shards=999
                original=JSON.stringify(s.snapshot())
                check(quote.maximum and not s.change_gear(id,"upgrade"),"+15 is hard cap")
                check(JSON.stringify(s.snapshot())==original,"capped double tap does not charge")
            else:
                s.gold=int(quote.cost.gold)-1;s.profile.shards=int(quote.cost.shards)
                original=JSON.stringify(s.snapshot())
                check(not s.change_gear(id,"upgrade") and JSON.stringify(s.snapshot())==original,"insufficient funds are atomic "+str(plus))
                s.gold=int(quote.cost.gold)
                check(s.change_gear(id,"upgrade") and s.gold==0 and s.profile.shards==0,"exact quote charged "+str(plus))
                check(Gear.item_stats(s.profile,id)==quote.next,"next values match actual upgrade "+str(plus))
    var legacy=Session.new()
    legacy.profile.hero_equipment.owned.sky_wings={"level":10,"source":"legacy709","custom_note":"preserve"}
    var loaded=Session.new(legacy.snapshot())
    check(not loaded.read_only and Gear.plus(loaded.profile,"sky_wings")==9,"old level ten becomes +9 without reset")
    check(loaded.profile.hero_equipment.owned.sky_wings.custom_note=="preserve","unknown item metadata retained")
    for bad in [0,17,1.5,true,"3"]:
        var broken=legacy.snapshot();broken.profile.hero_equipment.owned.sky_wings.level=bad
        check(Session.new(broken).read_only,"invalid/future wing level protected "+str(bad))
    var future=legacy.snapshot();future.profile.hero_equipment.wing_revision=99
    check(Session.new(future).read_only,"future wing revision blocks writeback")
    legacy.profile.hero_equipment.owned.astral_plate={"level":10}
    check(Preview.gear(legacy.profile,"astral_plate").maximum,"armor cap unchanged")
    var hero=Rig.new();root.add_child(hero)
    for id in ["runenpaladin","schattenjager","realmwachter"]:
        hero.set_hero(id)
        for plus in [0,1,5,9,10,12,15]:
            legacy.profile.hero_equipment.owned.sky_wings.level=plus+1
            legacy.profile.hero_equipment.equipped.wings="sky_wings"
            hero.set_gear(legacy.profile)
            for pose in ["idle","ready","windup","attack_contact","recovery","hit"]:
                hero._set_pose(pose)
                check(hero.attachments.wings.visible and hero.attachments.wing_evolution.visible,"visible modular wings "+id+str(plus)+pose)
                check(hero.attachments.wing_evolution.plus==plus,"pose keeps wing stage")
        check(hero.weapon_is_modular(),"separate weapon retained "+id)
    hero.fx_intensity=0;hero.set_gear(legacy.profile)
    check(hero.attachments.wings.visible and not hero.attachments.wing_evolution.is_processing(),"effects off retains silhouette and stops animated wing highlights")
    legacy.profile.hero_equipment.owned.harvest_wings={"level":4}
    Gear.set_cosmetic(legacy.profile,"wings","harvest_wings");hero.set_gear(legacy.profile)
    check(hero.attachments.wing_evolution.plus==3,"cosmetic uses own visible wing stage")
    var stats=Gear.stats(legacy.profile)
    Gear.set_cosmetic(legacy.profile,"wings","");hero.set_gear(legacy.profile)
    check(not hero.attachments.wings.visible and not hero.attachments.wing_evolution.visible and stats==Gear.stats(legacy.profile),"hiding art retains actual combat values")
    var original=JSON.stringify(legacy.profile)
    for body in Appearance.BODY_VARIANTS:
        for color in Appearance.NATURAL_COLORS:
            var identity=Appearance.basic(body,color)
            check(Appearance.valid(identity),"future basic appearance contract "+body+color)
            check(identity.class_id=="adventurer" and identity.equipment_layers.is_empty(),"basic begins without invented class or gear")
    check(Appearance.basic("male","white").is_empty(),"special hair is not a free starter choice")
    check(JSON.stringify(legacy.profile)==original and not legacy.profile.has("character_identity"),"future architecture never converts existing saves")
    for armor in ["astral_plate","eclipse_plate"]:
        legacy.profile.hero_equipment.owned[armor]={"level":5}
        legacy.profile.hero_equipment.equipped.chest=armor
        for id in ["runenpaladin","schattenjager","realmwachter"]:
            hero.set_hero(id);hero.set_gear(legacy.profile)
            for pose in ["idle","ready","windup","attack_contact","recovery","hit"]:
                hero._set_pose(pose)
                check(hero.attachments.armor_details.visible==(id!="realmwachter"),"armor detail follows compatible body "+id+pose)
                check(hero.attachments.armor_details.corners.size()==4 and hero.weapon_is_modular(),"fitted armor preserves hand weapon "+pose)
    hero.fx_intensity=1;hero.set_upgrade_tier(8)
    check(hero.weapon_glow.refinement==8,"weapon refinement follows actual upgrade level")
    hero.fx_intensity=0;hero.set_upgrade_tier(8)
    check(not hero.weapon_glow.is_processing(),"effects off stops weapon motes")
    var scene=preload("res://scenes/main.tscn").instantiate();root.add_child(scene)
    scene.set_process(false);scene.auto_enabled=false;scene.audio.enabled=false;scene._qa_active=true
    legacy.profile.hero_equipment.cosmetics.erase("wings")
    legacy.profile.hero_equipment.owned.sky_wings.level=16
    scene.model=legacy;scene.hud.model=legacy;scene._sync_hero();scene._layout()
    check(scene.hero.scale.x>=.66,"large wings do not shrink main hero")
    check(scene.hero.position.x>-185,"large wings receive presentation space")
    check(scene.hero.attachments.wings.to_global(Vector2.ZERO).x>=0,"full max wing canvas stays inside combat left edge")
    scene.queue_free();await process_frame
    hero.queue_free();await process_frame
    print("Equipment 710: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)

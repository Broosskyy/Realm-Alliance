extends SceneTree
const Session=preload("res://scripts/systems/combat_session.gd")
const Scene=preload("res://scenes/main.tscn")
var checks=0
var failures=0
func check(ok:bool,label:String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func prepared():
    var m=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());m.profile.xp=1000;m.profile.gold=1000;m.profile.shards=100
    for region in ["wolkgarten","glutkern"]:
        for i in 5:m.World.clear_stage(m.profile,region,i,1)
    m.enemy_hp=100000;m.enemy_max_hp=100000;m.behavior.deadline=10000
    return m
func count(events:Array,kind:String) -> int:
    var value=0
    for e in events:
        if e.type==kind:value+=1
    return value
func _initialize():call_deferred("run")
func run():
    var m=Session.new({"version":1,"gold":777,"upgrade_level":3,"weapon_index":1,"total_kills":8})
    check(m.hero_id=="realmwachter" and m.profile.hero_roster.owned.size()==1,"legacy guardian retained, no fabricated collection")
    check(m.gold==777 and m.profile.inventory.crystal.level==4 and m.profile.companions.active=="","legacy resources/weapon upgrades unchanged")
    check(m.hero_level==m.level,"legacy guardian XP contract retained")
    check(not m.unlock_hero("kaela") and not m.acquire_companion("skyfox"),"unmet gates cannot be bypassed")
    for domain in ["hero_roster","companions"]:
        var state=m.snapshot();state.profile[domain].schema=2;var future=Session.new(state)
        check(future.read_only and not future.acquire_companion("skyfox"),"future domain protected "+domain)
    m=prepared()
    check(m.Roster.playable_catalog().has("realmwachter") and not m.Roster.playable_catalog().has("kaela"),"Kaela no longer appears as playable hero")
    check(not m.unlock_hero("kaela") and not m.select_hero("kaela"),"retired NPC cannot be purchased or selected")
    var legacy=m.snapshot()
    legacy.profile.hero_roster.owned.kaela={"xp":340,"source":"historical_unlock"}
    legacy.profile.hero_roster.active="kaela"
    legacy.profile.gold=810
    legacy.profile.shards=21
    legacy.checkpoint.region="glutkern"
    legacy.checkpoint.tier=1
    legacy.checkpoint.encounter=2
    legacy.checkpoint.clock=4.0
    legacy.checkpoint.player_hp=70
    legacy.checkpoint.enemy_hp=35
    var remapped=Session.new(JSON.parse_string(JSON.stringify(legacy)))
    check(not remapped.read_only and remapped.hero_id=="realmwachter","old Kaela active session loads as canonical guardian")
    check(remapped.gold==960 and int(remapped.profile.shards)==29 and bool(remapped.profile.hero_roster.kaela_compensated),"previous Kaela unlock compensated once")
    check(int(remapped.profile.hero_roster.owned.kaela.xp)==340 and remapped.profile.hero_roster.owned.kaela.source=="historical_unlock","Kaela XP and ownership archived losslessly")
    check(remapped.region=="glutkern" and remapped.tier==1 and remapped.encounter==2 and remapped.enemy_hp==35 and remapped.player_hp==70,"region, wave, enemy HP and hero HP survive Kaela migration")
    check(remapped.profile.equipped==legacy.profile.equipped and remapped.profile.inventory.size()==legacy.profile.inventory.size(),"migration preserves equipped item and inventory slots")
    for item_id in legacy.profile.inventory:
        check(remapped.profile.inventory.has(item_id) and int(remapped.profile.inventory[item_id].get("level",1))==int(legacy.profile.inventory[item_id].get("level",1)),"migration preserves inventory level "+str(item_id))
    check(remapped.profile.claims.size()==legacy.profile.claims.size(),"migration preserves reward-claim count")
    var again=Session.new(JSON.parse_string(JSON.stringify(remapped.snapshot())))
    check(not again.read_only and again.gold==960 and int(again.profile.shards)==29,"migration does not grant Kaela compensation twice")
    check(not again.select_hero("kaela") and again.Roster.catalog().has("kaela"),"Kaela art/data retained for future NPC but cannot return as hero")
    var hp:int=0
    var e:Array=[]
    m=prepared();check(m.acquire_companion("skyfox") and m.gold==960 and m.profile.shards==98,"real companion cost")
    var pet_run=m.run_id;var pet_wave=m.wave;var pet_enemy=m.enemy_hp
    check(not m.acquire_companion("skyfox") and m.select_companion("skyfox"),"single purchase and owned selection")
    check(m.run_id==pet_run and m.wave==pet_wave and m.enemy_hp==pet_enemy,"pet equip preserves run, stage and enemy health")
    # Test snapshots must carry a valid HP total. prepared() intentionally inflates
    # enemy HP for combat tests; old equip used to reset it, in-place equip does not.
    m.enemy_max_hp=int(m.enemy_definition.hp)
    m.enemy_hp=m.enemy_max_hp
    m.behavior.deadline=10000;m.drain_events();var before=m.enemy_hp;var momentum=m.momentum;var rage=m.rage
    m.tick(1.0/60);check(m.enemy_hp==before and not m.companion.pending.is_empty(),"pet attack has genuine windup")
    var saved=m.snapshot();var restored=Session.new(JSON.parse_string(JSON.stringify(saved)))
    check(not restored.read_only,"pending pet survives actual JSON numeric types")
    m.drain_events();restored.drain_events();m.tick(.34);restored.tick(.34)
    check(m.enemy_hp<before and restored.enemy_hp==m.enemy_hp and m.drain_events()==restored.drain_events(),"single deterministic contact after reload")
    check(m.momentum==momentum and m.rage==rage and m.tap.charge==0 and m.tap.combo==0 and m.hit_count==0,"pet cannot farm resources, crits or ultimate")
    before=m.enemy_hp;m.tick(2);check(m.enemy_hp==before,"pet interval enforced");m.tick(1);check(m.enemy_hp<before,"next attack after actual cooldown")
    m=prepared();m.acquire_companion("skyfox");m.select_companion("skyfox");m.enemy_hp=1;m.behavior.deadline=10000;m.drain_events();m.tick(.5);e=m.drain_events()
    check(m.profile.kills==1 and m.outcome=="breathe" and count(e,"reward")==1,"pet kill rewards once and starts transition")
    check(int(m.profile.companions.owned.skyfox.xp)==12,"equipped pet earns actual combat XP")
    for event in e:
        if event.type=="damage":check(event.actor_id=="companion:skyfox:local" and str(event.action_id).contains("companion:skyfox"),"independent actor/action identifiers")
    m.tick(.5);check(m.companion.pending.is_empty(),"pending actions cancelled across transitions")
    m=prepared();m.acquire_companion("sunbird");m.select_companion("sunbird")
    # The fixture raises XP directly after initialization, not through gameplay.
    # Hero switching no longer refills HP; start healer test at true max HP.
    m.player_hp=m.player_max_hp
    m.behavior.deadline=10000;m.drain_events();m.tick(1)
    check(m.companion.pending.is_empty() and count(m.drain_events(),"heal")==0,"healer waits at full health")
    m.player_hp=20;m.tick(1.0/60);check(m.player_hp==20,"heal not applied on activation");m.tick(.46)
    check(m.player_hp>20 and m.player_hp<=m.player_max_hp,"real delayed bounded healing")
    hp=m.player_hp;m.tick(2);check(m.player_hp==hp,"healing cooldown enforced")
    m.player_hp=1;m._enemy_strike(100,false);m.tick(10);check(m.outcome=="defeat" and m.player_hp==0,"healer cannot resurrect defeat")
    m=prepared();m.acquire_companion("skyfox");m.select_companion("skyfox");check(not m.evolve_companion("skyfox"),"evolution requires real training")
    m.profile.companions.owned.skyfox.xp=100;var strength=m.Companions.strength(m.profile,"skyfox");var gold=m.gold
    check(m.evolve_companion("skyfox") and m.gold==gold-100 and m.Companions.strength(m.profile,"skyfox")>strength,"evolution spends currency and increases effectiveness")
    check(not m.evolve_companion("skyfox"),"evolution cannot spend twice")
    var evolved_restored=Session.new(JSON.parse_string(JSON.stringify(m.snapshot())))
    check(not evolved_restored.read_only and str(evolved_restored.profile.companions.active)=="skyfox" and int(evolved_restored.profile.companions.owned.skyfox.evolution)==1,"active evolved companion survives JSON save/reload")
    check(evolved_restored.Companions.strength(evolved_restored.profile,"skyfox")==m.Companions.strength(m.profile,"skyfox"),"evolved companion strength survives reload")
    var post_reload_gold=evolved_restored.gold
    check(not evolved_restored.evolve_companion("skyfox") and evolved_restored.gold==post_reload_gold,"evolved companion cannot repurchase after reload")
    var future=m.snapshot();future.checkpoint.companion_runtime.schema=2;check(Session.new(future).read_only,"future companion runtime protected")
    future=m.snapshot();future.profile.companions.owned.skyfox.xp=1.5;check(Session.new(future).read_only,"fractional training counter rejected")
    m=prepared();m.acquire_companion("skyfox");m.select_companion("skyfox")
    var roster_restored=Session.new(JSON.parse_string(JSON.stringify(m.snapshot())))
    check(not roster_restored.read_only and roster_restored.hero_id=="realmwachter" and str(roster_restored.profile.companions.active)=="skyfox","guardian and equipped companion survive JSON save/reload")
    check(roster_restored.hero_level==m.hero_level and roster_restored.gold==m.gold,"hero training and currency survive reload")
    var scene=Scene.instantiate();root.add_child(scene);await process_frame
    scene.model=m;scene.hud.model=m;scene._sync_hero();scene.hud.active_tab="Wesen";scene.hud.update_buttons()
    check(scene.hero.hero_id=="realmwachter" and scene.hud.preview.hero_id=="realmwachter","combat arena and preview show canonical masked guardian")
    for pose in scene.hero.Gate.HERO_STATES:
        scene.hero._set_pose(pose)
        for sword in 5:
            scene.hero.equip_weapon(sword)
            check(scene.hero.weapon_is_modular() and scene.hero._weapon.texture!=null and scene.hero._socket.z_index>3,"masked guardian holds separate weapon "+pose+str(sword))
    for size in [Vector2(360,800),Vector2(720,1280),Vector2(720,1560),Vector2(1280,720)]:
        var metrics=preload("res://scripts/combat_layout.gd").solve(size);scene.hud.configure(metrics.logical_height);scene.hud.update_buttons()
        check(scene.hud.buttons.roster.size.y*float(metrics.ui_scale)>=44,"collection has physical touch target "+str(size))
    var pet=scene.companion_visual;pet.sync(m.profile,10);var texture=pet.sprite.texture;m.profile.companions.owned.skyfox.evolution=1;pet.sync(m.profile,10)
    check(texture!=pet.sprite.texture,"actual evolved multi-tail sprite swapped")
    scene._on_hud_action("Wesen")
    check(scene.hud.buttons.roster.visible and scene.hud.buttons.roster.position.y<230,"Wesen has visible prominent roster button")
    scene.hud.buttons.roster.pressed.emit()
    var entered=false
    for child in scene.get_children():
        if child is RARosterDialog:
            entered=child.tabs.get_tab_count()==2
            child.queue_free()
    check(entered,"tapping Wesen roster action opens both collection tabs")
    var dialog=preload("res://scripts/ui/roster_dialog.gd").new();scene.add_child(dialog);dialog.configure(m);check(dialog.tabs.get_tab_count()==2,"collection has two real content tabs")
    scene.queue_free();await process_frame
    print("Roster/Pets 6.7: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)

extends SceneTree
const Session=preload("res://scripts/systems/combat_session.gd")
const Scene=preload("res://scenes/main.tscn")
var checks=0
var failures=0
func check(ok:bool,label:String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func prepared():
    var m=Session.new();m.profile.xp=1000;m.profile.gold=1000;m.profile.shards=100
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
    m=prepared();var old_damage=m.hero_damage();var xp=m.profile.xp
    check(m.unlock_hero("kaela") and m.gold==850 and m.profile.shards==92,"actual hero cost deducted once")
    check(not m.unlock_hero("kaela") and m.gold==850,"duplicate hero acquisition rejected")
    check(m.hero_id=="realmwachter" and m.Roster.xp(m.profile,"realmwachter")==xp,"unlock does not silently switch hero")
    m.request_basic();m.tick(.1);var old_run=m.run_id
    check(m.select_hero("kaela"),"owned hero selection accepted")
    check(m.clock==0 and m.run_id!=old_run and m.pending.is_empty() and m.enemy_hp==m.enemy_max_hp and m.player_hp==m.player_max_hp,"switch resets run; no mid-boss healing exploit")
    check(m.hero_level==1 and m.profile.xp==xp and m.hero_damage()<old_damage and m.player_max_hp>=188 and m.defense>=3,"independent training and actual tank stats")
    check(m.skills.definitions.sky_blade.name=="Runenstoß" and m.skills.definitions.guardian_wall.cooldown==7.5,"distinct real skill definitions")
    m.player_hp=80;m.momentum=100;m.behavior.deadline=10000
    check(m.request_action("guardian_wall"),"rune bastion cast")
    m.tick(.02);var hp=m.player_hp;m._enemy_strike(1,false);var e=m.drain_events()
    check(m.player_hp>hp and count(e,"heal")==1,"true shield block heals Kaela")
    m.hero_status.active.clear();hp=m.player_hp;m._enemy_strike(1,false)
    check(m.player_hp<hp and count(m.drain_events(),"heal")==0,"unblocked hit does not fake healing")
    var guardian_xp=m.Roster.xp(m.profile,"realmwachter");m.enemy_hp=1;m.pending.clear();m.busy_until=m.clock;m.request_basic();m.tick(.6)
    check(m.Roster.xp(m.profile,"kaela")>0 and m.Roster.xp(m.profile,"realmwachter")==guardian_xp and m.profile.xp>xp,"only active hero trains; account XP also advances")
    var kaela_xp=m.Roster.xp(m.profile,"kaela");m.select_hero("realmwachter")
    check(m.Roster.xp(m.profile,"kaela")==kaela_xp and m.hero_damage()==old_damage,"switch retains individual XP and guardian power")
    m=prepared();check(m.acquire_companion("skyfox") and m.gold==960 and m.profile.shards==98,"real companion cost")
    check(not m.acquire_companion("skyfox") and m.select_companion("skyfox"),"single purchase and owned selection")
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
    m=prepared();m.acquire_companion("sunbird");m.select_companion("sunbird");m.behavior.deadline=10000;m.drain_events();m.tick(1)
    check(m.companion.pending.is_empty() and count(m.drain_events(),"heal")==0,"healer waits at full health")
    m.player_hp=20;m.tick(1.0/60);check(m.player_hp==20,"heal not applied on activation");m.tick(.46)
    check(m.player_hp>20 and m.player_hp<=m.player_max_hp,"real delayed bounded healing")
    hp=m.player_hp;m.tick(2);check(m.player_hp==hp,"healing cooldown enforced")
    m.player_hp=1;m._enemy_strike(100,false);m.tick(10);check(m.outcome=="defeat" and m.player_hp==0,"healer cannot resurrect defeat")
    m=prepared();m.acquire_companion("skyfox");m.select_companion("skyfox");check(not m.evolve_companion("skyfox"),"evolution requires real training")
    m.profile.companions.owned.skyfox.xp=100;var strength=m.Companions.strength(m.profile,"skyfox");var gold=m.gold
    check(m.evolve_companion("skyfox") and m.gold==gold-100 and m.Companions.strength(m.profile,"skyfox")>strength,"evolution spends currency and increases effectiveness")
    check(not m.evolve_companion("skyfox"),"evolution cannot spend twice")
    var future=m.snapshot();future.checkpoint.companion_runtime.schema=2;check(Session.new(future).read_only,"future companion runtime protected")
    future=m.snapshot();future.profile.companions.owned.skyfox.xp=1.5;check(Session.new(future).read_only,"fractional training counter rejected")
    m=prepared();m.unlock_hero("kaela");m.select_hero("kaela");m.acquire_companion("skyfox");m.select_companion("skyfox")
    var scene=Scene.instantiate();root.add_child(scene);await process_frame;scene.model=m;scene.hud.model=m;scene._sync_hero();scene.hud.active_tab="Wesen";scene.hud.update_buttons()
    check(scene.hero.hero_id=="kaela" and scene.hud.preview.hero_id=="kaela","combat and preview show actual active hero")
    for pose in scene.hero.Gate.HERO_STATES:
        scene.hero._set_pose(pose);var pixels=scene.hero._body.texture.get_image()
        check(pixels.get_pixelv(Vector2i(scene.hero.hand(pose))).a>.1,"fist socket intersects actual opaque art "+pose)
        for sword in 5:
            scene.hero.equip_weapon(sword)
            check(scene.hero.weapon_is_modular() and scene.hero._weapon.texture!=null and scene.hero._socket.z_index>3,"separate visible sword "+pose+str(sword))
    check(not scene.hero.cape.cloth.visible and scene.hero._palette.get_shader_parameter("split_cape")==false,"alternate short cape excludes guardian-only masks")
    for size in [Vector2(360,800),Vector2(720,1280),Vector2(720,1560),Vector2(1280,720)]:
        var metrics=preload("res://scripts/combat_layout.gd").solve(size);scene.hud.configure(metrics.logical_height);scene.hud.update_buttons()
        check(scene.hud.buttons.roster.size.y*float(metrics.ui_scale)>=44,"collection has physical touch target "+str(size))
    var pet=scene.companion_visual;pet.sync(m.profile,10);var texture=pet.sprite.texture;m.profile.companions.owned.skyfox.evolution=1;pet.sync(m.profile,10)
    check(texture!=pet.sprite.texture,"actual evolved multi-tail sprite swapped")
    var dialog=preload("res://scripts/ui/roster_dialog.gd").new();scene.add_child(dialog);dialog.configure(m);check(dialog.tabs.get_tab_count()==2,"collection has two real content tabs")
    scene.queue_free();await process_frame
    print("Roster/Pets 6.7: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)

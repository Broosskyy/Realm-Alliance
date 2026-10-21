extends SceneTree
const Session=preload("res://scripts/systems/combat_session.gd")
const Buffer=preload("res://scripts/combat_input_buffer.gd")
const Scene=preload("res://scenes/main.tscn")
var checks=0
var failures=0
func check(ok: bool,label: String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func prepared():
    var m=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());m.profile.xp=1000
    for i in 5:m.World.clear_stage(m.profile,"wolkgarten",i,1)
    m.enemy_hp=100000;m.enemy_max_hp=100000;m.behavior.deadline=10000;m.momentum=0;m.rage=0
    return m
func damage(events: Array) -> int:
    var sum=0
    for e in events:
        if e.type=="damage":sum+=int(e.amount)
    return sum
func count(events: Array,type: String) -> int:
    var total=0
    for e in events:
        if e.type==type:total+=1
    return total
func _initialize():call_deferred("run")
func run():
    var m=Session.new(preload("res://tests/legacy_fixture709.gd").guardian())
    check(m.profile.combat_mastery.schema==1 and m.Tap.mode(m.profile)==1,"old saves gain additive default mastery")
    check(not m.profile.combat_mastery.auto_enabled and m.profile.combat_mastery.auto_skills.is_empty(),"AUTO skills opt out by default")
    check(not m.select_hit_mode(2) and not m.select_hit_mode(4) and not m.select_hit_mode(3),"modes enforce actual gates and catalogue")
    m.profile.xp=180
    check(not m.select_hit_mode(2),"XP alone cannot replace elite objective")
    m.World.clear_stage(m.profile,"wolkgarten",2,1)
    check(m.select_hit_mode(2),"x2 level 3 plus elite unlock")
    check(not m.select_hit_mode(4),"x4 remains gated")
    m.profile.xp=1000;m.World.clear_stage(m.profile,"wolkgarten",4,1)
    check(m.select_hit_mode(4),"x4 level 6 plus boss unlock")
    for mode in [1,2,4]:
        m=prepared();check(m.select_hit_mode(mode),"select unlocked mode "+str(mode));var hp=m.enemy_hp
        check(m.request_basic(),"real basic accepted "+str(mode));check(m.enemy_hp==hp,"no damage on input "+str(mode))
        m.tick(.1833333333333);check(m.enemy_hp==hp,"no premature first contact "+str(mode))
        m.tick(1.0/60);var first=m.drain_events();check(count(first,"damage")==1,"exact first contact "+str(mode))
        check(not m.request_basic(),"attack speed blocks overlap "+str(mode))
        m.tick(.3);var rest=m.drain_events()
        var expected=int(round(m.hero_damage()*{1:1.0,2:1.25,4:1.6}[mode]))
        check(count(first,"damage")+count(rest,"damage")==mode,"scheduled contact count "+str(mode))
        check(hp-m.enemy_hp==expected,"bounded total integer damage budget "+str(mode))
        check(m.momentum==9 and m.rage==7 and m.tap.charge==12,"one resource/charge grant per action "+str(mode))
        check(m.tap.combo==mode,"actual contact combo "+str(mode))
    m=prepared();m.enemy_hp=85;m.enemy_max_hp=85;m.select_hit_mode(4);m.request_basic();m.tick(.2)
    var saved=m.snapshot();var restored=Session.new(saved)
    check(restored.snapshot()==saved,"partial multihit save is lossless")
    m.drain_events();restored.drain_events();m.tick(.4);restored.tick(.4)
    check(m.snapshot()==restored.snapshot(),"remaining contacts resume exactly once")
    check(m.drain_events()==restored.drain_events(),"resumed damage IDs/order are deterministic")
    var json_round=Session.new(JSON.parse_string(JSON.stringify(saved)))
    check(not json_round.read_only and json_round.Tap.mode(json_round.profile)==4,"real JSON numeric types preserve valid mastery")
    json_round.tick(.4);check(json_round.enemy_hp==m.enemy_hp,"JSON reload resumes remaining contact damage")
    m=prepared();m.select_hit_mode(4);m.request_basic();m.tick(.2);m.select_hit_mode(1);m.tick(.4)
    check(m.tap.combo==4,"changing selected mode cannot change a pending action")
    m=prepared();var amounts=[];var variants=[]
    for i in 3:
        m.request_basic();variants.append(m.pending.definition.animation);m.tick(.7);amounts.append(damage(m.drain_events()))
    check(amounts[2]>amounts[1] and amounts[1]>=amounts[0],"three-step chain has an earned finisher")
    check(variants==["chain_0_1","chain_1_1","chain_2_1"],"three independently identified motions")
    m.tick(1.8);m.request_basic();check(m.pending.definition.chain_step==0,"inactivity resets chain")
    m=prepared();m.select_hit_mode(4);m.profile.inventory.crystal={"id":"crystal","level":1,"rarity":"rare"};m.equip("crystal")
    var crit_actions=0
    for i in 4:
        m.request_basic();m.tick(.8);var events=m.drain_events();var crits=0
        for e in events:
            if e.type=="damage" and e.critical:crits+=1
        if crits>0:crit_actions+=1;check(crits==4,"crit applies to all scheduled pieces of one action")
    check(m.hit_count==4 and crit_actions==1,"four contacts do not quadruple crit rolls")
    m=prepared();m.select_hit_mode(4);m.enemy_hp=1;m.request_basic();m.tick(.2);var reward_events=m.drain_events()
    check(m.pending.is_empty() and m.outcome=="breathe" and count(reward_events,"reward")==1,"lethal first contact cancels surplus and rewards once")
    m.tick(1);check(m.enemy_hp==m.enemy_max_hp and m.tap.combo==0,"cancelled contacts never damage new spawn")
    m=prepared();m.select_hit_mode(4);m.request_basic();m.tick(.2);m.player_hp=1;m._enemy_strike(100,false);m.tick(1)
    check(m.outcome=="defeat" and m.pending.is_empty(),"defeat cancels remaining contacts")
    m=prepared();var buffer=Buffer.new();check(buffer.request_tap(m)==Buffer.CAST,"manual tap starts real attack")
    check(buffer.request_tap(m)==Buffer.QUEUED and buffer.request_tap(m)==Buffer.REJECTED,"only one bounded tap intent")
    m.momentum=100;check(buffer.request(m,1)==Buffer.QUEUED and not buffer.tap_pending,"explicit skill takes input priority")
    m.tick(.5);check(buffer.drain(m) and m.pending.definition.id=="arcane_eye","buffered skill is actually accepted")
    buffer.clear();check(buffer.is_empty(),"menu/spawn clear every manual intent")
    m=prepared()
    check(not m.configure_auto_skills(true,["unknown"]) and not m.configure_auto_skills(true,["sky_blade","sky_blade"]),"AUTO catalogue rejects unknown or duplicate IDs")
    m.read_only=true;check(not m.configure_auto_skills(true,["sky_blade"]),"protected saves reject AUTO setting mutations")
    var malformed=prepared().snapshot();malformed.checkpoint.tap_combat=[]
    check(Session.new(malformed).read_only,"malformed checkpoint is protected without a script crash")
    m=prepared();m.momentum=100;m.rage=100
    check(not m.request_auto_skill(),"default AUTO never spends skills")
    m.profile.combat_mastery.auto_enabled=true;m.profile.combat_mastery.auto_skills=["arcane_eye"]
    m.momentum=59;check(not m.request_auto_skill(),"AUTO obeys advertised reserve")
    m.momentum=60;check(m.request_auto_skill() and m.momentum==35,"explicit AUTO policy spends real cost once")
    m.tick(1);check(not m.request_auto_skill(),"AUTO cannot duplicate active mark")
    m=prepared();check(not m.request_action("ultimate"),"ultimate needs real charge")
    for i in 9:m.request_basic();m.tick(.8);m.drain_events()
    check(m.tap.charge==100,"charge earned through completed attacks")
    var hp=m.enemy_hp;check(m.request_action("ultimate") and m.tap.charge==0,"explicit ultimate consumes charge once")
    m.tick(.5333333333);check(m.enemy_hp==hp,"ultimate has real charge-up timing")
    m.tick(1.0/60);check(m.enemy_hp<hp and count(m.drain_events(),"damage")==1,"ultimate contact resolves once")
    m.tap.charge=100;m.tick(1);check(not m.request_action("ultimate"),"ultimate cooldown cannot be bypassed by charge")
    m=prepared();m.tap.charge=100;m.request_basic();buffer=Buffer.new()
    check(buffer.request_ultimate(m)==Buffer.QUEUED and m.tap.charge==100,"AUTO recovery cannot swallow ultimate or spend early")
    m.tick(.5);check(buffer.drain(m) and m.tap.charge==0 and m.pending.definition.id=="ultimate","buffered ultimate starts at real readiness")
    m=prepared();m.start_stage("wolkgarten",4);m.enemy_hp=100000;m.enemy_max_hp=100000;m.player_hp=m.player_max_hp
    m.boss.meter=9;m.behavior.state="windup";m.behavior.deadline=.23;m.request_basic();m.tick(.5)
    check(m.clock<m.boss.break_until and m.player_hp==m.player_max_hp,"real armor break interrupts upcoming boss hit")
    check(m.behavior.state=="idle" and not m.behavior.second,"break clears multi-strike telegraph state")
    var phase_events=m.drain_events();check(count(phase_events,"boss_phase")==1,"break cue emitted once")
    var no_contact=m.boss.meter;m._damage_enemy(1,"burn",false);check(m.boss.meter==no_contact,"burn ticks cannot farm stagger")
    m.tick(2);m.enemy_hp=40000;m.tick(.05);check(m.boss.enraged,"half-health phase is real state")
    check(count(m.drain_events(),"boss_phase")==1,"enrage cue emitted once")
    m.tick(.1);check(count(m.drain_events(),"boss_phase")==0,"phase does not flash every tick")
    var data=m.snapshot();data.profile.combat_mastery.schema=9;var unknown=data.profile.combat_mastery.duplicate(true);restored=Session.new(data)
    check(restored.read_only and restored.profile.combat_mastery==unknown,"future mastery protects original save")
    var scene=Scene.instantiate();scene.initial_creation_enabled=false;root.add_child(scene);scene.hud.collection_page.category="Helden";scene.set_process(false);scene.auto_enabled=false
    scene.model=prepared();scene.hud.model=scene.model
    scene.model.gold=10000;scene.model.profile.shards=100
    scene.model.change_gear("sky_wings","acquire");scene.model.change_gear("sky_wings")
    scene._sync_hero();scene._on_hud_action("Wesen");await process_frame
    for hero in [scene.hero,scene.hud.preview]:
        check(hero.cape.folded and hero.cape.cloth.visible,"real folded cape on both equipped rigs")
        for pose in hero.Gate.HERO_STATES:
            hero._set_pose(pose)
            var polygon=PackedVector2Array(hero.cape.SHAPES[pose])
            check(not Geometry2D.is_point_in_polygon(hero.HANDS[pose],polygon),"cape split preserves weapon hand "+pose)
            check(not Geometry2D.is_point_in_polygon(hero.VISUAL_SOCKETS[pose].head,polygon),"cape split preserves face "+pose)
            check(hero.cape.cloth.texture==hero._body.texture,"cape uses matching pose source "+pose)
            check(hero.attachments.wing_mount.z_index<hero.cape.cloth.z_index,"wings behind cape and body "+pose)
        hero.set_upgrade_tier(1);check(hero.weapon_glow.tier==1,"first upgrade has actual separate visible tier")
        hero.fx_intensity=0;hero.set_upgrade_tier(1);check(hero.weapon_glow.intensity==0,"upgrade VFX honour off setting")
    scene.model.change_gear("wings","unequip");scene._sync_hero();scene.hud.update_buttons()
    check(not scene.hero.cape.folded and not scene.hud.preview.cape.cloth.visible,"unequip restores original full cape")
    for v in [Vector2i(360,800),Vector2i(720,1280),Vector2i(720,1560),Vector2i(1280,720)]:
        root.size=v;await process_frame;scene._layout();scene._on_hud_action("Kampf");scene._refresh()
        var scale=root.get_final_transform().get_scale().x*scene.hud.scale.x
        for id in ["hit_mode","ultimate"]:check(scene.hud.buttons[id].size.y*scale>=44 and scene.hud.buttons[id].size.x*scale>=44,"new combat controls are real touch targets "+id+str(v))
        var local_floor=(scene._stage_home.y-scene.hud.position.y)/scene.hud.scale.x
        check(local_floor<scene.hud.buttons.hit_mode.position.y,"new controls do not cover actor ground line "+str(v))
    scene.vfx.status.mark=true;scene.vfx.status.intensity=0
    var status_clock=scene.vfx.status.clock;scene.vfx.status._process(1)
    check(scene.vfx.status.clock==status_clock,"effects off stops ambient status redraw clock")
    scene.queue_free();await process_frame
    print("Tap Combat 6.6: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)

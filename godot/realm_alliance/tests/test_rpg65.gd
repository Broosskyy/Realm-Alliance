extends SceneTree
const Session=preload("res://scripts/systems/combat_session.gd")
const Store=preload("res://scripts/save_store.gd")
const Inventory=preload("res://scripts/systems/inventory_view.gd")
var checks=0
var failures=0
func check(ok: bool,label: String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func play_run(m) -> bool:
    for i in 6000:
        if m.outcome=="victory":return true
        if m.outcome=="defeat":return false
        for id in m.SKILL_IDS:
            if m.request_action(id):break
        m.request_action();m.tick(.05)
    return false
func _initialize() -> void:
    if not OS.get_environment("XDG_DATA_HOME").begins_with("/tmp/realm62-test-"):
        push_error("Use isolated XDG_DATA_HOME=/tmp/realm62-test-rpg65");quit(1);return
    var m=Session.new(preload("res://tests/legacy_fixture709.gd").guardian())
    check(m.region=="wolkgarten" and m.World.can_enter(m.profile,"wolkgarten",0),"starter region and first stage are real")
    check(not m.start_stage("glutkern") and not m.start_stage("wolkgarten",1),"region/stage prerequisites enforced")
    check(not m.start_stage("missing") and not m.start_stage("wolkgarten",9),"invalid content cannot launch")
    check(m.World.stars(m.profile,"wolkgarten",0)==0 and m.profile.chests.sealed.is_empty(),"fresh save has no fabricated progress/chests")
    check(Inventory.items(m.profile).size()==1 and Inventory.items(m.profile)[0].id=="steel","fresh inventory contains only real starter sword")
    var original=m.snapshot();check(play_run(m),"natural first five-encounter run reaches victory")
    check(m.profile.kills==5 and m.profile.inventory.size()==5,"complete run grants all real weapon drops")
    for i in 5:check(m.World.stars(m.profile,"wolkgarten",i)>0,"actual clear persists stars "+str(i))
    check(m.World.unlocked(m.profile,"glutkern") and m.profile.chests.sealed.size()==1,"boss unlocks next region and grants one chest")
    var uid:String=m.profile.chests.sealed[0]
    check(not m.Chests.grant(m.profile,uid),"boss grant cannot duplicate a sealed UID")
    var before=m.snapshot();var reward=m.open_chest();var a=Session.new(before);var same=a.open_chest()
    check(not reward.is_empty() and reward==same,"chest reward is deterministic from its stable UID")
    check(m.gold==int(before.profile.gold)+int(reward.gold) and m.profile.shards==int(before.profile.shards)+int(reward.shards),"opening debits chest and credits exact resources")
    check(m.profile.chests.opened.has(uid) and m.profile.chests.sealed.is_empty(),"opened UID is retained across saves")
    var after=m.snapshot();check(m.open_chest().is_empty() and m.snapshot()==after,"opening empty inventory cannot repeat reward")
    check(not m.Chests.grant(m.profile,uid),"opened boss UID cannot be regranted")
    var resumed=Session.new(m.snapshot());check(resumed.profile.chests.opened.has(uid) and resumed.World.unlocked(resumed.profile,"glutkern"),"world and chest state round-trip")
    check(m.Quests.progress(m.profile,"first_five")==5 and m.Quests.progress(m.profile,"boss_hunter")==1,"real kills and boss feed quests")
    var gold=m.gold;check(m.claim_quest("first_five") and m.gold==gold+40,"quest gives exact one-time reward")
    gold=m.gold;check(not m.claim_quest("first_five") and m.gold==gold,"quest claim is idempotent")
    check(m.Quests.progress(m.profile,"sword_collector")==5 and m.claim_quest("sword_collector"),"achievement checks actual collection")
    check(not m.claim_quest("missing"),"unknown objective cannot grant resources")
    check(m.start_stage("glutkern"),"unlocked second region starts a real new run")
    check(m.enemy_definition.id=="ember_boar" and m.player_hp==m.player_max_hp,"new run has its own content and resets combat HP")
    check(play_run(m),"natural second-region run normal elite eruption boss reaches victory")
    check(m.profile.kills==10 and m.enemy_definition.id=="cinder_colossus","new encounters produce actual kills through boss")
    check(m.profile.chests.sealed.size()==1 and m.claim_quest("ten_stages"),"second boss chest and ten-stage achievement are real")
    var serial=m.run_id;check(m.start_stage("wolkgarten",4) and m.run_id!=serial,"replay uses unique run reward identity")
    check(m.encounter==4 and m.enemy_definition.kind=="boss","unlocked boss stage can be replayed directly")
    var previous=m.World.stars(m.profile,"wolkgarten",0)
    m.World.clear_stage(m.profile,"wolkgarten",0,.1);check(m.World.stars(m.profile,"wolkgarten",0)==previous,"lower replay score cannot erase best stars")
    m.World.clear_stage(m.profile,"glutkern",0,.85);check(m.World.stars(m.profile,"glutkern",0)==3,"three-star threshold is explicit")
    var old=Session.new(original);var legacy=old.snapshot()
    for domain in ["world_progress","skill_progress","quests","chests"]:legacy.profile.erase(domain)
    legacy.checkpoint.encounter=2
    var migrated=Session.new(legacy)
    check(not migrated.read_only and migrated.World.stars(migrated.profile,"wolkgarten",1)==1,"old checkpoint conservatively migrates cleared stages")
    check(migrated.World.stars(migrated.profile,"wolkgarten",2)==0 and migrated.profile.chests.sealed.is_empty(),"migration invents neither current clear nor chests")
    check(migrated.profile.inventory==legacy.profile.inventory and migrated.gold==int(legacy.profile.gold),"migration preserves actual equipment/currency")
    for domain in ["world_progress","skill_progress","quests","chests"]:
        var future=m.snapshot();future.profile[domain].schema=9
        var guarded=Session.new(future)
        check(guarded.read_only and guarded.profile[domain]==future.profile[domain],"future domain preserved "+domain)
        check(not guarded.start_stage("wolkgarten") and not guarded.upgrade_skill("sky_blade") and not guarded.claim_quest("boss_hunter") and guarded.open_chest().is_empty(),"future domain mutations blocked "+domain)
    for domain in ["world_progress","skill_progress","quests","chests"]:
        for malformed in [{},"future",1.5]:
            var bad=m.snapshot();bad.profile[domain].schema=malformed
            var protected=Session.new(bad)
            check(protected.read_only and protected.profile[domain]==bad.profile[domain],"malformed domain preserved "+domain+str(malformed))
    for field in ["levels","talents"]:
        var bad=m.snapshot();bad.profile.skill_progress[field]["sky_blade" if field=="levels" else "might"]={"bad":true}
        check(Session.new(bad).read_only,"nested invalid progression cannot crash or overwrite "+field)
    var s=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());s.gold=1000;s.profile.shards=100;s.profile.xp=1000
    var d=s.skills.definitions.sky_blade.duplicate(true);var spent=s.gold
    check(s.upgrade_skill("sky_blade") and s.gold==spent-30 and s.profile.shards==98,"skill upgrade spends real saved resources")
    check(s.skills.definitions.sky_blade.multiplier>d.multiplier and s.skills.definitions.sky_blade.cooldown==d.cooldown and s.skills.definitions.sky_blade.cost==d.cost,"skill upgrade increases real potency while retaining cost/CD")
    check(s.Definitions.all().sky_blade.multiplier==d.multiplier,"upgrade never mutates shared catalog")
    for id in ["arcane_eye","rage_flame","guardian_wall"]:check(s.upgrade_skill(id),"all real skill types upgrade "+id)
    check(s.skills.definitions.arcane_eye.amplify>1.35 and s.skills.definitions.rage_flame.tick_multiplier>.4 and s.skills.definitions.guardian_wall.absorb_fraction>.35,"mark burn and shield have distinct upgraded effects")
    for i in 6:s.upgrade_skill("sky_blade")
    check(s.Advancement.rank(s.profile,"sky_blade")==5 and not s.upgrade_skill("sky_blade"),"skill rank cap enforced")
    var broke=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());check(not broke.upgrade_skill("sky_blade") and broke.gold==0,"insufficient upgrade resources never spend")
    check(not broke.train_talent("might"),"no talent points before XP unlock")
    s.player_hp=80;var hp=s.player_max_hp
    check(s.train_talent("vitality") and s.player_max_hp==hp+8 and s.player_hp==88,"vitality preserves missing health")
    var attack=s.hero_damage();check(s.train_talent("might") and s.hero_damage()==attack+2,"strength changes real damage")
    check(not s.train_talent("might") and not s.train_talent("unknown"),"talent budget and valid IDs enforced")
    s.profile.xp=4000;s.player_hp=0;check(s.train_talent("vitality") and s.player_hp==0,"talents never resurrect defeated hero")
    var damage_model=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());damage_model.gold=100;damage_model.profile.shards=5;damage_model.upgrade_skill("sky_blade")
    damage_model.request_action("sky_blade");damage_model.tick(.3)
    var baseline=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());baseline.request_action("sky_blade");baseline.tick(.3)
    check(damage_model.enemy_hp<baseline.enemy_hp,"upgraded multiplier reaches actual contact damage")
    var counter=s.Quests.progress(s.profile,"skill_practice");s.pending.clear();s.busy_until=s.clock;s.skills.ready_at.clear();s.player_hp=1;s.outcome="fighting"
    check(s.request_action("sky_blade") and s.Quests.progress(s.profile,"skill_practice")==counter+1,"accepted manual skill counts once")
    check(not s.request_action("sky_blade") and s.Quests.progress(s.profile,"skill_practice")==counter+1,"rejected request never counts")
    var inv=Inventory.items(m.profile,"weapon",true)
    check(inv.size()==5 and inv[0].rarity=="epic","inventory filters and rarity sort actual owned weapons")
    check(Inventory.items(m.profile,"gear").size()==m.profile.hero_equipment.owned.size(),"inventory gear derives from true ownership")
    var old_weapon=m.profile.equipped;m.gold=1000
    check(m.upgrade_weapon("crystal") and m.profile.equipped==old_weapon,"selected inventory upgrade never silently equips")
    var saved=Session.new(s.snapshot());check(saved.skills.definitions.sky_blade.multiplier==s.skills.definitions.sky_blade.multiplier and saved.Advancement.bonuses(saved.profile)==s.Advancement.bonuses(s.profile),"skill/talent progression round-trip")
    check(Store.save_state(s.snapshot()),"expanded domains use existing atomic save writer")
    var disk=Session.new(Store.load_state())
    check(JSON.parse_string(JSON.stringify(disk.profile))==JSON.parse_string(JSON.stringify(s.profile)) and not disk.read_only,"all progression domains survive real disk load")
    var boss=m.World.encounter("glutkern",4);var behavior=m.Behavior.new();behavior.configure(boss,0)
    var tell=behavior.update(2.1);check(tell[0].pattern=="eruption" and tell[0].duration==1.5,"boss announces longer eruption windup")
    check(behavior.update(3.59).is_empty(),"eruption cannot strike before windup")
    var strike=behavior.update(3.6);check(strike[0].heavy and strike[1].pattern=="aftershock" and strike[1].duration==.8,"eruption announces separate aftershock")
    check(behavior.update(4.39).is_empty(),"aftershock cannot hit before its own telegraph")
    check(not behavior.update(4.4)[0].heavy and behavior.state=="idle","boss returns to recovery after bounded two-strike sequence")
    print("RPG 6.5: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)

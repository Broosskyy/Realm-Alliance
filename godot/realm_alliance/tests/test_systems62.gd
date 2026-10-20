extends SceneTree
const Session = preload("res://scripts/systems/combat_session.gd")
const Status = preload("res://scripts/systems/combat_status.gd")
const Rewards = preload("res://scripts/systems/reward_system.gd")
const Migration = preload("res://scripts/systems/save_migration.gd")
var checks = 0
var failures = 0
func check(ok: bool, text: String) -> void:
    checks += 1
    if not ok:
        failures += 1
        push_error("FAIL "+text)
func fresh() -> RACombatSession:
    return Session.new(preload("res://tests/legacy_fixture709.gd").guardian())
func high_health(s) -> void:
    s.enemy_hp = 10000
    s.enemy_max_hp = 10000
func _initialize() -> void:
    var s = fresh()
    high_health(s)
    check(s.request_action("sky_blade"),"sky blade available")
    check(not s.request_action("sky_blade"),"no duplicate reservation")
    s.tick(0.2)
    check(s.enemy_hp == 10000,"damage waits for impact")
    s.tick(0.2)
    check(s.enemy_hp == 9958,"blue skill does 2.8x damage")
    s.tick(0.5)
    check(not s.request_action("sky_blade"),"cooldown enforced")
    s.tick(4.7)
    check(s.request_action("sky_blade"),"cooldown expires by simulation time")
    s = fresh();high_health(s)
    s.momentum = 24
    check(not s.request_action("arcane_eye"),"insufficient momentum rejected")
    check(s.momentum == 24 and s.skills.ready_at.is_empty(),"rejection consumes nothing")
    s.momentum = 25
    check(s.request_action("arcane_eye") and s.momentum == 0,"mark consumes real cost")
    s.tick(0.6)
    check(s.enemy_status.has("mark",s.clock),"mark begins at impact")
    var hp = s.enemy_hp
    check(s.request_action(),"follow-up attack allowed")
    s.tick(0.7)
    check(hp-s.enemy_hp == 20,"mark increases subsequent attack from 15 to 20")
    s.tick(4.8)
    check(not s.enemy_status.has("mark",s.clock),"mark expires")
    s = fresh();high_health(s);s.rage = 40
    check(s.request_action("rage_flame") and s.rage == 0,"rage consumed")
    s.tick(0.5)
    hp = s.enemy_hp
    s.tick(4.0)
    check(hp-s.enemy_hp == 24,"burn yields exactly four ticks")
    check(not s.enemy_status.has("burn",s.clock),"burn expires after final tick")
    s = fresh();s.profile.xp=80;high_health(s);s.momentum=20
    s.behavior.state="windup";s.behavior.deadline=0.1
    hp = s.player_hp
    check(s.request_action("guardian_wall"),"defense unlocks at level 2")
    s.tick(0.2)
    check(s.player_hp == hp,"shield absorbs incoming damage")
    check(s.enemy_hp < 10000,"shield produces real counter damage")
    check(not bool(s.hero_status.active.shield.counter),"counter is single-use")
    s = fresh()
    check(not s.request_action("guardian_wall"),"defense locked before level 2")
    s.tick(2.2)
    check(s.behavior.state == "windup" and s.player_hp == s.player_max_hp,"enemy telegraphs before damage")
    s.tick(1)
    check(s.player_hp < s.player_max_hp,"enemy reduces HP")
    s.tick(120)
    check(s.outcome == "defeat" and s.player_hp == 0,"idle player can lose")
    check(not s.request_action(),"dead hero cannot attack")
    check(s.restart() and s.player_hp == s.player_max_hp,"defeat restart restores hero")
    check(not s.restart(),"cannot restart active battle for free healing")
    var v1={"version":1,"wave":7,"gold":177,"upgrade_level":3,"weapon_index":2,"total_kills":6}
    s = Session.new(v1)
    check(s.gold==177 and s.weapon_index==2 and s.upgrade_level==3 and s.total_kills==6,"v1 progress preserved")
    check(s.profile.inventory.size()==3 and s.profile.legacy_snapshot==v1,"all old weapons and source snapshot retained")
    check(s.wave==7 and s.profile.xp==120,"legacy stage and explicit XP conversion")
    var restored = Session.new(s.snapshot())
    check(restored.snapshot()==s.snapshot(),"v2 round-trip lossless")
    s = fresh();s.request_action("arcane_eye");s.tick(0.3)
    restored=Session.new(s.snapshot())
    s.tick(3.0);restored.tick(3.0)
    check(s.snapshot()==restored.snapshot(),"active statuses/cooldowns/enemy timing resume deterministically")
    s = fresh();s.rage=40;s.request_action("rage_flame")
    restored=Session.new(s.snapshot())
    s.tick(3.0)
    for i in 30:restored.tick(0.1)
    check(absf(s.clock-restored.clock)<0.0001 and s.enemy_hp==restored.enemy_hp and s.player_hp==restored.player_hp,"fixed-step tick independent of render delta")
    s = fresh()
    var reward=Rewards.grant(s.profile,"test",s.enemy_definition,0)
    var gold=s.gold
    check(reward.granted and not Rewards.grant(s.profile,"test",s.enemy_definition,0).granted and s.gold==gold,"reward transaction at most once")
    for i in 5:
        var d:Dictionary=s.Definitions.catalog().encounters[i]
        Rewards.grant(s.profile,"loot-%d"%i,d,0)
    check(s.profile.inventory.size()==5,"run awards all five real weapon IDs")
    var powers=[]
    for id in s.Equipment.IDS:
        check(s.equip(id),"can equip "+id)
        powers.append(s.hero_damage())
    check(powers[0]!=powers[1] and powers[3]!=powers[4],"weapons have distinct base values")
    s = fresh();high_health(s)
    s.profile.inventory.crystal={"id":"crystal","level":1,"rarity":"rare"};s.equip("crystal")
    for i in 4:
        s.request_action();s.tick(0.7)
    var criticals=0
    for event in s.drain_events():
        if event.type=="damage" and event.critical:criticals+=1
    check(criticals==1,"crystal produces one real crit in four hits")
    s = fresh();high_health(s)
    s.profile.inventory.ember={"id":"ember","level":1,"rarity":"rare"};s.equip("ember")
    for i in 5:s.request_action();s.tick(0.7)
    var dots=0
    for e in s.drain_events():
        if e.type=="damage" and e.source=="burn":dots+=1
    check(dots>=2,"frequent ember hits do not postpone burn ticks forever")
    s = fresh()
    var elapsed=0.0
    while s.outcome not in ["victory","defeat"] and elapsed<120:
        if s.outcome=="fighting":
            if not s.request_action("sky_blade"):
                s.request_action()
        s.tick(0.1);elapsed+=0.1
    check(s.outcome=="victory" and s.encounter==4,"complete normal/elite/boss run is winnable")
    check(s.profile.kills==5 and s.profile.loot.size()==5 and s.level>=2,"run grants real loot and XP")
    restored=Session.new(s.snapshot())
    check(restored.outcome=="victory" and restored.gold==s.gold,"completed run cannot regrant rewards on reload")
    check(s.restart() and s.tier==1,"victory restart advances challenge tier")
    # Behavior patterns have real temporal differences, not only different labels.
    var behavior=s.Behavior.new()
    var defs=s.Definitions.catalog().encounters
    for index in [0,2,4]:
        behavior.configure(defs[index],0)
        var strikes=[]
        for frame in range(1200):
            for e in behavior.update(frame/60.0):
                if e.type=="enemy_strike":strikes.append(e)
        if index==0:check(strikes.size()>=3,"normal attacks recur with recovery")
        if index==2:check(strikes.size()>=6 and float(strikes[1].multiplier)==0.7,"elite has timed follow-up strikes")
        if index==4:check(strikes.size()>=3 and float(strikes[1].multiplier)>1,"boss has alternating heavy strikes")
    s=fresh();high_health(s)
    s.profile.inventory.shadow_violet={"id":"shadow_violet","level":1,"rarity":"epic"}
    s.equip("shadow_violet");s.player_hp=50;s.request_action();s.tick(0.4)
    check(s.player_hp>50,"shadow weapon lifesteal heals actual HP")
    s=fresh();high_health(s)
    s.profile.inventory.rune_gold={"id":"rune_gold","level":1,"rarity":"epic"}
    s.equip("rune_gold");s.momentum=0;s.request_action();s.tick(0.4)
    check(s.momentum==14,"rune weapon adds extra momentum")
    var bonus=Rewards.grant(s.profile,"rune-bonus",s.enemy_definition,0)
    check(bonus.gold==20,"rune weapon grants actual gold modifier")
    s=fresh();high_health(s);s.request_action();s.tick(0.4)
    check(s.hero_status.has("guard",s.clock) and s.hero_status.active.guard.amount==3,"steel weapon adds timed guard")
    s.gold=1000
    check(s.try_upgrade() and s.profile.inventory.steel.level==2,"weapon level increases")
    check(s.try_upgrade() and s.profile.inventory.steel.level==3,"first two levels need only gold")
    check(not s.try_upgrade(),"later upgrades require real shards")
    s.profile.shards=1
    check(s.try_upgrade() and s.profile.shards==0,"upgrade consumes shard")
    s=fresh();elapsed=0
    var auto_clock=0.0
    while s.outcome not in ["victory","defeat"] and elapsed<120:
        auto_clock+=0.1
        if auto_clock>=0.72:
            auto_clock=0
            s.request_action("basic")
        s.tick(0.1);elapsed+=0.1
    check(s.outcome=="victory","standard-only AUTO can finish the starter run")
    check(s.skills.ready_at.is_empty(),"AUTO never spends a skill or starts its cooldown")
    s=fresh();s.request_action("sky_blade");s.tick(0.1)
    restored=Session.new(s.snapshot())
    s.tick(0.6);restored.tick(0.6)
    check(s.enemy_hp==restored.enemy_hp and s.skills.ready_at==restored.skills.ready_at,"pending impact resumes without duplicate or missing hit")
    s=fresh();high_health(s)
    s.profile.inventory.ember={"id":"ember","level":1,"rarity":"rare"}
    s.request_action()
    check(s.equip("ember"),"weapon can be changed while a saved action is pending")
    s.tick(0.4)
    check(s.enemy_hp==9985 and not s.enemy_status.has("burn",s.clock),"pending action retains its original damage and weapon trait")
    print("Systems 6.2: %d/%d checks"%[checks-failures,checks])
    quit(1 if failures else 0)

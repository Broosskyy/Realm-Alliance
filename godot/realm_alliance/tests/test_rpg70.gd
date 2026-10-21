extends SceneTree
const Session=preload("res://scripts/systems/combat_session.gd")
const Store=preload("res://scripts/save_store.gd")
var checks=0
var failures=0
func check(ok:bool,label:String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func prepared():
    var m=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());m.profile.gold=10000;m.profile.shards=1000;m.profile.xp=3000
    for region in m.World.IDS:
        for i in 5:m.World.clear_stage(m.profile,region,i,1)
    m.player_hp=m.player_max_hp
    m.profile.economy.materials.forge_dust=1000;m.profile.economy.materials.ember_core=100
    return m
func roundtrip(m):return Session.new(JSON.parse_string(JSON.stringify(m.snapshot())))
func win(m):
    var steps=0
    while m.outcome not in ["victory","defeat"] and steps<10000:
        m.request_action("basic");m.tick(.64);steps+=1
    return m.outcome=="victory"
func _initialize():call_deferred("run")
func run():
    var m=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());check(m.profile.economy.materials.forge_dust==0 and m.profile.activities.clears.is_empty(),"migration adds no fabricated loot or clears")
    check(m.Economy.RARITIES.size()==6,"six ordered rarity definitions")
    for id in ["economy","activities","journey"]:
        var state=m.snapshot();state.profile[id].schema=2;var future=Session.new(state)
        check(future.read_only and not future.economy_command("shop","forge_supply","economy:1"),"future domain protected "+id)
    m=prepared();var gold=m.gold;var receipt=m.Economy.nonce(m.profile)
    check(m.economy_command("shop","crystal_blade",receipt) and m.gold==gold-100 and m.profile.inventory.has("crystal"),"guaranteed shop debits and grants")
    gold=m.gold;check(not m.economy_command("shop","crystal_blade",receipt) and m.gold==gold,"replayed purchase cannot debit")
    m=roundtrip(m);check(not m.read_only and not m.economy_command("shop","forge_supply",receipt),"receipt survives JSON reload and rejects changed product replay")
    receipt=m.Economy.nonce(m.profile);gold=m.gold;var dust=m.profile.economy.materials.forge_dust
    m.profile.gold=0
    check(not m.economy_command("craft","ember_blade",receipt) and m.profile.economy.materials.forge_dust==dust and m.Economy.nonce(m.profile)==receipt,"insufficient funds leaves materials and receipt untouched")
    m.profile.gold=gold
    check(m.economy_command("craft","ember_blade",receipt) and m.profile.inventory.has("ember") and int(m.profile.economy.materials.forge_dust)==dust-18,"craft consumes recipe exactly")
    check(int(m.profile.journey.metrics.crafts)==1,"craft records progression once")
    check(not m.economy_command("craft","ember_blade",m.Economy.nonce(m.profile)),"owned item cannot be recrafted")
    var damage=m.Equipment.item_damage(m.profile,"ember")
    receipt=m.Economy.nonce(m.profile);check(m.economy_command("enchant","ember",receipt) and m.Equipment.item_damage(m.profile,"ember")==damage+4,"enchantment changes actual damage")
    for i in 4:check(m.economy_command("enchant","ember",m.Economy.nonce(m.profile)),"enchantment rank "+str(i+2))
    check(not m.economy_command("enchant","ember",m.Economy.nonce(m.profile)),"enchantment cap")
    check(not m.economy_command("salvage_weapon","steel",m.Economy.nonce(m.profile)),"starter and active weapon protected")
    m.equip("ember");check(not m.economy_command("salvage_weapon","ember",m.Economy.nonce(m.profile)),"equipped weapon protected")
    m.equip("steel");receipt=m.Economy.nonce(m.profile)
    check(m.economy_command("salvage_weapon","ember",receipt) and not m.profile.inventory.has("ember") and not m.profile.economy.enchants.has("ember"),"salvage removes item and enchant, grants material")
    check(not m.economy_command("salvage_weapon","ember",receipt),"salvage cannot repeat")
    for id in ["astral_plate","sentinel_circlet","sky_wings"]:m.change_gear(id,"acquire");m.change_gear(id)
    check(m.Economy.set_bonus(m.profile).pieces==3 and m.Economy.set_bonus(m.profile).attack==6 and m.Economy.set_bonus(m.profile).defense==2,"three-piece set affects actual stats")
    check(not m.economy_command("salvage_gear","sky_wings",m.Economy.nonce(m.profile)),"active armor protected")
    m=prepared();check(m.unlock_hero("runenpaladin"),"complete second hero unlocks")
    m.enemy_hp=32;m.player_hp=70;m.request_basic();var saved=m.snapshot();var serial=m.profile.run_serial
    check(m.select_hero("runenpaladin") and m.enemy_hp==32 and m.player_hp==70 and m.run_id==saved.checkpoint.run_id and m.pending.is_empty(),"hero switch cancels only outgoing action, retains health and run")
    check(m.select_hero("realmwachter") and m.profile.run_serial==serial,"switching back never creates new stage")
    m=prepared();m.enemy_hp=31;m.clock=2.5;m.momentum=42;m.request_basic();var story=m.snapshot()
    check(m.start_activity("gold_vault") and not m.start_activity("ember_forge") and not m.start_stage("wolkgarten"),"activity entry suspends story and prevents nested entry")
    check(m.encounter_count()==3 and m.enemy_definition.id.begins_with("gold_vault:"),"gold dungeon has own encounter contract")
    m=roundtrip(m);check(not m.read_only and m.activity.id=="gold_vault","mid-dungeon save restores activity")
    m.player_hp=m.player_max_hp;m.profile.inventory.steel.level=20
    check(win(m),"gold dungeon can be played to completion")
    check(int(m.profile.activities.clears.gold_vault)==1 and int(m.profile.journey.metrics.dungeons)==1,"activity and journey record one completed run")
    gold=m.gold;var chest_count=m.profile.chests.sealed.size();m.tick(10)
    check(m.gold==gold and m.profile.chests.sealed.size()==chest_count and m.Activities.complete(m.profile,"gold_vault",m.run_id,m.clock).is_empty(),"victory cannot pay twice")
    m=roundtrip(m);check(not m.read_only and m.outcome=="victory" and m.profile.chests.sealed.size()==chest_count,"victory save retains paid rewards")
    var returned=Session.new(m.leave_activity())
    check(returned.activity.is_empty() and returned.enemy_hp==31 and returned.clock==2.5 and returned.momentum==42 and returned.run_id==story.checkpoint.run_id,"return restores exact suspended main encounter")
    check(returned.pending==JSON.parse_string(JSON.stringify(story.checkpoint.pending)) and returned.gold==m.gold and returned.profile.inventory.steel.level==20,"story pending action and earned dungeon equipment survive return")
    returned.tick(.30);check(returned.enemy_hp<31,"suspended action resumes on its original combat clock")
    m=prepared();check(m.start_activity("ember_forge") and m.encounter_count()==5,"second dungeon has five encounters")
    m.profile.inventory.steel.level=20;check(win(m) and int(m.profile.activities.clears.ember_forge)==1,"material dungeon is completable")
    check(int(m.profile.economy.materials.ember_core)>=103,"forge rewards include boss and completion cores")
    m=prepared();check(m.start_activity("colossus_trial"),"local boss challenge entry")
    m.behavior.deadline=10000;m.tick(60.1);check(m.outcome=="defeat" and m.profile.activities.clears.is_empty(),"timer fails without a completion reward")
    check(m.restart() and m.clock==0 and m.outcome=="fighting","failed activity can restart with fresh timer")
    m.profile.inventory.steel.level=20;m.player_hp=m.player_max_hp;check(win(m) and int(m.profile.journey.metrics.boss_trials)==1,"timed boss can be defeated")
    check(not m.leave_activity().checkpoint.has("activity"),"suspended checkpoint cannot recurse")
    m=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());var now=1792368000
    m.profile.journey.last_seen=0;m.profile.journey.day=-1;m.profile.journey.week=-1
    check(m.Journey.claim(m.profile,"login",now),"UTC login reward claim")
    check(not m.Journey.claim(m.profile,"login",now) and not m.Journey.claim(m.profile,"login",now-86400),"same day and backwards clock cannot reopen login")
    for i in 10:m.Journey.kill(m.profile,i<5,now)
    check(m.Journey.claim(m.profile,"daily",now) and m.Journey.claim(m.profile,"weekly",now),"real daily and weekly goals")
    m=roundtrip(m);check(not m.read_only and not m.Journey.claim(m.profile,"daily",now),"daily receipt survives reload")
    m.Journey.refresh(m.profile,now+86400)
    check(m.profile.journey.daily_kills==0 and m.Journey.claim(m.profile,"login",now+86400),"next UTC day resets daily goals")
    check(not m.Journey.select_title(m.profile,"colossus_breaker"),"unearned title cannot be selected")
    for i in 3:m.Journey.record(m.profile,"boss_trials")
    check(m.Journey.select_title(m.profile,"colossus_breaker"),"title earned through actual objective metric")
    check(not m.journey_command("specialize","vanguard"),"specialization gate")
    m.profile.xp=3000;m.profile.gold=300;var before=m.hero_damage()
    check(m.journey_command("specialize","vanguard") and m.hero_damage()==before+8 and m.gold==300,"first specialization free and effective")
    check(m.journey_command("specialize","sentinel") and m.gold==200 and m.defense==3,"respecialization spends real gold")
    var bad=m.snapshot();bad.profile.economy.materials.forge_dust=1.5;check(Session.new(bad).read_only,"fractional material counter protected")
    bad=m.snapshot();bad.checkpoint.activity={"id":"unknown"};check(Session.new(bad).read_only,"unknown activity protected")
    var scene=load("res://scenes/main.tscn").instantiate();scene.initial_creation_enabled=false;root.add_child(scene);scene.hud.collection_page.category="Helden";scene.set_process(false)
    scene._on_hud_action("Beute");scene._on_hud_action("economy");await process_frame
    var hub
    for child in scene.get_children():
        if child is RARPGHub:hub=child
    check(hub!=null and hub.tabs.get_tab_count()==4,"real native Shop/Crafting/Dungeons/Journey screens wired")
    if hub:
        var touch_rect=hub.tabs.get_tab_bar().get_tab_rect(0)
        check(touch_rect.size.y>=88 and touch_rect.size.x>=88,"native tabs retain 44 px touch targets at half-scale")
    scene.queue_free();await process_frame
    print("RPG 6.8–7.0: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)

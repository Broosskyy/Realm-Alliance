extends SceneTree
const Session=preload("res://scripts/systems/combat_session.gd")
const Hero=preload("res://scripts/production_hero.gd")
const Scene=preload("res://scenes/main.tscn")
var checks=0
var failures=0
func check(ok:bool,label:String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func run() -> void:
    var m=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());m.gold=100000;m.profile.shards=10000;m.profile.xp=100000
    m.profile.economy.materials.forge_dust=10000;m.profile.economy.materials.ember_core=10000;m.World.clear_stage(m.profile,"glutkern",4,1)
    for id in ["runenpaladin","schattenjager"]:m.profile.hero_roster.owned[id]={"xp":100000,"source":"test"}
    check(m.Roster.playable_catalog().keys()==["runenpaladin","schattenjager","realmwachter"],"requested collection order")
    for id in m.Mastery.ORDER:
        m.profile.hero_roster.owned[id].xp=100000
        var other="schattenjager" if id!="schattenjager" else "runenpaladin"
        var unchanged=m.hero_preview_stats(other)
        for r in range(1,6):
            var quote=m.Mastery.cost(m.profile,id);var gold=m.gold;var shards=int(m.profile.shards)
            check(m.advance_hero(id),id+" can ascend to "+str(r))
            check(m.Mastery.rank(m.profile,id)==r,"only one rank advanced "+id+str(r))
            check(gold-m.gold==int(quote.gold) and shards-int(m.profile.shards)==int(quote.shards),"exact rank price "+id+str(r))
            check(m.hero_preview_stats(other)==unchanged,"other hero stats unchanged "+id+str(r))
        check(not m.advance_hero(id),"rank V cap "+id)
        m.select_hero(id);check(m.hero_preview_stats(id).attack==m.hero_damage() and m.hero_preview_stats(id).hp==m.player_max_hp and m.hero_preview_stats(id).defense==m.defense,"preview equals equipped stats "+id)
    var roundtrip=Session.new(JSON.parse_string(JSON.stringify(m.snapshot())))
    check(not roundtrip.read_only and roundtrip.profile.hero_mastery==m.profile.hero_mastery,"ranks survive save roundtrip")
    var malformed=m.snapshot();malformed.profile.hero_mastery.heroes.realmwachter.rank=6
    check(Session.new(malformed).read_only,"unknown rank protects original save")
    var fresh=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());fresh.gold=1000;fresh.profile.economy.materials.forge_dust=100
    var account_xp=int(fresh.profile.xp);var before=fresh.Roster.xp(fresh.profile,"realmwachter");var cost=fresh.Mastery.training_cost(fresh.profile,"realmwachter")
    check(fresh.train_hero("realmwachter"),"single guardian can train")
    check(fresh.Roster.xp(fresh.profile,"realmwachter")==before+int(cost.xp) and int(fresh.profile.xp)==account_xp,"training is individual XP, not account XP")
    fresh.profile.hero_roster.owned.runenpaladin={"xp":0,"source":"test"};var guardian_xp=fresh.Roster.xp(fresh.profile,"realmwachter")
    check(fresh.train_hero("runenpaladin") and fresh.Roster.xp(fresh.profile,"realmwachter")==guardian_xp,"inactive hero training never trains active hero")
    fresh.gold=0;before=fresh.Roster.xp(fresh.profile,"runenpaladin")
    check(not fresh.train_hero("runenpaladin") and fresh.Roster.xp(fresh.profile,"runenpaladin")==before,"unaffordable training makes no change")
    check(not fresh.Titles.equip(fresh.profile,"ascended"),"unearned local title rejected")
    check(m.Titles.equip(m.profile,"ascended") and m.profile.titles.active=="ascended","earned legendary title equips")
    var hero=Hero.new();root.add_child(hero);hero.set_process(false)
    for id in m.Mastery.ORDER:
        hero.set_hero(id)
        for r in 6:
            var weapon=hero._weapon.texture;hero.set_mastery_visual(r)
            check(hero.aura.mastery_rank==r and hero._palette.get_shader_parameter("mastery_rank")==r,"visual rank applies "+id+str(r))
            check(hero._weapon.texture==weapon,"rank keeps weapon modular "+id+str(r))
    hero.queue_free()
    var scene=Scene.instantiate();root.add_child(scene);scene.set_process(false);scene.auto_enabled=false;scene.audio.enabled=false;scene._qa_active=true
    scene._on_hud_action("Mehr");await process_frame
    check(scene.hud.buttons.community.visible,"community has visible main-menu entry")
    scene.hud.buttons.community.pressed.emit();await process_frame
    var window
    for child in scene.get_children():
        if child is Window and child.title=="Gemeinschaft":window=child
    check(window!=null,"community menu opens real game sheet")
    for tab in ["Konto","Familie","Arena","Titel","Rangliste","Raid"]:check(window.find_child("Community_"+tab,true,false)!=null,"community feature visible "+tab)
    window._select("Titel");check(window.find_child("TitleEquip_wanderer",true,false)!=null,"titles work without online connection")
    var profile=JSON.stringify(scene.model.snapshot());window._select("Familie")
    check(profile==JSON.stringify(scene.model.snapshot()),"browsing social pages leaves combat and profile untouched")
    var net=scene.realm_online
    net.connected=true;net.message="Verbunden als Test";net.state={"boss":{"hp":6000,"max_hp":6000,"contributions":[]},"online":[{"name":"Test"}]}
    window._select("Raid");var attack=window.find_child("RaidAttack",true,false);var instance=attack.get_instance_id()
    net.state.boss.hp=5955;net.state.boss.contributions=[{"name":"Test","damage":45}];net.changed.emit()
    check(window.find_child("RaidAttack",true,false).get_instance_id()==instance,"raid refresh preserves physical touch target")
    check(window.find_child("SharedBossHP",true,false).value==5955,"raid HP refreshes without rebuilding page")
    check(window.find_child("RaidContributors",true,false).text.contains("45"),"raid contributor refreshes in place")
    net.busy=true;net._route="state";net.changed.emit()
    check(not attack.disabled,"background polling does not disable attack target")
    var snapshot=scene.model.snapshot()
    check(net.send("boss/attack",{"nonce":"queued-action-708"}),"tap during state request queues real action")
    check(net._queued_action.route=="boss/attack" and net._queued_action.payload.nonce=="queued-action-708","queued action keeps original idempotency key")
    check(not net.send("boss/attack",{"nonce":"duplicate-708"}),"second pending tap cannot enqueue duplicate action")
    check(scene.model.snapshot()==snapshot,"online queue never mutates local hero profile")
    net._queued_action.clear();net.busy=false
    window.queue_free();scene.queue_free();await process_frame;await process_frame
    print("708 hero mastery and community: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)
func _initialize() -> void:call_deferred("run")

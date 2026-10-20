extends SceneTree
const Session=preload("res://scripts/systems/combat_session.gd")
const Hero=preload("res://scripts/production_hero.gd")
var checks=0
var failures=0
func check(value:bool,label:String):
    checks+=1
    if not value:failures+=1;push_error("FAIL "+label)
func roundtrip(m):return Session.new(JSON.parse_string(JSON.stringify(m.snapshot())))
func _initialize():call_deferred("run")
func run():
    var m=Session.new(preload("res://tests/legacy_fixture709.gd").guardian());m.profile.xp=5000;m.profile.gold=10000;m.profile.shards=1000
    for region in m.World.IDS:
        for i in 5:m.World.clear_stage(m.profile,region,i,1)
    m.profile.economy.materials.forge_dust=300;m.profile.economy.materials.ember_core=20
    check(not m.acquire_companion("lanternwisp") and not m.change_gear("harvest_wings","acquire"),"event gear and pet cannot be acquired free via legacy shop")
    check(not m.Events.claim(m.profile,"harvest_2026","harvest_king"),"event quest chain rejects out-of-order claim")
    m.profile.inventory.steel.level=20
    for run_index in 3:
        check(m.start_activity("harvest_abbey"),"event activity starts "+str(run_index))
        var count=0
        while m.outcome not in ["victory","defeat"] and count<5000:
            m.request_basic();m.tick(.65);count+=1
        check(m.outcome=="victory","five-wave event completed "+str(run_index))
        m=roundtrip(m)
        check(not m.read_only and int(m.profile.event_progress.packs.harvest_2026.clears)==run_index+1,"event metrics persist and never duplicate "+str(run_index))
        var tokens=m.profile.economy.materials.harvest_token
        m.tick(10);check(m.profile.economy.materials.harvest_token==tokens,"terminal encounter cannot farm tokens")
        m=Session.new(m.leave_activity())
    check(int(m.profile.event_progress.packs.harvest_2026.kills)==15 and int(m.profile.event_progress.packs.harvest_2026.bosses)==3,"event has actual kills and boss counters")
    for quest in ["harvest_scout","harvest_king","harvest_warden"]:
        check(m.Events.claim(m.profile,"harvest_2026",quest),"real ordered event quest claim "+quest)
        var tokens=m.profile.economy.materials.harvest_token
        m=roundtrip(m)
        check(not m.Events.claim(m.profile,"harvest_2026",quest) and m.profile.economy.materials.harvest_token==tokens,"event claim receipt persists "+quest)
    var opened=0
    while not m.profile.chests.sealed.is_empty():
        var reward=m.open_chest();check(not reward.is_empty(),"sealed chest grants exactly once");opened+=1
    check(opened>=3 and m.profile.hero_equipment.owned.has("harvest_wings"),"themed event chest awards actual harvest gear")
    check(m.open_chest().is_empty(),"opened event chests cannot replay")
    check(m.economy_command("shop","harvest_pet",m.Economy.nonce(m.profile)) and m.select_companion("lanternwisp"),"earned event currency buys a real combat companion")
    var tokens=m.profile.economy.materials.harvest_token
    check(not m.economy_command("shop","harvest_pet",m.Economy.nonce(m.profile)) and m.profile.economy.materials.harvest_token==tokens,"owned event companion cannot be repurchased")
    m.enemy_hp=500;m.enemy_max_hp=500;m.behavior.deadline=10000;m.outcome="fighting";m.tick(.6)
    check(m.enemy_hp<500,"event companion resolves a timed actual hit")
    check(m.change_gear("harvest_wings"),"themed wings are independently equipable")
    check(m.journey_command("evolve","") and m.Evolution.highest(m.profile)==1,"visible form II costs resources and unlocks")
    check(m.journey_command("evolve","") and m.Evolution.highest(m.profile)==2,"visible form III")
    check(not m.journey_command("evolve",""),"legendary form requires real boss trial")
    m.profile.activities.clears.colossus_trial=1
    check(m.journey_command("evolve","") and m.Evolution.highest(m.profile)==3,"visible form IV gated progression")
    var stats=m.player_max_hp;var attack=m.hero_damage();var gold=m.gold
    check(not m.journey_command("evolve","") and m.gold==gold,"legendary cap cannot charge twice")
    check(m.journey_command("form","base") and m.player_max_hp==stats and m.hero_damage()==attack,"cosmetic form cannot change earned stats or heal")
    m.journey_command("form","legendary");m=roundtrip(m)
    check(not m.read_only and m.Evolution.form_rank(m.profile)==3,"four-form progression survives actual JSON save")
    var rig=Hero.new();root.add_child(rig);rig.set_gear(m.profile)
    check(rig.attachments.wings.visible and rig.aura.form_rank==3 and rig._palette.get_shader_parameter("evolution_rank")==3,"legendary visual and event wings applied to real rig")
    for id in ["pumpkin","shadow","harvest_boss"]:
        for pose in ["idle","attack","hit","defeated"]:
            var texture=load("res://assets/events69/"+id+"/"+pose+".png")
            var image=texture.get_image()
            check(image.get_pixel(0,0).a==0 and image.get_pixel(image.get_width()-1,image.get_height()-1).a==0,"actual alpha on monster "+id+pose)
    m.unlock_hero("runenpaladin");m.select_hero("runenpaladin");rig.set_hero("runenpaladin");rig.set_gear(m.profile)
    for pose in rig.Gate.HERO_STATES:
        rig._set_pose(pose)
        check(rig._body.texture!=null and rig.weapon_is_modular(),"second hero has own pose and separate weapon "+pose)
    rig.play_death();check(rig._pose=="defeated","second hero has genuine defeated pose")
    rig.queue_free();await process_frame
    print("Event/Progression 6.9–7.0: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)

extends SceneTree
const Session=preload("res://scripts/systems/combat_session.gd")
const Character=preload("res://scripts/systems/character_progress712.gd")
const Rig=preload("res://scripts/production_hero.gd")
var checks=0
var failures=0
func check(ok:bool,label:String) -> void:
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func _initialize():call_deferred("run")
func run():
    var original=Session.new().snapshot()
    for sex in ["male","female"]:
        for hair in Character.Appearance.NATURAL_COLORS:
            var s=Session.new(original);s.player_hp=37;var owned=s.profile.hero_roster.duplicate(true);var before=JSON.stringify(s.snapshot())
            check(not s.create_character(sex,"white") and JSON.stringify(s.snapshot())==before,"special hair locked and rejection atomic")
            check(s.create_character(sex,hair) and s.hero_id=="adventurer_"+sex and s.hero_level==1,"create chosen body/hair")
            check(s.profile.hero_roster==owned and s.gold==original.profile.gold and s.player_hp==37,"old roster/currencies and damage retained")
            var power=s.power
            for color in Character.Appearance.NATURAL_COLORS:check(Character.set_hair(s.profile,color) and s.power==power,"free cosmetic hair "+color)
            check(not s.create_character(sex,hair) and not s.choose_class("mage"),"one character and job gate")
            s.enemy_hp=1;s._damage_enemy(100000,"basic",false);var xp=s.profile.character712.xp
            check(xp>0 and s.profile.character712.jobs.adventurer==xp,"real victory awards both XP domains")
            s._damage_enemy(100000,"basic",false);check(s.profile.character712.xp==xp,"duplicate reward no XP")
            Character.gain(s.profile,160);var actor=s.actor_id;var lv=s.hero_level
            for job in ["swordsman","archer","mage"]:
                var next=Session.new(JSON.parse_string(JSON.stringify(s.snapshot())))
                check(not next.read_only and next.choose_class(job),"choose "+job)
                check(next.actor_id==actor and next.hero_level==lv and next.profile.character712.appearance.body_variant==sex,"same character progression "+job)
                check(Character.job_level(next.profile)==1 and next.profile.character712.jobs.adventurer>=160,"new job separate "+job)
                check(not next.choose_class("mage" if job!="mage" else "archer"),"choice cannot reset job")
                var loaded=Session.new(JSON.parse_string(JSON.stringify(next.snapshot())))
                check(not loaded.read_only and loaded.profile.character712==next.profile.character712,"save roundtrip "+job)
            check(s.select_hero("runenpaladin") and not Character.active(s.profile) and s.activate_character() and s.actor_id==actor,"switch legacy and back safely")
    var old=Session.new(preload("res://tests/legacy_fixture709.gd").guardian())
    old.profile.xp=440;var guardian_xp=old.Roster.xp(old.profile,"realmwachter")
    check(old.create_character("male","brown"),"legacy guardian can create new character")
    old.enemy_hp=1;old._damage_enemy(100000,"basic",false)
    check(old.Roster.xp(old.profile,"realmwachter")==guardian_xp and old.profile.hero_roster.independent_xp,"new character does not advance old account-linked guardian")
    var valid=Session.new();valid.create_character("female","copper")
    for bad in [null,[],true,{"schema":99},valid.profile.character712.duplicate(true)]:
        if bad is Dictionary and bad.has("appearance"):bad.jobs.adventurer=-1
        var data=valid.snapshot();data.profile.character712=bad;var loaded=Session.new(data)
        check(loaded.read_only and loaded.profile.character712==bad,"future/malformed record retained")
        check(not loaded.create_character("male","brown") and not loaded.choose_class("mage") and not loaded.activate_character(),"read-only rejects mutations")
    var rig=Rig.new();root.add_child(rig)
    for sex in ["male","female"]:
        valid=Session.new();valid.create_character(sex,"blond");rig.set_hero(valid.hero_id);rig.set_gear(valid.profile)
        check(not rig.attachments.wings.visible and not rig.wardrobe_visual.visible,"simple starter has no wings/costume")
        for pose in rig.Gate.HERO_STATES:
            rig._set_pose(pose);var at=rig.hand(pose)
            check(rig._body.texture.get_size()==Vector2(640,512) and rig._body.texture.get_image().get_pixel(int(at.x),int(at.y)).a>.4,"hand on glove "+sex+pose)
        for family in ["forest_path","sand_traveler"]:
            valid.profile.wardrobe.owned[family]={};valid.equip_costume(family);rig.set_gear(valid.profile)
            for pose in rig.Gate.HERO_STATES:
                rig._set_pose(pose);check(rig.wardrobe_visual.pieces.torso.polygon.size()==4 and rig._body.texture.resource_path.contains("/work712/"),"explicit costume body fit "+sex+family+pose)
    rig.queue_free();await process_frame
    var scene=preload("res://scenes/main.tscn").instantiate();root.add_child(scene)
    await process_frame;await process_frame;await process_frame
    check(is_instance_valid(scene.creation_dialog) and scene.creation_dialog.visible,"actual fresh boot shows creation")
    var stopped=scene.model.clock;scene._process(.5)
    check(scene.model.clock==stopped and not scene._on_tap() and not scene._on_skill(0),"creation blocks simulation/input")
    scene.creation_dialog.created.emit("female","blond")
    check(scene.model.Character.active(scene.model.profile) and not scene.creation_dialog.visible,"creation applies to actual scene")
    scene._qa_active=true;scene.queue_free();await process_frame
    print("Character 712: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)

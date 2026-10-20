extends SceneTree
const Hero=preload("res://scripts/production_hero.gd")
const Timeline=preload("res://scripts/presentation/animation_timeline.gd")
var checks=0
var failures=0
func check(ok:bool,label:String):
    checks+=1
    if not ok:failures+=1;push_error("FAIL "+label)
func _initialize():call_deferred("run")
func sample(hero,id:String,t:float):
    hero._action_id=id;hero._action_elapsed=t;hero._windup=.28;hero._recovery=.38;hero._busy=true;hero._impacted=false;hero._sample_action()
    return hero._socket.rotation
func run():
    var hero=Hero.new();root.add_child(hero);hero.set_process(false)
    for id in ["realmwachter","runenpaladin","schattenjager"]:
        hero.set_hero(id)
        for action in ["basic","sky_blade","rage_flame","ultimate","chain_0_1","chain_1_1","chain_2_1","chain_0_4","chain_1_4","chain_2_4"]:
            hero.revive()
            var beginning=sample(hero,action,0)
            check(absf(angle_difference(beginning,deg_to_rad(hero.angle("idle"))))<.001,id+action+" starts from idle blade angle")
            var worst=0.0
            for boundary in [.14,.252,.28,.34,.38,.475,.6599]:
                var before=sample(hero,action,boundary-.00001)
                var after=sample(hero,action,boundary+.00001)
                worst=maxf(worst,absf(angle_difference(before,after)))
            check(worst<.005,id+action+" no blade-angle discontinuity at phase/body boundaries")
            var ending=sample(hero,action,.6599)
            check(absf(angle_difference(ending,deg_to_rad(hero.angle("idle"))))<.005,id+action+" returns to idle without final snap")
        hero.revive();hero.play_action("chain_0_1",.28,.38)
        hero.sync_clock(.1)
        var expected=Timeline.sample("chain_0_1",.1,.28,.38).get("weapon_track",{})
        if expected.is_empty():check(false,id+" missing continuous blade track")
        else:
            var target=lerp_angle(deg_to_rad(hero.angle(expected.from)),deg_to_rad(hero.angle(expected.to)),expected.blend)+deg_to_rad(expected.offset)
            check(absf(angle_difference(target,hero._socket.rotation))<.001,id+" renderer does not overwrite scheduled windup")
    hero.queue_free();await process_frame
    print("Continuous weapon track: %d/%d checks"%[checks-failures,checks]);quit(1 if failures else 0)

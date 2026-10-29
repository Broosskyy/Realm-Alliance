extends SceneTree
const Enemy=preload("res://scripts/production_enemy.gd")
const Stage=preload("res://scripts/presentation/enemy_stage735.gd")
const Layout=preload("res://scripts/combat_layout.gd")
var checks=0
var errors=0
func verify(ok:bool,label:String) -> void:
    checks+=1
    if not ok:
        errors+=1
        push_error("735 "+label)
func _initialize() -> void:call_deferred("run")
func run() -> void:
    for size in [Vector2(360,800),Vector2(720,1280),Vector2(720,1560),Vector2(1280,720)]:
        var metrics=Layout.solve(size)
        var room=float(metrics.stage_origin.y)/float(metrics.ui_scale)-300
        var normal=Stage.target_height("normal","golem",room)
        var small=Stage.target_height("normal","slime",room)
        var elite=Stage.target_height("elite","stone_sentry",room)
        var boss=Stage.target_height("boss","cinder_colossus",room)
        verify(small<=normal and normal<=elite and elite<=boss,"size hierarchy "+str(size))
        verify(boss<=maxf(178.0,room),"boss respects available vertical room "+str(size))
    var monster=Enemy.new()
    root.add_child(monster)
    monster.set_process(false)
    monster.configure_enemy({"visual":"golem","kind":"normal","palette":""})
    monster.show_wave(5)
    verify(monster._kind=="normal","fifth wave does not automatically create boss")
    monster.fit_height(305.0,205.0)
    verify(absf(monster.scale.y*Enemy.STANDING.golem.size.y-305.0)<0.5,"normal silhouette fits height")
    monster.play_telegraph(1.0,"heavy")
    verify(monster._warning_remaining>0 and monster._warning_pattern=="heavy","heavy warning starts")
    monster._process(0.35)
    verify(monster._warning_remaining>0.5 and monster._warning_remaining<0.8,"warning progresses")
    monster.play_attack()
    verify(monster._warning_remaining==0,"hit clears warning")
    monster.play_telegraph(0.75,"double")
    monster.interrupt_telegraph()
    verify(monster._warning_remaining==0,"interrupted attack clears warning")
    monster.configure_enemy({"visual":"cinder_colossus","kind":"boss","palette":""})
    monster.show_wave(6)
    verify(monster._kind=="boss","definition, not wave, marks boss")
    monster.fit_height(580,230)
    verify(absf(monster.scale.y*Enemy.STANDING.cinder_colossus.size.y-580)<0.5,"boss silhouette fits height")
    monster.play_telegraph(0.8,"eruption")
    verify(monster._warning_remaining>0,"boss warning starts")
    monster.play_death()
    verify(monster._warning_remaining==0,"boss death clears warning")
    monster.queue_free()
    await process_frame
    print("REALM 735 ENCOUNTER %d/%d"%[checks-errors,checks])
    quit(1 if errors else 0)

extends Node2D
class_name RACompanionVisual
const Progress=preload("res://scripts/systems/companion_progress.gd")
var sprite:Sprite2D
var actor_id=""
var frames:Dictionary={}
var clock=0.0
var cast_start=-10.0
var cast_duration=0.0
var reward_until=0.0
func _ready() -> void:
    sprite=Sprite2D.new();sprite.centered=false;sprite.position=Vector2(-256,-470);add_child(sprite)
    for id in ["skyfox","sunbird"]:
        frames[id]={}
        for form in ["base","evolved"]:
            for pose in ["idle","ready","cast","reward"]:frames[id][form+"_"+pose]=load("res://assets/roster67/"+id+"/"+form+"_"+pose+".png")
func sync(profile:Dictionary,value:float) -> void:
    if not sprite:return
    clock=value
    var id=str(profile.companions.active) if Progress.ensure(profile) else ""
    visible=id!=""
    if not visible:return
    if id!=actor_id:actor_id=id;cast_start=-10;reward_until=0
    var casting=clock<cast_start+cast_duration+.12
    var pose=("ready" if clock<cast_start+cast_duration*.4 else "cast") if casting else ("reward" if clock<reward_until else "idle")
    sprite.texture=frames[id][("evolved" if int(profile.companions.owned[id].evolution)>0 else "base")+"_"+pose]
    sprite.position=Vector2(-256,-470)+Vector2(0,sin(clock*2.4)*4)
func cast(duration:float) -> void:cast_start=clock;cast_duration=duration
func reward() -> void:reward_until=clock+.7

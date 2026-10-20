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
var preview_mode=false
var preview_evolved=false
func _ready() -> void:
    sprite=Sprite2D.new();sprite.centered=false;sprite.position=Vector2(-256,-470);add_child(sprite)
    for id in Progress.catalog():
        frames[id]={}
        for form in ["base","evolved"]:
            for pose in ["idle","ready","cast","reward"]:frames[id][form+"_"+pose]=load("res://assets/roster67/"+id+"/"+form+"_"+pose+".png")
func sync(profile:Dictionary,value:float) -> void:
    if not sprite:return
    clock=value
    var id=str(profile.companions.active) if Progress.ensure(profile) else ""
    _sample(id,int(profile.companions.owned.get(id,{}).get("evolution",0))>0)
func _sample(id:String,evolved:bool) -> void:
    visible=frames.has(id)
    if not visible:return
    if id!=actor_id:actor_id=id;cast_start=-10;reward_until=0
    var casting=clock<cast_start+cast_duration+.12
    var pose=("ready" if clock<cast_start+cast_duration*.4 else "cast") if casting else ("reward" if clock<reward_until else "idle")
    sprite.texture=frames[id][("evolved" if evolved else "base")+"_"+pose]
    sprite.position=Vector2(-256,-470)+Vector2(0,sin(clock*2.4)*4)
func configure_preview(id:String,evolved:bool=false) -> void:
    # Visual state only: previews never acquire/equip/evolve a companion.
    preview_mode=true;preview_evolved=evolved;_sample(id,evolved)
func _process(delta:float) -> void:
    if not preview_mode or not sprite:return
    clock+=delta;_sample(actor_id,preview_evolved)
func cast(duration:float) -> void:cast_start=clock;cast_duration=duration
func reward() -> void:reward_until=clock+.7

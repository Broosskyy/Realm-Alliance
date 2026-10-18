extends Node2D
class_name RACombatVFXController
const Effect=preload("res://scripts/presentation/skill_vfx.gd")
const Status=preload("res://scripts/presentation/status_vfx.gd")
const MAX_EFFECTS: int = 24
const TEX={
    "sky_slash":preload("res://assets/vfx/sky_slash.png"),"sky_impact":preload("res://assets/vfx/sky_impact.png"),
    "arcane_eye":preload("res://assets/vfx/arcane_eye.png"),"arcane_seal":preload("res://assets/vfx/arcane_seal.png"),
    "fire_slash":preload("res://assets/vfx/fire_slash.png"),"fire_impact":preload("res://assets/vfx/fire_impact.png"),
    "shield":preload("res://assets/vfx/shield.png"),"reward":preload("res://assets/vfx/reward.png")}
var intensity: float = 1
var status
var hero_at: Vector2
var enemy_at: Vector2
func _ready() -> void:
    status=Status.new();status.z_index=9;add_child(status)
func emit_effect(id: String, at: Vector2, diameter: float=240, lifetime: float=0.5, kind: String="impact", layer: int=16):
    if intensity<=0 or not TEX.has(id):return null
    var active=[]
    for child in get_children():
        if child is RASkillVFX and not child.is_queued_for_deletion():active.append(child)
    if active.size()>=MAX_EFFECTS:active[0].queue_free()
    var fx=Effect.new();fx.texture=TEX[id];fx.position=at;fx.diameter=diameter;fx.duration=lifetime;fx.kind=kind;fx.intensity=intensity;fx.z_index=layer;add_child(fx)
    return fx
func enemy_warning(model,pattern: String,duration: float,ground: Vector2) -> void:
    if pattern not in ["eruption","aftershock"]:return
    var fx=emit_effect("fire_impact",ground,250 if pattern=="eruption" else 190,duration,"eruption_warning",7)
    if fx:fx.model_deadline=model.clock+duration
func action(e: Dictionary, weapon_socket: Node2D=null) -> void:
    var id=str(e.id);var duration=maxf(0.08,float(e.get("windup",0.28)))
    match id:
        "sky_blade":
            var fx=emit_effect("sky_impact",hero_at+Vector2(60,-40),140,duration,"charge",11)
            if fx:fx.follow_node=weapon_socket
        "arcane_eye":
            emit_effect("arcane_seal",hero_at,190,duration,"charge",7)
            var fx=emit_effect("arcane_eye",hero_at,95,duration,"projectile",15)
            if fx:fx.origin=hero_at;fx.target=enemy_at
        "rage_flame":
            var fx=emit_effect("fire_impact",hero_at+Vector2(60,-20),180,duration,"charge",11)
            if fx:fx.follow_node=weapon_socket
        "guardian_wall":emit_effect("shield",hero_at,270,0.4,"spawn",17)
        _:emit_effect("sky_slash",hero_at+Vector2(90,0),95,duration,"charge",11)
func impact(source: String, critical: bool=false) -> void:
    match source:
        "sky":
            emit_effect("sky_slash",hero_at.lerp(enemy_at,0.56),390,0.48,"slash")
            emit_effect("sky_impact",enemy_at,240,0.42)
        "fire":
            emit_effect("fire_slash",hero_at.lerp(enemy_at,0.6),420,0.55,"slash")
            emit_effect("fire_impact",enemy_at,270,0.6)
        "arcane":emit_effect("arcane_eye",enemy_at,200,0.55)
        "burn":emit_effect("fire_impact",enemy_at+Vector2(0,30),110,0.35)
        "counter":emit_effect("shield",enemy_at,220,0.38)
        _:emit_effect("sky_impact",enemy_at,105,0.25)
    if critical:emit_effect("reward",enemy_at,280,0.5)
func sync(model, hero_pos: Vector2, enemy_pos: Vector2) -> void:
    for child in get_children():
        if child is RASkillVFX and child.model_deadline>=0:
            child.age=maxf(0,child.duration-child.model_deadline+model.clock)
            if child.age>=child.duration:child.queue_free()
            else:child.queue_redraw()
    hero_at=hero_pos+Vector2(40,-140);enemy_at=enemy_pos+Vector2(-40,-155)
    if status==null:return
    status.hero_at=hero_at;status.enemy_at=enemy_at;status.intensity=intensity
    status.mark=model.enemy_status.has("mark",model.clock) and model.enemy_hp>0
    status.burn=model.enemy_status.has("burn",model.clock) and model.enemy_hp>0
    var shield_now=model.hero_status.has("shield",model.clock) and model.player_hp>0
    if status.shielded and not shield_now:emit_effect("shield",hero_at,250,0.32,"spawn",17)
    status.shielded=shield_now
    status.shield_ratio=clampf(float(model.hero_status.active.get("shield",{}).get("amount",0))/maxf(1,model.player_max_hp*0.35),0,1)
    status.queue_redraw()
func clear() -> void:
    for child in get_children():
        if child!=status:child.queue_free()
    if status:status.mark=false;status.burn=false;status.shielded=false;status.queue_redraw()

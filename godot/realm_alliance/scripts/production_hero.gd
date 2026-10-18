extends Node2D
class_name RAProductionHero

# White-haired masked Realmwächter; six weapon-free hero sprites.
# Equipment remains a separate sprite, changed without modifying body texture.
signal impact
signal action_finished

const Timeline = preload("res://scripts/presentation/animation_timeline.gd")
const Definitions = preload("res://scripts/systems/skill_definition.gd")
const Gate = preload("res://scripts/production_art_gate.gd")
const PIVOT: Vector2 = Vector2(320.0, 488.0)
const BLADE_GRIP: Vector2 = Vector2(188.0, 193.0)
const BLADE_SCALE: float = 0.33
# Approximate fist centers reviewed against the 640x512 canonical cutouts.
# These replace the earlier out-of-body values; final grip-angle QA needs phone video.
const HANDS := {
    "idle": Vector2(505.0, 349.0),
    "ready": Vector2(510.0, 348.0),
    "windup": Vector2(470.0, 225.0),
    "attack_contact": Vector2(544.0, 347.0),
    "recovery": Vector2(443.0, 418.0),
    "hit": Vector2(474.0, 355.0)
}
const ANGLES := {
    "idle": -28.0, "ready": -34.0, "windup": -74.0,
    "attack_contact": -8.0, "recovery": -25.0, "hit": -45.0
}

const Alternate=preload("res://scripts/presentation/hero_visual_catalog.gd")
var hero_id="realmwachter"
var hero_sets:Dictionary={}
var _art: Node2D
var _body: Sprite2D
var _socket: Node2D
var _weapon: Sprite2D
var _poses: Dictionary = {}
var _weapons: Array[Texture2D] = []
var _pose: String = "idle"
var _busy: bool = false
var _clock: float = 0.0
var _selected: int = 0
var _action: Tween
var _reaction: Tween
var _dead: bool = false
var _look: String = "canonical"
var _palette: ShaderMaterial
var aura
var external_clock: bool = false
var _action_id: String = "basic"
var _action_elapsed: float = 0
var _action_start: float = 0
var _windup: float = 0.28
var _recovery: float = 0.35
var _impacted: bool = false
var _recoil: Vector2 = Vector2.ZERO
var _grip: Sprite2D
const Aura = preload("res://scripts/hero_aura.gd")
const VISUAL_SOCKETS = {
    "idle": {"chest":Vector2(427,296),"head":Vector2(424,182),"back":Vector2(349,266)},
    "ready": {"chest":Vector2(432,291),"head":Vector2(429,178),"back":Vector2(354,257)},
    "windup": {"chest":Vector2(400,291),"head":Vector2(403,184),"back":Vector2(328,263)},
    "attack_contact": {"chest":Vector2(407,329),"head":Vector2(456,219),"back":Vector2(388,290)},
    "recovery": {"chest":Vector2(400,315),"head":Vector2(404,212),"back":Vector2(326,286)},
    "hit": {"chest":Vector2(420,310),"head":Vector2(416,207),"back":Vector2(345,281)}
}
var layer_sockets: Dictionary = {}
var attachments
var cape
var weapon_glow
var _upgrade_level=0
var fx_intensity=1.0

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    _art = Node2D.new()
    _art.name = "ArtRoot"
    add_child(_art)
    _body = Sprite2D.new()
    _body.name = "BodySprite"
    _body.centered = false
    _body.position = -PIVOT
    _palette = ShaderMaterial.new()
    _palette.shader = preload("res://assets/hero/cape_palette.gdshader")
    _body.material = _palette
    _art.add_child(_body)
    for id in ["chest", "shoulder", "head", "back", "wings"]:
        var socket = Node2D.new()
        socket.name = id.capitalize()+"Socket"
        _art.add_child(socket)
        layer_sockets[id] = socket
    aura = Aura.new()
    aura.name = "AuraLayer"
    aura.z_index = -2
    _art.add_child(aura)
    _socket = Node2D.new()
    _socket.name = "RightHandSocket"
    # Absolute world layers: enemy 3, hero 4, blade 12, fingers 13, impact 16.
    # The hand can cover its grip while the sword stays in front of an overlapping enemy.
    _socket.z_as_relative = false
    _socket.z_index = 12
    _art.add_child(_socket)
    _weapon = Sprite2D.new()
    _weapon.name = "ReplaceableSword"
    _weapon.centered = false
    _weapon.scale = Vector2.ONE * BLADE_SCALE
    _weapon.position = -BLADE_GRIP * BLADE_SCALE
    _socket.add_child(_weapon)
    weapon_glow=preload("res://scripts/presentation/weapon_upgrade_vfx.gd").new();weapon_glow.z_index=1;_weapon.add_child(weapon_glow)
    for state in Gate.HERO_STATES:
        _poses[state] = load(Gate.ROOT + "hero/" + state + ".png")
    hero_sets["realmwachter"]=_poses.duplicate()
    hero_sets["kaela"]={}
    for state in Gate.HERO_STATES+["defeated"]:hero_sets.kaela[state]=load("res://assets/roster67/kaela/"+state+".png")
    for name in Gate.WEAPONS:
        _weapons.append(load(Gate.ROOT + "weapons/" + name + ".png"))
    _grip=Sprite2D.new()
    _grip.name="GripOccluder"
    _grip.region_enabled=true
    _grip.z_as_relative=false
    _grip.z_index=13
    _grip.material=_palette
    _art.add_child(_grip)
    cape=preload("res://scripts/hero_cape.gd").new();cape.attach(self)
    attachments=preload("res://scripts/hero_attachments.gd").new()
    attachments.attach(self)
    _set_pose("idle")
    equip_weapon(_selected)
    set_look(_look, false)

func set_hero(id:String) -> void:
    if id==hero_id or not hero_sets.has(id):return
    hero_id=id;_poses=hero_sets[id];revive()
func hand(pose:String) -> Vector2:return Alternate.HANDS.get(pose,Alternate.HANDS.hit) if hero_id=="kaela" else HANDS.get(pose,HANDS.hit)
func angle(pose:String) -> float:return float(Alternate.ANGLES.get(pose,-45)) if hero_id=="kaela" else float(ANGLES.get(pose,-45))
func sockets(pose:String) -> Dictionary:return Alternate.SOCKETS.get(pose,Alternate.SOCKETS.hit) if hero_id=="kaela" else VISUAL_SOCKETS.get(pose,VISUAL_SOCKETS.hit)
func _set_pose(name: String) -> void:
    _pose = name
    if _body == null:
        return
    _body.texture = _poses.get(name)
    _body.position = -PIVOT
    _socket.position = hand(name) - PIVOT
    _socket.rotation_degrees = angle(name)
    _socket.z_index = _world_layer()+8
    if _grip:
        _grip.z_index=_world_layer()+9
        _grip.texture=_body.texture
        _grip.region_rect=Rect2(hand(name)-Vector2(10,10),Vector2(20,20))
        _grip.position=hand(name)-PIVOT
    for id in layer_sockets:
        var anchor: Vector2 = sockets(name).get(id,sockets(name).get("back",PIVOT))
        layer_sockets[id].position = anchor - PIVOT
    if attachments:attachments.sync_pose(self,name)
    if cape:cape.sync(self,name)

func _world_layer() -> int:
    var value=0
    var item:CanvasItem=self
    while item!=null:
        value+=item.z_index
        if not item.z_as_relative:break
        item=item.get_parent() as CanvasItem
    return value

func _process(delta: float) -> void:
    if _dead or _art == null:return
    _clock+=delta
    if _busy:
        if not external_clock:
            _action_elapsed+=delta
            _sample_action()
    else:
        _art.position=_recoil+Vector2(0,sin(_clock*2.6)*2)

func sync_clock(value: float) -> void:
    if _busy:
        _action_elapsed=maxf(0,value-_action_start)
        _sample_action()

func _sample_action() -> void:
    var frame=Timeline.sample(_action_id,_action_elapsed,_windup,_recovery)
    if frame.pose!=_pose:_set_pose(frame.pose)
    _art.position=frame.offset+_recoil
    _art.rotation=float(frame.get("art_rotation",0))
    if frame.has("weapon_angle"):_socket.rotation_degrees=angle(_pose)+float(frame.weapon_angle)
    if _pose=="windup":_socket.rotation_degrees=angle(_pose)-12*(1-clampf(_action_elapsed/maxf(_windup,0.01),0,1))
    if not _impacted and _action_elapsed>=_windup:
        _impacted=true;impact.emit()
    if frame.done:_finish_attack()

func equip_weapon(index: int) -> void:
    _selected = clampi(index, 0, _weapons.size() - 1)
    if _weapon != null and not _weapons.is_empty():
        _weapon.texture = _weapons[_selected]

func set_upgrade_tier(_level: int) -> void:
    _upgrade_level=clampi(_level,0,19)
    if weapon_glow:weapon_glow.configure(_upgrade_level,fx_intensity)

func set_look(id: String, evolution: bool = false) -> void:
    _look = id
    if _palette:
        _palette.set_shader_parameter("emerald",id == "emerald" and hero_id=="realmwachter")
        _palette.set_shader_parameter("astral",id == "astral" and hero_id=="realmwachter")
    if aura:
        aura.evolution = evolution
    if cape:cape.sync(self,_pose)

func set_gear(profile: Dictionary) -> void:
    if attachments:attachments.apply(self,profile)

func set_shield(active: bool, ratio: float = 1.0) -> void:
    if aura:
        aura.shielded = active
        aura.shield_ratio = ratio

func play_attack(is_skill: bool = false) -> bool:
    return play_action("sky_blade" if is_skill else "basic")

func play_action(id: String, windup: float=-1, recovery: float=-1, started_at: float=-1) -> bool:
    if _dead or _art==null:return false
    if _busy and (started_at<0 or started_at<_action_start+_windup+_recovery-0.001):return false
    var d:Dictionary=Definitions.all().get(id,{}) if id!="basic" else {"windup":0.28,"recovery":0.35}
    _action_id=id;_action_elapsed=0;_action_start=maxf(0,started_at)
    _windup=float(d.get("windup",0.28)) if windup<0 else windup
    _recovery=float(d.get("recovery",0.35)) if recovery<0 else recovery
    _busy=true;_impacted=false
    _sample_action()
    return true

func play_hit(blocked: bool = false) -> void:
    if _dead:
        return
    if _reaction and _reaction.is_running():
        _reaction.kill()
    # Reaction on the rig root leaves the scheduled weapon animation intact.
    _reaction = create_tween()
    modulate = Color("#a9e5ff") if blocked else Color("#ffb8ac")
    _recoil=Vector2(-8 if blocked else -18,0)
    if not _busy:_set_pose("hit")
    _reaction.tween_property(self,"_recoil",Vector2.ZERO,0.18)
    _reaction.parallel().tween_property(self,"modulate",Color.WHITE,0.24)
    _reaction.tween_callback(func():
        if not _busy: _set_pose("idle"))

func play_death() -> void:
    _dead = true
    _busy = false
    if _action and _action.is_running():
        _action.kill()
    _set_pose("defeated" if hero_id=="kaela" else "hit")
    _art.position = Vector2.ZERO
    var t=create_tween()
    t.tween_property(_art,"rotation_degrees",-25,0.4)
    t.parallel().tween_property(self,"modulate:a",0.4,0.4)

func revive() -> void:
    if _action and _action.is_running(): _action.kill()
    if _reaction and _reaction.is_running(): _reaction.kill()
    _dead = false
    _busy = false
    _recoil=Vector2.ZERO
    _art.rotation = 0
    _art.position = Vector2.ZERO
    modulate = Color.WHITE
    _set_pose("idle")

func _finish_attack() -> void:
    _art.position = Vector2.ZERO
    _art.rotation=0
    if not _dead:
        _set_pose("idle")
    _busy = false
    action_finished.emit()

func current_pose() -> String:
    return _pose

func weapon_is_modular() -> bool:
    return _weapon != null and _weapon.get_parent() == _socket and _body.get_parent() == _art


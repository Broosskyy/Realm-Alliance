extends Node2D
class_name RAProductionHero

# White-haired masked Realmwächter; six weapon-free hero sprites.
# Equipment remains a separate sprite, changed without modifying body texture.
signal impact
signal action_finished

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
const Aura = preload("res://scripts/hero_aura.gd")
const VISUAL_SOCKETS = {
    "idle": {"chest":Vector2(427,296),"head":Vector2(424,182),"back":Vector2(349,266)},
    "ready": {"chest":Vector2(432,291),"head":Vector2(429,178),"back":Vector2(354,257)},
    "windup": {"chest":Vector2(400,291),"head":Vector2(403,184),"back":Vector2(328,263)},
    "attack_contact": {"chest":Vector2(462,313),"head":Vector2(456,219),"back":Vector2(388,290)},
    "recovery": {"chest":Vector2(400,315),"head":Vector2(404,212),"back":Vector2(326,286)},
    "hit": {"chest":Vector2(420,310),"head":Vector2(416,207),"back":Vector2(345,281)}
}
var layer_sockets: Dictionary = {}

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
    _art.add_child(_socket)
    _weapon = Sprite2D.new()
    _weapon.name = "ReplaceableSword"
    _weapon.centered = false
    _weapon.scale = Vector2.ONE * BLADE_SCALE
    _weapon.position = -BLADE_GRIP * BLADE_SCALE
    _socket.add_child(_weapon)
    for state in Gate.HERO_STATES:
        _poses[state] = load(Gate.ROOT + "hero/" + state + ".png")
    for name in Gate.WEAPONS:
        _weapons.append(load(Gate.ROOT + "weapons/" + name + ".png"))
    _set_pose("idle")
    equip_weapon(_selected)
    set_look(_look, false)

func _set_pose(name: String) -> void:
    _pose = name
    if _body == null:
        return
    _body.texture = _poses.get(name)
    _body.position = -PIVOT
    _socket.position = HANDS[name] - PIVOT
    _socket.rotation_degrees = ANGLES[name]
    _socket.z_index = -1 if name in ["idle", "ready", "windup"] else 3
    for id in layer_sockets:
        var anchor: Vector2 = VISUAL_SOCKETS[name].get(id,VISUAL_SOCKETS[name].get("back",PIVOT))
        layer_sockets[id].position = anchor - PIVOT

func _process(delta: float) -> void:
    if _busy or _dead or _art == null:
        return
    _clock += delta
    _art.position.y = sin(_clock * 2.6) * 2.0

func equip_weapon(index: int) -> void:
    _selected = clampi(index, 0, _weapons.size() - 1)
    if _weapon != null and not _weapons.is_empty():
        _weapon.texture = _weapons[_selected]

func set_upgrade_tier(_level: int) -> void:
    # True equipable armor layers need additional authored source art.
    pass

func set_look(id: String, evolution: bool = false) -> void:
    _look = id
    if _palette:
        _palette.set_shader_parameter("emerald",id == "emerald")
    if aura:
        aura.evolution = evolution

func set_shield(active: bool, ratio: float = 1.0) -> void:
    if aura:
        aura.shielded = active
        aura.shield_ratio = ratio

func play_attack(is_skill: bool = false) -> bool:
    return play_action("sky_blade" if is_skill else "basic")

func play_action(id: String) -> bool:
    if _busy or _dead or _art == null:
        return false
    _busy = true
    _art.position = Vector2.ZERO
    _set_pose("ready")
    _action = create_tween()
    match id:
        "arcane_eye", "guardian_wall":
            _action.tween_property(_art,"position:y",-8.0,0.14)
            _action.tween_interval(0.10 if id == "arcane_eye" else 0.01)
            _action.tween_callback(func(): impact.emit())
            _action.tween_property(_art,"position",Vector2.ZERO,0.27 if id == "arcane_eye" else 0.01)
        "rage_flame":
            _set_pose("windup")
            _action.tween_property(_art,"position",Vector2(-8,-12),0.28)
            _action.tween_callback(func(): _set_pose("attack_contact"))
            _action.tween_property(_art,"position",Vector2(24,0),0.14)
            _action.tween_callback(func(): impact.emit())
            _action.tween_callback(func(): _set_pose("recovery"))
            _action.tween_property(_art,"position",Vector2.ZERO,0.32)
        _:
            _action.tween_interval(0.04)
            _action.tween_callback(func(): _set_pose("windup"))
            _action.tween_property(_art,"position:x",-14.0,0.12)
            _action.tween_callback(func(): _set_pose("attack_contact"))
            _action.tween_property(_art,"position:x",46.0 if id == "sky_blade" else 24.0,0.12)
            _action.tween_callback(func(): impact.emit())
            _action.tween_interval(0.04)
            _action.tween_callback(func(): _set_pose("recovery"))
            _action.tween_property(_art,"position",Vector2.ZERO,0.28)
    _action.tween_callback(_finish_attack)
    return true

func play_hit(blocked: bool = false) -> void:
    if _dead:
        return
    if _reaction and _reaction.is_running():
        _reaction.kill()
    # Reaction on the rig root leaves the scheduled weapon animation intact.
    _reaction = create_tween()
    modulate = Color("#a9e5ff") if blocked else Color("#ffb8ac")
    position.x = -193 if blocked else -202
    if not _busy:
        _set_pose("hit")
    _reaction.tween_property(self,"position:x",-185,0.18)
    _reaction.parallel().tween_property(self,"modulate",Color.WHITE,0.24)
    _reaction.tween_callback(func():
        if not _busy: _set_pose("idle"))

func play_death() -> void:
    _dead = true
    _busy = false
    if _action and _action.is_running():
        _action.kill()
    _set_pose("hit")
    _art.position = Vector2.ZERO
    var t=create_tween()
    t.tween_property(_art,"rotation_degrees",-25,0.4)
    t.parallel().tween_property(self,"modulate:a",0.4,0.4)

func revive() -> void:
    if _action and _action.is_running(): _action.kill()
    if _reaction and _reaction.is_running(): _reaction.kill()
    _dead = false
    _busy = false
    position.x = -185
    _art.rotation = 0
    _art.position = Vector2.ZERO
    modulate = Color.WHITE
    _set_pose("idle")

func _finish_attack() -> void:
    _art.position = Vector2.ZERO
    if not _dead:
        _set_pose("idle")
    _busy = false
    action_finished.emit()

func current_pose() -> String:
    return _pose

func weapon_is_modular() -> bool:
    return _weapon != null and _weapon.get_parent() == _socket and _body.get_parent() == _art


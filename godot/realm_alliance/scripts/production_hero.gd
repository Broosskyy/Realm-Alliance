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
const HANDS := {
    "idle": Vector2(497.0, 345.0),
    "ready": Vector2(508.0, 335.0),
    "windup": Vector2(431.0, 280.0),
    "attack_contact": Vector2(535.0, 332.0),
    "recovery": Vector2(471.0, 330.0),
    "hit": Vector2(432.0, 338.0)
}
const ANGLES := {
    "idle": 53.0, "ready": -14.0, "windup": -75.0,
    "attack_contact": 16.0, "recovery": 42.0, "hit": 78.0
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

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    _art = Node2D.new()
    _art.name = "ArtRoot"
    add_child(_art)
    _body = Sprite2D.new()
    _body.name = "BodySprite"
    _body.centered = false
    _body.position = -PIVOT
    _art.add_child(_body)
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

func _set_pose(name: String) -> void:
    _pose = name
    if _body == null:
        return
    _body.texture = _poses.get(name)
    _body.position = -PIVOT
    _socket.position = HANDS[name] - PIVOT
    _socket.rotation_degrees = ANGLES[name]
    _socket.z_index = -1 if name in ["idle", "ready", "windup"] else 3

func _process(delta: float) -> void:
    if _busy or _art == null:
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

func play_attack(is_skill: bool = false) -> bool:
    if _busy or _art == null:
        return false
    _busy = true
    _art.position = Vector2.ZERO
    _set_pose("ready")
    var t: Tween = create_tween()
    t.tween_interval(0.06)
    t.tween_callback(func(): _set_pose("windup"))
    t.tween_property(_art, "position:x", -16.0 if is_skill else -10.0, 0.13)
    t.tween_callback(func(): _set_pose("attack_contact"))
    t.tween_property(_art, "position:x", 36.0 if is_skill else 25.0, 0.12)
    t.tween_callback(func(): impact.emit())
    t.tween_interval(0.045)
    t.tween_callback(func(): _set_pose("recovery"))
    t.tween_property(_art, "position", Vector2.ZERO, 0.19)
    t.tween_callback(_finish_attack)
    return true

func _finish_attack() -> void:
    _art.position = Vector2.ZERO
    _set_pose("idle")
    _busy = false
    action_finished.emit()

func current_pose() -> String:
    return _pose

func weapon_is_modular() -> bool:
    return _weapon != null and _weapon.get_parent() == _socket and _body.get_parent() == _art

extends Node2D
class_name RABramblePreviewHero

# BRAMBLE art-pipeline proof only — this is NOT the canonical REALM ALLIANCE hero.
# The body and the sword remain separate textures/nodes at every keypose.
signal impact
signal action_finished

const IDLE = preload("res://assets/preview/bramble/hero/idle.png")
const READY = preload("res://assets/preview/bramble/hero/ready.png")
const WINDUP = preload("res://assets/preview/bramble/hero/windup.png")
const CONTACT = preload("res://assets/preview/bramble/hero/contact.png")
const RECOVERY = preload("res://assets/preview/bramble/hero/recovery.png")
const SWORD = preload("res://assets/preview/bramble/weapon/longsword.png")

# Source files are NOT on one canvas: idle = 306x524, melee keyposes = 512x512.
# All image opaque bounds were measured with Godot Image.get_used_rect().
# Their true alpha-contact lines are y=494 (idle) and y=464 (action poses).
# Explicit pose pivots preserve a stable world-ground point across transitions.
const GROUND_PIXELS := {
    "idle": Vector2(153.0, 494.0),
    "ready": Vector2(256.0, 464.0),
    "windup": Vector2(256.0, 464.0),
    "contact": Vector2(256.0, 464.0),
    "recovery": Vector2(256.0, 464.0)
}
# These hand points were visually calibrated against source keyposes, but remain
# review coordinates (not production-certified per-pose hand metadata).
# The sword anchor is at the wrapped grip, not at the bottom pommel.
const SWORD_GRIP_PIXEL := Vector2(112.0, 382.0)
const GRIP_COORDS := {
    "idle": Vector2(229, 352),
    "ready": Vector2(256, 322),
    "windup": Vector2(167, 250),
    "contact": Vector2(340, 302),
    "recovery": Vector2(259, 352)
}
const ROTATIONS := {"idle": 23.0, "ready": -3.0, "windup": -102.0, "contact": 52.0, "recovery": 17.0}
const POSES := {"idle": IDLE, "ready": READY, "windup": WINDUP, "contact": CONTACT, "recovery": RECOVERY}

var _visual: Node2D
var _body: Sprite2D
var _socket: Node2D
var _sword: Sprite2D
var _busy: bool = false
var _idle_clock: float = 0.0
var _active_pose: String = "idle"
var _weapon_index: int = 0

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    _visual = Node2D.new()
    _visual.name = "ArtRoot"
    add_child(_visual)

    _body = Sprite2D.new()
    _body.name = "BodySprite"
    _body.centered = false
    _body.position = -GROUND_PIXELS["idle"]
    _body.texture = IDLE
    _visual.add_child(_body)

    _socket = Node2D.new()
    _socket.name = "RightHandSocket"
    _visual.add_child(_socket)
    _sword = Sprite2D.new()
    _sword.name = "SeparateSwordSprite"
    _sword.texture = SWORD
    _sword.centered = false
    _sword.scale = Vector2.ONE * 0.57
    # The wrapped handle is held at the hand. Anchoring to the pommel instead
    # leaves an obvious floating gap and makes every attack pose look detached.
    _sword.position = -SWORD_GRIP_PIXEL * _sword.scale
    _socket.add_child(_sword)
    _set_pose("idle")
    equip_weapon(_weapon_index)

func _set_pose(id: String) -> void:
    if _body == null:
        return
    _active_pose = id
    _body.texture = POSES[id]
    _body.position = -GROUND_PIXELS[id]
    _socket.position = GRIP_COORDS[id] - GROUND_PIXELS[id]
    _socket.rotation_degrees = ROTATIONS[id]
    _socket.z_index = -1 if id == "windup" else 8

func _process(delta: float) -> void:
    if _busy or _visual == null:
        return
    _idle_clock += delta
    _visual.position.y = sin(_idle_clock * 2.8) * 2.0

func equip_weapon(index: int) -> void:
    _weapon_index = clampi(index, 0, 2)
    if _sword == null:
        return
    # Preview only: the one proven sword texture is colored to reflect model states.
    _sword.modulate = [Color.WHITE, Color("#a7eaff"), Color("#ffc59a")][_weapon_index]

func set_upgrade_tier(_level: int) -> void:
    # The actual REALM modular armor/evolution visuals need purpose-authored overlays.
    pass

func play_attack(is_skill: bool = false) -> bool:
    if _busy or _visual == null:
        return false
    _busy = true
    _visual.position = Vector2.ZERO
    _set_pose("ready")
    var animation: Tween = create_tween()
    animation.tween_interval(0.065)
    animation.tween_callback(func(): _set_pose("windup"))
    animation.tween_property(_visual, "position:x", -17.0 if is_skill else -10.0, 0.14)
    animation.tween_callback(func(): _set_pose("contact"))
    animation.tween_property(_visual, "position:x", 35.0 if is_skill else 26.0, 0.10)
    animation.tween_callback(func(): impact.emit())
    animation.tween_interval(0.045)
    animation.tween_callback(func(): _set_pose("recovery"))
    animation.tween_property(_visual, "position", Vector2.ZERO, 0.18)
    animation.tween_callback(_finish_attack)
    return true

func _finish_attack() -> void:
    _visual.position = Vector2.ZERO
    _set_pose("idle")
    _busy = false
    action_finished.emit()

func preview_pose() -> String:
    return _active_pose

func socket_is_separate() -> bool:
    return _sword != null and _body != null and _sword.get_parent() == _socket and _socket.get_parent() == _visual

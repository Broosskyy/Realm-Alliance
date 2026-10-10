extends Node2D
class_name RABramblePreviewEnemy

# Temporary BRAMBLE creature for validating shared art style in REALM's arena.
# Do not register this as an original REALM monster or overwrite BRAMBLE originals.
const IDLE = preload("res://assets/preview/bramble/enemy/idle.png")
const ATTACK = preload("res://assets/preview/bramble/enemy/attack.png")
const HIT = preload("res://assets/preview/bramble/enemy/hit.png")
const DEFEATED = preload("res://assets/preview/bramble/enemy/defeated.png")

var wave: int = 1
var health_ratio: float = 1.0
var _base_scale: Vector2 = Vector2.ONE
var _display_scale: Vector2 = Vector2.ONE
var _base_position: Vector2 = Vector2.ZERO
var _sprite: Sprite2D
var _motion: Tween
var _clock: float = 0.0
var _dying: bool = false
var _bar_y: float = -395.0

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    _base_scale = scale
    _display_scale = scale
    _base_position = position
    _sprite = Sprite2D.new()
    _sprite.name = "CreatureSprite"
    _sprite.texture = IDLE
    # Sprite feet stay on the character's local ground y=0.
    _sprite.position = Vector2(0.0, -float(IDLE.get_height()) * 0.5)
    _bar_y = -float(IDLE.get_height()) - 18.0
    add_child(_sprite)

func show_wave(number: int) -> void:
    if _motion != null and _motion.is_running():
        _motion.kill()
    wave = number
    health_ratio = 1.0
    _dying = false
    _display_scale = _base_scale * (1.14 if wave % 5 == 0 else 1.0)
    scale = _display_scale
    position = _base_position
    modulate = Color.WHITE
    if _sprite != null:
        _sprite.texture = IDLE
        _sprite.position.y = -float(IDLE.get_height()) * 0.5
        _sprite.modulate = Color.WHITE
    queue_redraw()

func set_health(current_hp: int, maximum_hp: int) -> void:
    health_ratio = clampf(float(current_hp) / float(maxi(maximum_hp, 1)), 0.0, 1.0)
    queue_redraw()

func _process(delta: float) -> void:
    if _sprite == null or _dying or (_motion != null and _motion.is_running()):
        return
    _clock += delta
    _sprite.position.y = -float(IDLE.get_height()) * 0.5 + sin(_clock * 2.1) * 3.0
    scale = _display_scale * (1.0 + sin(_clock * 1.7) * 0.009)

func _draw() -> void:
    var boss: bool = wave % 5 == 0
    var width: float = 202.0
    var x: float = -width * 0.5
    draw_rect(Rect2(x - 6.0, _bar_y - 6.0, width + 12.0, 20.0), Color("#0c1724"))
    draw_rect(Rect2(x, _bar_y, width, 8.0), Color("#3d4d52"))
    draw_rect(Rect2(x, _bar_y, width * health_ratio, 8.0), Color("#f0a170") if boss else Color("#78d9a8"))
    draw_rect(Rect2(x - 6.0, _bar_y - 6.0, width + 12.0, 20.0), Color("#d5b97a") if boss else Color("#8c9b9b"), false, 2.0)

func play_hit() -> void:
    if _dying or _sprite == null:
        return
    if _motion != null and _motion.is_running():
        _motion.kill()
    _sprite.texture = HIT
    _sprite.modulate = Color("#ffedcc")
    _motion = create_tween()
    _motion.tween_property(self, "position:x", _base_position.x + 9.0, 0.08)
    _motion.tween_property(self, "position:x", _base_position.x, 0.12)
    _motion.parallel().tween_property(_sprite, "modulate", Color.WHITE, 0.12)
    _motion.tween_callback(_restore_idle)

func _restore_idle() -> void:
    if not _dying and _sprite != null:
        _sprite.texture = IDLE

func play_death() -> void:
    if _motion != null and _motion.is_running():
        _motion.kill()
    _dying = true
    _sprite.texture = DEFEATED
    _sprite.modulate = Color.WHITE
    _motion = create_tween()
    _motion.set_parallel(true)
    _motion.tween_property(self, "position:y", _base_position.y + 20.0, 0.30)
    _motion.tween_property(self, "modulate:a", 0.0, 0.47).set_delay(0.12)
    _motion.tween_property(self, "scale", _display_scale * 0.88, 0.47)

func preview_has_four_states() -> bool:
    return IDLE != null and ATTACK != null and HIT != null and DEFEATED != null

extends Node2D
class_name RABramblePreviewSlash

# Eight authored BRAMBLE effect frames. Plays as a non-interactive stage-local VFX.
const FRAMES: Array[Texture2D] = [
    preload("res://assets/preview/bramble/vfx/00_glint.png"),
    preload("res://assets/preview/bramble/vfx/01_arc_start.png"),
    preload("res://assets/preview/bramble/vfx/02_arc_grow.png"),
    preload("res://assets/preview/bramble/vfx/03_slash_peak.png"),
    preload("res://assets/preview/bramble/vfx/04_impact_peak.png"),
    preload("res://assets/preview/bramble/vfx/05_burst.png"),
    preload("res://assets/preview/bramble/vfx/06_arc_fade.png"),
    preload("res://assets/preview/bramble/vfx/07_motes_fade.png")
]

var _sprite: Sprite2D
var _elapsed: float = 0.0
var _frame_time: float = 0.047

func configure(is_skill: bool) -> void:
    scale = Vector2.ONE * (0.66 if is_skill else 0.51)
    _frame_time = 0.055 if is_skill else 0.046

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    _sprite = Sprite2D.new()
    _sprite.name = "EightFrameSlash"
    _sprite.texture = FRAMES[0]
    _sprite.z_index = 10
    add_child(_sprite)

func _process(delta: float) -> void:
    _elapsed += delta
    var index: int = int(floor(_elapsed / _frame_time))
    if index >= FRAMES.size():
        queue_free()
    elif _sprite != null:
        _sprite.texture = FRAMES[index]

func preview_frame_count() -> int:
    return FRAMES.size()

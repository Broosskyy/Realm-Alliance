extends Node2D
class_name RAProductionEnemy

const ROOT: String = "res://assets/production/enemy/"
const BOAR_FRAMES={"idle":preload("res://assets/enemies/ember_boar/idle.png"),"attack":preload("res://assets/enemies/ember_boar/attack.png"),"hit":preload("res://assets/enemies/ember_boar/hit.png"),"defeated":preload("res://assets/enemies/ember_boar/defeated.png")}
const GROUND: Vector2 = Vector2(368.0, 704.0)

var show_local_health: bool = true
var _ground: Vector2 = GROUND
var _visual: String = "golem"
var _kind: String = "normal"
var wave: int = 1
var health_ratio: float = 1.0
var _sprite: Sprite2D
var _frames: Dictionary = {}
var _base_scale: Vector2 = Vector2.ONE
var _display_scale: Vector2 = Vector2.ONE
var _base_pos: Vector2 = Vector2.ZERO
var _animation: Tween
var _clock: float = 0.0
var _recoil: Vector2 = Vector2.ZERO
var _motion: Vector2 = Vector2.ZERO
var _reaction: Tween
var _attacking: bool = false
var _dying: bool = false

func _ready() -> void:
    texture_filter = CanvasItem.TEXTURE_FILTER_LINEAR
    _base_scale = scale
    _display_scale = scale
    _base_pos = position
    _sprite = Sprite2D.new()
    _sprite.name = "GolemSprite"
    _sprite.centered = false
    _sprite.position = -_ground
    add_child(_sprite)
    _frames = {
        "idle": load(ROOT + "golem_idle_ready.png"),
        "attack": load(ROOT + "golem_attack.png"),
        "hit": load(ROOT + "golem_hit_damage.png"),
        "defeated": load(ROOT + "golem_defeated.png")
    }
    _set_pose("idle")

func _set_pose(state: String) -> void:
    if _sprite != null:
        _sprite.texture = _frames[state]
        _sprite.position = -_ground

func configure_enemy(d: Dictionary) -> void:
    _visual = str(d.visual)
    _kind = str(d.kind)
    _ground = Vector2(256,480) if _visual=="boar" else (Vector2(320,488) if _visual == "slime" else GROUND)
    _sprite.material=null
    if d.get("palette","")=="ember":
        var palette=ShaderMaterial.new();palette.shader=preload("res://assets/world65/ember_palette.gdshader");_sprite.material=palette
    if _visual == "boar":
        _frames=BOAR_FRAMES.duplicate()
    elif _visual == "slime":
        for state in ["idle","attack","hit","defeated"]:
            _frames[state] = load("res://assets/expansion/slime/"+state+".png")
    else:
        _frames = {"idle":load(ROOT+"golem_idle_ready.png"),"attack":load(ROOT+"golem_attack.png"),"hit":load(ROOT+"golem_hit_damage.png"),"defeated":load(ROOT+"golem_defeated.png")}
    _set_pose("idle")

func play_telegraph(duration: float=0.85, pattern: String="single") -> void:
    if _dying:return
    if _animation and _animation.is_running():_animation.kill()
    _attacking=true
    _sprite.modulate=Color("#ff9487") if pattern in ["heavy","eruption","aftershock"] else Color("#ffce94")
    _animation=create_tween()
    _animation.tween_property(self,"_motion",Vector2(12,0),duration*0.65).set_trans(Tween.TRANS_SINE)
    _animation.tween_callback(func():_set_pose("attack"))
    _animation.tween_property(self,"_motion",Vector2(-28,0),duration*0.35).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)

func play_attack() -> void:
    if _dying:return
    if _animation and _animation.is_running():_animation.kill()
    _attacking=true
    _set_pose("attack")
    _sprite.modulate=Color.WHITE
    _motion=Vector2(-28,0)
    _animation=create_tween()
    _animation.tween_interval(0.06)
    _animation.tween_property(self,"_motion",Vector2.ZERO,0.24).set_trans(Tween.TRANS_SINE)
    _animation.tween_callback(func():_attacking=false;_return_idle())

func set_layout_scale(value: float) -> void:
    _base_scale = Vector2.ONE * value
    _display_scale = _base_scale * (1.09 if _kind == "boss" or wave % 5 == 0 else 1.0)
    if not _dying:
        scale = _display_scale

func show_wave(number: int) -> void:
    if _animation != null and _animation.is_running():
        _animation.kill()
    wave = number
    _dying = false
    _attacking=false
    _motion=Vector2.ZERO
    _recoil=Vector2.ZERO
    if _reaction and _reaction.is_running():_reaction.kill()
    health_ratio = 1.0
    _display_scale = _base_scale * (1.09 if _kind == "boss" or wave % 5 == 0 else 1.0)
    scale = _display_scale
    position = _base_pos
    modulate = Color.WHITE
    _sprite.modulate = Color.WHITE
    _set_pose("idle")
    queue_redraw()

func set_health(current_hp: int, maximum_hp: int) -> void:
    health_ratio = clampf(float(current_hp) / float(maxi(maximum_hp, 1)), 0.0, 1.0)
    queue_redraw()

func _process(delta: float) -> void:
    if _sprite:_sprite.position=-_ground+_motion+_recoil
    if _dying or (_animation != null and _animation.is_running()):
        return
    _clock += delta
    scale = _display_scale * (1.0 + sin(_clock * 2.0) * 0.008)

func _draw() -> void:
    if not show_local_health:
        return
    var y: float = -666.0
    var width: float = 224.0
    var x: float = -width * 0.5
    var boss: bool = wave % 5 == 0
    draw_rect(Rect2(x - 5.0, y - 5.0, width + 10.0, 21.0), Color("#081624", 0.92))
    draw_rect(Rect2(x, y, width, 10.0), Color("#344850"))
    draw_rect(Rect2(x, y, width * health_ratio, 10.0), Color("#f3876b") if boss else Color("#72dbb2"))
    draw_rect(Rect2(x - 5.0, y - 5.0, width + 10.0, 21.0), Color("#d5a870") if boss else Color("#aec2c0"), false, 2.0)

func play_hit() -> void:
    if _dying or _sprite==null:return
    if _reaction and _reaction.is_running():_reaction.kill()
    if not _attacking:_set_pose("hit")
    _sprite.modulate=Color("#fff1d7")
    _reaction=create_tween()
    _reaction.tween_property(self,"_recoil",Vector2(12,0),0.04)
    _reaction.tween_property(self,"_recoil",Vector2.ZERO,0.16)
    _reaction.parallel().tween_property(_sprite,"modulate",Color.WHITE,0.15)
    _reaction.tween_callback(_return_idle)

func _return_idle() -> void:
    if not _dying and not _attacking:
        _set_pose("idle")

func play_death() -> void:
    if _animation != null and _animation.is_running():
        _animation.kill()
    _dying = true
    _attacking=false
    if _reaction and _reaction.is_running():_reaction.kill()
    _set_pose("defeated")
    _sprite.modulate = Color.WHITE
    _animation = create_tween()
    _animation.set_parallel(true)
    _animation.tween_property(self, "scale", _display_scale * 0.94, 0.40)
    _animation.tween_property(self, "modulate:a", 0.0, 0.50).set_delay(0.13)


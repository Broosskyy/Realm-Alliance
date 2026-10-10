extends Node2D
class_name RAHeroRig

signal impact
signal action_finished

# Every visual part is its own node. WeaponSocket is a child of HandPivot
# so the weapon *must* follow animation transforms without CSS-like offsets.
var _visual: Node2D
var _arm: Node2D
var _weapon_socket: Node2D
var _armor: Polygon2D
var _helmet: Polygon2D
var _wing: Polygon2D
var _busy: bool = false
var _idle_time: float = 0.0

func _ready() -> void:
    _create_parts()

func _shape(parent: Node2D, points: PackedVector2Array, color: Color, z: int = 0) -> Polygon2D:
    var item := Polygon2D.new()
    item.polygon = points
    item.color = color
    item.z_index = z
    parent.add_child(item)
    return item

func _create_parts() -> void:
    _visual = Node2D.new()
    _visual.name = "BodyRoot"
    add_child(_visual)
    _wing = _shape(_visual, PackedVector2Array([
        Vector2(-20,-96), Vector2(-90,-140), Vector2(-76,-72), Vector2(-43,-34)
    ]), Color("#7790d0", 0.64), -5)
    _shape(_visual, PackedVector2Array([
        Vector2(-27,-81), Vector2(-43,-36), Vector2(-27,-10),
        Vector2(13,-13), Vector2(34,-75)
    ]), Color("#3b4471"), -3)
    _shape(_visual, PackedVector2Array([
        Vector2(-26,-48), Vector2(-8,-48), Vector2(-10,-4), Vector2(-28,-4)
    ]), Color("#424b6b"), -1)
    _shape(_visual, PackedVector2Array([
        Vector2(2,-48), Vector2(24,-48), Vector2(22,-4), Vector2(1,-4)
    ]), Color("#333d61"), -1)
    _shape(_visual, PackedVector2Array([
        Vector2(-33,-9), Vector2(-10,-9), Vector2(-8,3), Vector2(-36,3)
    ]), Color("#162033"), 1)
    _shape(_visual, PackedVector2Array([
        Vector2(1,-9), Vector2(29,-9), Vector2(28,3), Vector2(-1,3)
    ]), Color("#162033"), 1)
    _armor = _shape(_visual, PackedVector2Array([
        Vector2(-35,-102), Vector2(30,-102), Vector2(37,-51),
        Vector2(18,-38), Vector2(-24,-38), Vector2(-40,-53)
    ]), Color("#687e9b"), 1)
    _shape(_visual, PackedVector2Array([
        Vector2(-34,-96), Vector2(30,-96), Vector2(20,-85), Vector2(-24,-85)
    ]), Color("#d2ae72"), 2)
    _shape(_visual, PackedVector2Array([
        Vector2(-16,-139), Vector2(17,-139), Vector2(23,-113),
        Vector2(11,-99), Vector2(-14,-99), Vector2(-25,-114)
    ]), Color("#edcaa3"), 3)
    _helmet = _shape(_visual, PackedVector2Array([
        Vector2(-26,-127), Vector2(-18,-152), Vector2(17,-152),
        Vector2(30,-128), Vector2(20,-121), Vector2(-18,-121)
    ]), Color("#637695"), 4)
    _shape(_visual, PackedVector2Array([
        Vector2(-5,-151), Vector2(8,-169), Vector2(13,-145)
    ]), Color("#e1ba70"), 5)
    _arm = Node2D.new()
    _arm.name = "RightArmPivot"
    _arm.position = Vector2(27,-93)
    _visual.add_child(_arm)
    _shape(_arm, PackedVector2Array([
        Vector2(-11,-9), Vector2(12,-9), Vector2(14,40),
        Vector2(-7,43)
    ]), Color("#526b8e"), 6)
    _shape(_arm, PackedVector2Array([
        Vector2(-8,31), Vector2(15,32), Vector2(14,46), Vector2(-8,46)
    ]), Color("#cfab86"), 7)
    _weapon_socket = Node2D.new()
    _weapon_socket.name = "WeaponSocket"
    _weapon_socket.position = Vector2(5,41)
    _weapon_socket.rotation_degrees = 30.0
    _arm.add_child(_weapon_socket)
    equip_weapon(0)
    set_upgrade_tier(0)

func equip_weapon(index: int) -> void:
    if _weapon_socket == null:
        return
    for existing in _weapon_socket.get_children():
        _weapon_socket.remove_child(existing)
        existing.queue_free()
    var palette: Array[Color] = [
        Color("#e2e7f0"), Color("#60d9fa"), Color("#ffae70")
    ]
    var color: Color = palette[clampi(index,0,2)]
    # Blade geometry lives in the weapon's local coordinates and rotates with the hand.
    _shape(_weapon_socket, PackedVector2Array([
        Vector2(-7,-18), Vector2(-8,-85), Vector2(0,-111),
        Vector2(8,-85), Vector2(7,-18)
    ]), color, 10)
    _shape(_weapon_socket, PackedVector2Array([
        Vector2(-25,-19), Vector2(25,-19), Vector2(19,-11), Vector2(-19,-11)
    ]), Color("#d8b97b"), 11)
    _shape(_weapon_socket, PackedVector2Array([
        Vector2(-4,-10), Vector2(4,-10), Vector2(4,23), Vector2(-4,23)
    ]), Color("#493a3d"), 11)
    _shape(_weapon_socket, PackedVector2Array([
        Vector2(-8,20), Vector2(8,20), Vector2(6,28), Vector2(-6,28)
    ]), Color("#e8b96f"), 11)

func set_upgrade_tier(level: int) -> void:
    if _armor == null:
        return
    if level >= 10:
        _armor.color = Color("#a079d3")
        _helmet.color = Color("#b18edd")
        _wing.color = Color("#a589ec",0.76)
    elif level >= 4:
        _armor.color = Color("#967d48")
        _helmet.color = Color("#d9b56a")
        _wing.color = Color("#d9bb82",0.64)
    else:
        _armor.color = Color("#687e9b")
        _helmet.color = Color("#637695")
        _wing.color = Color("#7790d0",0.64)

func _process(delta: float) -> void:
    if _visual == null or _busy:
        return
    _idle_time += delta
    _visual.position.y = sin(_idle_time * 2.6) * 2.5

func play_attack(is_skill: bool = false) -> bool:
    if _busy:
        return false
    _busy = true
    # Three intentional beats: anticipation, strike and recovery.
    # The weapon socket is parented to the hand pivot throughout.
    _visual.position = Vector2.ZERO
    _visual.rotation_degrees = 0.0
    var animation: Tween = create_tween()
    animation.set_trans(Tween.TRANS_SINE)
    animation.set_ease(Tween.EASE_OUT)
    animation.set_parallel(true)
    animation.tween_property(_arm, "rotation_degrees", -84.0 if is_skill else -56.0, 0.13)
    animation.tween_property(_visual, "position:x", -15.0 if is_skill else -9.0, 0.13)
    animation.tween_property(_visual, "rotation_degrees", -6.0 if is_skill else -3.0, 0.13)
    animation.set_parallel(false)
    animation.tween_property(_arm, "rotation_degrees", 106.0 if is_skill else 83.0, 0.13)
    animation.parallel().tween_property(_visual, "position:x", 36.0 if is_skill else 24.0, 0.13)
    animation.parallel().tween_property(_visual, "rotation_degrees", 7.0 if is_skill else 4.0, 0.13)
    animation.tween_callback(func(): impact.emit())
    animation.set_parallel(true)
    animation.tween_property(_arm, "rotation_degrees", 0.0, 0.20)
    animation.tween_property(_visual, "position", Vector2.ZERO, 0.24)
    animation.tween_property(_visual, "rotation_degrees", 0.0, 0.24)
    animation.set_parallel(false)
    animation.tween_callback(_finish_attack)
    return true

func _finish_attack() -> void:
    _arm.rotation_degrees = 0.0
    _visual.rotation_degrees = 0.0
    _visual.position = Vector2.ZERO
    _busy = false
    action_finished.emit()

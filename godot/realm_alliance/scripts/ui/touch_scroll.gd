extends ScrollContainer
class_name RATouchScroll
# Handle real screen-touch events before child buttons consume emulated mouse
# presses. One deepest visible scroll view owns each gesture in its viewport.
var _finger=-1
var _origin=Vector2.ZERO
var _previous=Vector2.ZERO
var _start_scroll=0.0
var _dragging=false
var _velocity=0.0
var _floating_scroll=0.0
const DRAG_PIXELS=12.0
func _ready() -> void:
    add_to_group("realm_touch_scroll")
    horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
    mouse_filter=Control.MOUSE_FILTER_STOP
    # Native mouse wheel stays enabled; real touch is handled independently of
    # DisplayServer's touchscreen hint and without a second emulated drag.
    scroll_deadzone=2147483647
func _point(value:Vector2) -> Vector2:
    return get_global_transform_with_canvas().affine_inverse()*value
func _contains(value:Vector2) -> bool:
    if not is_visible_in_tree() or not get_window().visible:return false
    var local=_point(value)
    if not Rect2(Vector2.ZERO,size).has_point(local):return false
    var node=get_parent()
    while node is Control:
        if node.clip_contents and not node.get_global_rect().has_point(value):return false
        node=node.get_parent()
    return true
func _owns(value:Vector2) -> bool:
    if not _contains(value):return false
    for other in get_tree().get_nodes_in_group("realm_touch_scroll"):
        if other!=self and other.get_viewport()==get_viewport() and is_ancestor_of(other) and other._contains(value):return false
    return true
func _input(event:InputEvent) -> void:
    if event is InputEventScreenTouch:
        if event.pressed:
            if _finger==-1 and _owns(event.position):
                _finger=event.index;_origin=_point(event.position);_previous=_origin
                _start_scroll=scroll_vertical;_velocity=0;_dragging=false
        elif event.index==_finger:
            if _dragging:
                propagate_notification(Control.NOTIFICATION_SCROLL_END)
                get_viewport().set_input_as_handled()
            _finger=-1;_floating_scroll=scroll_vertical
    elif event is InputEventScreenDrag and event.index==_finger:
        var point=_point(event.position)
        var physical_scale=get_global_transform_with_canvas().get_scale().y*get_viewport().get_final_transform().get_scale().y
        if not _dragging and absf(point.y-_origin.y)*physical_scale>=DRAG_PIXELS:
            _dragging=true
            propagate_notification(Control.NOTIFICATION_SCROLL_BEGIN)
        if _dragging:
            scroll_vertical=roundi(_start_scroll+_origin.y-point.y)
            _floating_scroll=scroll_vertical
            _velocity=clampf(-(point.y-_previous.y)/maxf(get_process_delta_time(),.008),-2200,2200)
            get_viewport().set_input_as_handled()
        _previous=point
func _process(delta:float) -> void:
    if not is_visible_in_tree():
        _finger=-1;_velocity=0;return
    if _finger>=0 or absf(_velocity)<8:return
    _floating_scroll+=_velocity*delta
    var before=scroll_vertical
    scroll_vertical=roundi(_floating_scroll)
    _velocity=move_toward(_velocity,0,4800*delta)
    if scroll_vertical==before and absf(_floating_scroll-before)>2:_velocity=0

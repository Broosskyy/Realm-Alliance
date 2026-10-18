extends RefCounted
class_name RACameraFeedback
var intensity: float = 1.0
var hold: float = 0
var shake: float = 0
var clock: float = 0
func impact(strength: float, freeze: float = 0.035) -> void:
    if intensity<=0:return
    shake=maxf(shake,minf(strength,7)*intensity)
    hold=maxf(hold,freeze*intensity)
func step(delta: float) -> float:
    clock+=delta
    shake=move_toward(shake,0,delta*34)
    if hold>0:
        hold=maxf(0,hold-delta)
        return 0
    return delta
func offset() -> Vector2:
    return Vector2(sin(clock*139),cos(clock*113))*shake
func reset() -> void:
    hold=0;shake=0

extends RefCounted
class_name RABossPhase
# Pure simulation state; presentation consumes emitted phase/break events.
var meter=0
var break_until=0.0
var recovery_until=0.0
var enraged=false
const LIMIT=10
func reset() -> void:
    meter=0;break_until=0.0;recovery_until=0.0;enraged=false
func contact(now: float,weight: int) -> bool:
    if now<recovery_until:return false
    meter=mini(LIMIT,meter+weight)
    if meter<LIMIT:return false
    meter=0;break_until=now+1.6;recovery_until=now+5.5;return true
func snapshot() -> Dictionary:
    return {"schema":1,"meter":meter,"break_until":break_until,"recovery_until":recovery_until,"enraged":enraged}
func restore(d: Dictionary) -> bool:
    if d.is_empty():return true
    var validate=preload("res://scripts/systems/domain_validation.gd")
    if not validate.header(d) or not validate.integer(d.get("meter"),0,LIMIT) or not d.get("enraged") is bool:return false
    for key in ["break_until","recovery_until"]:
        if not (d.get(key) is int or d.get(key) is float) or not is_finite(float(d[key])) or float(d[key])<0:return false
    meter=int(d.meter);break_until=float(d.break_until);recovery_until=float(d.recovery_until);enraged=d.enraged;return true

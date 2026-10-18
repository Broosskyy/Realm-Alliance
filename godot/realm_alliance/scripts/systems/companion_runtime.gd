extends RefCounted
class_name RACompanionRuntime
const Validate=preload("res://scripts/systems/domain_validation.gd")
var ready_at:float=0
var pending:Dictionary={}
var sequence:int=0
func reset() -> void:ready_at=0;pending.clear();sequence=0
func snapshot() -> Dictionary:return {"schema":1,"ready_at":ready_at,"pending":pending.duplicate(true),"sequence":sequence}
func number(value) -> bool:return (value is int or value is float) and is_finite(float(value)) and float(value)>=0
func restore(d:Dictionary) -> bool:
    if d.is_empty():return true
    if not Validate.header(d) or not number(d.get("ready_at")) or not Validate.integer(d.get("sequence"),0,2000000000) or not d.get("pending") is Dictionary:return false
    if not d.pending.is_empty():
        if d.pending.get("id") not in ["skyfox","sunbird"] or not number(d.pending.get("hit_at")) or not d.pending.get("action_id") is String or not Validate.integer(d.pending.get("amount"),1,2000000000):return false
    ready_at=float(d.ready_at);pending=d.pending.duplicate(true);sequence=int(d.sequence);return true

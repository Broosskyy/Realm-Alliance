extends RefCounted
class_name RACombatInputBuffer
# One explicit manual skill intent, never an AUTO skill policy. No save state,
# resource authority or presentation timers: the session still owns acceptance.
const REJECTED=0
const CAST=1
const QUEUED=2
const WINDOW=1.0
var skill: String=""
var expires_at: float=0
func clear() -> void:
    skill="";expires_at=0
func request(model,index: int) -> int:
    if index not in range(4) or model.outcome!="fighting":return REJECTED
    var id: String=model.SKILL_IDS[index]
    if model.request_action(id):clear();return CAST
    if not model.skills.can_cast(id,model.clock,model.level,{"momentum":model.momentum,"rage":model.rage}):return REJECTED
    if model.pending.is_empty() and model.clock>=model.busy_until:return REJECTED
    skill=id;expires_at=model.clock+WINDOW
    return QUEUED
func drain(model) -> bool:
    if skill=="":return false
    if model.outcome!="fighting" or model.clock>expires_at:
        clear();return false
    if not model.skills.can_cast(skill,model.clock,model.level,{"momentum":model.momentum,"rage":model.rage}):
        clear();return false
    if model.request_action(skill):clear();return true
    return false

extends RefCounted
class_name RACombatInputBuffer
# One explicit manual skill intent, never an AUTO skill policy. No save state,
# resource authority or presentation timers: the session still owns acceptance.
const REJECTED=0
const CAST=1
const QUEUED=2
const WINDOW=1.0
var tap_pending=false
var tap_expires=0.0
var skill: String=""
var expires_at: float=0
func clear() -> void:
    skill="";expires_at=0;tap_pending=false;tap_expires=0.0
func request(model,index: int) -> int:
    if index not in range(4) or model.outcome!="fighting":return REJECTED
    var id: String=model.SKILL_IDS[index]
    if model.request_action(id):clear();return CAST
    if not _available(model,id):return REJECTED
    if model.pending.is_empty() and model.clock>=model.busy_until:return REJECTED
    skill=id;expires_at=model.clock+WINDOW;tap_pending=false
    return QUEUED
func drain(model) -> bool:
    if skill=="":
        if not tap_pending:return false
        if model.outcome!="fighting" or model.clock>tap_expires:clear();return false
        if model.request_basic():tap_pending=false;return true
        return false
    if model.outcome!="fighting" or model.clock>expires_at:
        clear();return false
    if not _available(model,skill):
        clear();return false
    if model.request_action(skill):clear();return true
    return false

func is_empty() -> bool:
    return skill=="" and not tap_pending
func request_tap(model) -> int:
    if model.outcome!="fighting" or model.player_hp<=0:return REJECTED
    if skill!="":return REJECTED
    if model.request_basic():tap_pending=false;return CAST
    if tap_pending:return REJECTED
    tap_pending=true;tap_expires=model.clock+.85;return QUEUED

func _available(model,id: String) -> bool:
    if id=="ultimate":return model.Tap.ultimate_unlocked(model.profile) and model.tap.charge>=100 and model.clock>=model.tap.ultimate_at
    return model.skills.can_cast(id,model.clock,model.level,{"momentum":model.momentum,"rage":model.rage})
func request_ultimate(model) -> int:
    if model.outcome!="fighting" or not _available(model,"ultimate"):return REJECTED
    if model.request_action("ultimate"):clear();return CAST
    skill="ultimate";expires_at=model.clock+WINDOW;tap_pending=false;return QUEUED

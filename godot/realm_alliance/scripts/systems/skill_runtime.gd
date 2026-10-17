extends RefCounted
class_name RASkillRuntime
const Definition = preload("res://scripts/systems/skill_definition.gd")
var definitions: Dictionary = Definition.all()
var ready_at: Dictionary = {}

func remaining(id: String, clock: float) -> float:
    return maxf(0, float(ready_at.get(id, 0.0)) - clock)

func can_cast(id: String, clock: float, level: int, resources: Dictionary) -> bool:
    if not definitions.has(id):
        return false
    var d: Dictionary = definitions[id]
    return level >= int(d.unlock_level) and remaining(id, clock) <= 0.00001 and (d.cost_type == "none" or float(resources.get(d.cost_type, 0)) >= float(d.cost))

func commit(id: String, clock: float) -> Dictionary:
    var d: Dictionary = definitions[id]
    ready_at[id] = clock + float(d.cooldown)
    return d.duplicate(true)

func snapshot() -> Dictionary:
    return ready_at.duplicate()

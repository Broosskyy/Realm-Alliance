extends RefCounted
class_name RAEnemyStage735

# Keep readable monsters inside the remaining portrait battle stage.
static func target_height(kind:String,visual:String,available:float) -> float:
    var desired=305.0
    if visual=="slime":desired=238.0
    if kind=="elite":desired=380.0
    if kind=="boss":desired=580.0
    return minf(desired,maxf(178.0,available))

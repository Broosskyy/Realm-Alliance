extends RefCounted
class_name RAAdminQA

# LOCAL DEBUG BUILDS ONLY. No backend authority, no online admin API.
# Call this only on a copied CombatSession held in memory. It must never be persisted.
const MAX_CURRENCY=2000000000
const LEVEL_TARGET=12

static func enabled() -> bool:
    return OS.is_debug_build()

static func xp_for_level(level: int) -> int:
    var total=0
    for l in range(1,clampi(level,1,100)):
        total+=80+20*(l-1)
    return total

static func _world(p:Dictionary) -> void:
    const_world(p)

static func const_world(p:Dictionary) -> void:
    for region in ["wolkgarten","glutkern"]:
        for i in 5:
            p.world_progress.stars[region+":"+str(i)]=3

static func _pets(p:Dictionary) -> void:
    for id in ["skyfox","sunbird"]:
        if not p.companions.owned.has(id):
            p.companions.owned[id]={"xp":0,"evolution":0,"source":"qa_sandbox"}

static func apply(session,kind:String) -> bool:
    if not enabled() or session==null or session.read_only:
        return false
    var p:Dictionary=session.profile
    if not session.World.ensure(p) or not session.Roster.ensure(p) or not session.Companions.ensure(p):
        return false
    var should_restart=true
    match kind:
        "gold":
            p.gold=mini(MAX_CURRENCY,int(p.gold)+10000)
        "shards":
            p.shards=mini(MAX_CURRENCY,int(p.shards)+500)
        "level":
            var target=xp_for_level(LEVEL_TARGET)
            p.xp=maxi(int(p.xp),target)
            var id:String=session.hero_id
            p.hero_roster.owned[id].xp=maxi(int(p.hero_roster.owned[id].xp),target)
        "world":
            _world(p)
        "pets":
            _pets(p)
        "evolve":
            _world(p);_pets(p)
            if int(p.companions.owned.skyfox.evolution)>0:return false
            p.companions.owned.skyfox.xp=maxi(100,int(p.companions.owned.skyfox.xp))
            p.gold=maxi(int(p.gold),100)
            p.shards=maxi(int(p.shards),6)
            if not session.evolve_companion("skyfox"):return false
        "showcase":
            _world(p);_pets(p)
            var xp=xp_for_level(LEVEL_TARGET)
            p.xp=maxi(int(p.xp),xp)
            p.hero_roster.owned.realmwachter.xp=maxi(int(p.hero_roster.owned.realmwachter.xp),xp)
            p.companions.active="skyfox"
            p.hero_roster.active="realmwachter"
            session._refresh_skill_definitions()
        "boss":
            _world(p)
            should_restart=false
            return session.start_stage("wolkgarten",4)
        _:
            return false
    if should_restart:
        return session.start_stage(session.region,0)
    return true

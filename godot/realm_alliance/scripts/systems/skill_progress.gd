extends RefCounted
class_name RASkillProgress
const Validate=preload("res://scripts/systems/domain_validation.gd")
const Definitions=preload("res://scripts/systems/skill_definition.gd")
const Progress=preload("res://scripts/systems/player_progress.gd")
const TALENTS=["might","vitality"]
static func ensure(profile: Dictionary) -> bool:
    if not profile.has("skill_progress"):profile.skill_progress={"schema":1,"levels":{},"talents":{"might":0,"vitality":0}}
    var d=profile.skill_progress
    if not Validate.header(d) or not d.get("levels") is Dictionary or not d.get("talents") is Dictionary:return false
    for id in d.levels:
        if not Definitions.all().has(id) or not Validate.integer(d.levels[id],1,5):return false
    var spent=0
    for id in d.talents:
        if id not in TALENTS or not Validate.integer(d.talents[id],0,3):return false
        spent+=int(d.talents[id])
    return spent<=mini(6,(Progress.level(int(profile.xp))-1)/3)
static func rank(profile: Dictionary,id: String) -> int:
    return int(profile.skill_progress.levels.get(id,1)) if ensure(profile) else 1
static func definition(profile: Dictionary,id: String) -> Dictionary:
    var d:Dictionary=Definitions.all()[id].duplicate(true)
    var extra=rank(profile,id)-1
    d.multiplier=float(d.multiplier)*(1+.1*extra)
    match d.effect:
        "mark":d.amplify=float(d.amplify)+.04*extra;d.duration=float(d.duration)+.25*extra
        "burn":d.tick_multiplier=float(d.tick_multiplier)+.06*extra
        "shield":d.absorb_fraction=float(d.absorb_fraction)+.025*extra;d.counter_multiplier=float(d.counter_multiplier)+.1*extra
    return d
static func cost(profile: Dictionary,id: String) -> Dictionary:
    var value=rank(profile,id)
    return {"gold":30*value,"shards":2,"level":int(Definitions.all()[id].unlock_level)+value-1}
static func can_upgrade(profile: Dictionary,id: String) -> bool:
    if not ensure(profile) or not Definitions.all().has(id):return false
    var c=cost(profile,id)
    return rank(profile,id)<5 and Progress.level(int(profile.xp))>=int(c.level) and int(profile.gold)>=int(c.gold) and int(profile.shards)>=2
static func upgrade(profile: Dictionary,id: String) -> bool:
    if not can_upgrade(profile,id):return false
    var c=cost(profile,id)
    profile.gold-=int(c.gold);profile.shards-=2;profile.skill_progress.levels[id]=rank(profile,id)+1
    return true
static func available_points(profile: Dictionary) -> int:
    if not ensure(profile):return 0
    var spent=0
    for rank_value in profile.skill_progress.talents.values():spent+=int(rank_value)
    return maxi(0,mini(6,(Progress.level(int(profile.xp))-1)/3)-spent)
static func talent(profile: Dictionary,id: String) -> bool:
    if id not in TALENTS or available_points(profile)<=0 or int(profile.skill_progress.talents.get(id,0))>=3:return false
    profile.skill_progress.talents[id]=int(profile.skill_progress.talents.get(id,0))+1
    return true
static func bonuses(profile: Dictionary) -> Dictionary:
    if not ensure(profile):return {"hp":0,"attack":0}
    return {"hp":8*int(profile.skill_progress.talents.get("vitality",0)),"attack":2*int(profile.skill_progress.talents.get("might",0))}

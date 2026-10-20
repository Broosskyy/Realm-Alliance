extends RefCounted
class_name RAWorldProgress
const Validate=preload("res://scripts/systems/domain_validation.gd")
const Definitions=preload("res://scripts/systems/skill_definition.gd")
const IDS=["wolkgarten","glutkern"]
const NAMES={"wolkgarten":"Wolkgarten","glutkern":"Glutkern"}
static func ensure(profile: Dictionary,checkpoint: Dictionary={}) -> bool:
    if not profile.has("world_progress"):
        var stars={}
        var cleared=5 if int(checkpoint.get("tier",0))>0 or checkpoint.get("outcome","")=="victory" else int(checkpoint.get("encounter",0))
        for i in clampi(cleared,0,5):stars["wolkgarten:%d"%i]=1
        profile.world_progress={"schema":1,"stars":stars}
    var d=profile.world_progress
    if not Validate.header(d) or not d.get("stars") is Dictionary:return false
    for key in d.stars:
        var parts=str(key).split(":")
        if parts.size()!=2 or parts[0] not in IDS or not parts[1].is_valid_int() or int(parts[1]) not in range(5) or not Validate.integer(d.stars[key],1,3):return false
    return true
static func stars(profile: Dictionary,region: String,index: int) -> int:
    return int(profile.world_progress.stars.get(region+":"+str(index),0)) if ensure(profile) else 0
static func unlocked(profile: Dictionary,region: String) -> bool:
    return region=="wolkgarten" or (region=="glutkern" and stars(profile,"wolkgarten",4)>0)
static func can_enter(profile: Dictionary,region: String,index: int) -> bool:
    return ensure(profile) and region in IDS and index in range(5) and unlocked(profile,region) and (index==0 or stars(profile,region,index-1)>0)
static func clear_stage(profile: Dictionary,region: String,index: int,hp_ratio: float) -> int:
    if not ensure(profile) or region not in IDS or index not in range(5):return 0
    var count=1+int(hp_ratio>=.5)+int(hp_ratio>=.85)
    var key=region+":"+str(index)
    profile.world_progress.stars[key]=maxi(count,int(profile.world_progress.stars.get(key,0)))
    return int(profile.world_progress.stars[key])
static var _glutkern: Array=[]
static func encounter(region: String,index: int) -> Dictionary:
    if region=="wolkgarten":return Definitions.catalog().encounters[index].duplicate(true)
    if _glutkern.is_empty():_glutkern=JSON.parse_string(FileAccess.get_file_as_string("res://data/glutkern_encounters.json"))
    return _glutkern[index].duplicate(true)

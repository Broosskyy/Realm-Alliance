extends RefCounted
class_name RACharacterProgress712
const Appearance=preload("res://scripts/systems/character_appearance710.gd")
const Validate=preload("res://scripts/systems/domain_validation.gd")
const Progress=preload("res://scripts/systems/player_progress.gd")
static var _config:Dictionary={}
static func config() -> Dictionary:
    if _config.is_empty():_config=JSON.parse_string(FileAccess.get_file_as_string("res://data/character712.json"))
    return _config
static func ensure(p:Dictionary) -> bool:
    if not p.has("character712"):return true
    var d=p.character712
    if not Validate.header(d) or not d.get("active") is bool or not d.get("appearance") is Dictionary:return false
    if not Appearance.valid(d.appearance) or d.get("id")!="player_adventurer":return false
    if not Validate.integer(d.get("xp"),0,2000000000) or not d.get("jobs") is Dictionary:return false
    if not d.jobs.has("adventurer") or not d.jobs.has(d.appearance.class_id):return false
    for id in d.jobs:
        if not config().classes.has(id) or not Validate.integer(d.jobs[id],0,2000000000):return false
    d.schema=1;d.appearance.schema=1;d.xp=int(d.xp)
    for id in d.jobs:d.jobs[id]=int(d.jobs[id])
    return true
static func active(p:Dictionary) -> bool:return p.has("character712") and ensure(p) and bool(p.character712.active)
static func exists(p:Dictionary) -> bool:return p.has("character712") and ensure(p)
static func create(p:Dictionary,body:String,hair:String) -> bool:
    if p.has("character712"):return false
    var appearance=Appearance.basic(body,hair)
    if appearance.is_empty():return false
    # Split old account-linked guardian XP before the new character earns account XP.
    var roster:Dictionary=p.get("hero_roster",{})
    var owned:Dictionary=roster.get("owned",{})
    if owned.size()==1 and owned.has("realmwachter") and not bool(roster.get("independent_xp",false)):
        owned.realmwachter.xp=int(p.get("xp",0));roster.independent_xp=true
    p.character712={"schema":1,"id":"player_adventurer","active":true,"appearance":appearance,"xp":0,"jobs":{"adventurer":0}}
    return true
static func visual_id(p:Dictionary) -> String:return "adventurer_"+str(p.character712.appearance.body_variant) if active(p) else ""
static func class_id(p:Dictionary) -> String:return str(p.character712.appearance.class_id) if exists(p) else "adventurer"
static func definition(p:Dictionary) -> Dictionary:return config().classes[class_id(p)]
static func level(p:Dictionary) -> int:return Progress.level(int(p.character712.xp)) if exists(p) else 1
static func job_level(p:Dictionary,id:String="") -> int:
    if not exists(p):return 1
    if id=="":id=class_id(p)
    return mini(100,1+int(int(p.character712.jobs.get(id,0))/int(config().job_xp_step)))
static func gain(p:Dictionary,amount:int) -> void:
    if not active(p) or amount<=0:return
    p.character712.xp=mini(2000000000,int(p.character712.xp)+amount)
    var id=class_id(p);p.character712.jobs[id]=mini(2000000000,int(p.character712.jobs[id])+amount)
static func can_choose(p:Dictionary,id:String) -> bool:
    return active(p) and id in ["swordsman","archer","mage"] and class_id(p)=="adventurer" and job_level(p,"adventurer")>=int(config().class_job_level)
static func choose(p:Dictionary,id:String) -> bool:
    if not can_choose(p,id):return false
    p.character712.appearance.class_id=id;p.character712.jobs[id]=0;return true
static func set_hair(p:Dictionary,id:String) -> bool:
    if not exists(p) or id not in p.character712.appearance.unlocked_hair_colors:return false
    p.character712.appearance.hair_color=id;return true

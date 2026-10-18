extends RefCounted
class_name RATapCombat
const Validate=preload("res://scripts/systems/domain_validation.gd")
const Progress=preload("res://scripts/systems/player_progress.gd")
const World=preload("res://scripts/systems/world_progress.gd")
static var _catalog: Dictionary={}
static func catalog() -> Dictionary:
    if _catalog.is_empty():_catalog=JSON.parse_string(FileAccess.get_file_as_string("res://data/tap_combat.json"))
    return _catalog
const MODES=[1,2,4]
const SKILLS=["sky_blade","arcane_eye","rage_flame","guardian_wall"]
var chain=0
var chain_until=0.0
var combo=0
var combo_until=0.0
var charge=0
var ultimate_at=0.0
static func ensure(profile: Dictionary) -> bool:
    if not profile.has("combat_mastery"):profile.combat_mastery={"schema":1,"mode":1,"auto_enabled":false,"auto_skills":[]}
    var d=profile.combat_mastery
    if not Validate.header(d) or (not Validate.integer(d.get("mode"),1,4) or int(d.mode) not in MODES) or not d.get("auto_enabled") is bool or not d.get("auto_skills") is Array:return false
    var seen=[]
    for id in d.auto_skills:
        if id not in SKILLS or id in seen:return false
        seen.append(id)
    return true
static func unlocked(profile: Dictionary,mode: int) -> bool:
    if mode not in MODES or not World.ensure(profile):return false
    var gate:Dictionary=catalog().modes[str(mode)]
    if Progress.level(int(profile.xp))<int(gate.level):return false
    return int(gate.stage)<0 or World.stars(profile,str(gate.region),int(gate.stage))>0

static func mode(profile: Dictionary) -> int:
    return int(profile.combat_mastery.mode) if ensure(profile) and unlocked(profile,int(profile.combat_mastery.mode)) else 1
static func select(profile: Dictionary,value: int) -> bool:
    if not ensure(profile) or not unlocked(profile,value):return false
    profile.combat_mastery.mode=value;return true
static func ultimate_unlocked(profile: Dictionary) -> bool:
    var d:Dictionary=catalog().ultimate
    return Progress.level(int(profile.xp))>=int(d.unlock_level) and World.stars(profile,str(d.region),int(d.stage))>0
static func split_damage(total: int,count: int) -> Array:
    var parts=[]
    # Progressed basic attacks always have enough total damage for every contact.
    for i in count:parts.append(int(total/count)+int(i<total%count))
    return parts
func plan(profile: Dictionary,now: float) -> Dictionary:
    if now>chain_until:chain=0
    var step=chain;var hits=mode(profile)
    var rules:Dictionary=catalog()
    var frame:Dictionary=rules.chains[step]
    var spacing=float(rules.contact_spacing)
    var windup=float(frame.windup)
    var recovery=float(frame.recovery)+(hits-1)*spacing
    return {"id":"basic","effect":"chain","multiplier":float(frame.multiplier)*float(rules.modes[str(hits)].budget),"windup":windup,"recovery":recovery,"vfx":"chain","contacts":hits,"spacing":spacing,"chain_step":step,"animation":"chain_%d_%d"%[step,hits]}

func accepted(d: Dictionary,now: float) -> void:
    chain=(int(d.chain_step)+1)%3;chain_until=now+float(d.windup)+float(d.recovery)+float(catalog().chain_grace)
func contact(now: float,finished_action: bool=false) -> void:
    if now>combo_until:combo=0
    combo+=1;combo_until=now+float(catalog().combo_window)
    if finished_action:charge=mini(100,charge+int(catalog().charge_per_basic))
func reset_chain() -> void:
    chain=0;chain_until=0.0;combo=0;combo_until=0.0
func snapshot() -> Dictionary:
    return {"schema":1,"chain":chain,"chain_until":chain_until,"combo":combo,"combo_until":combo_until,"charge":charge,"ultimate_at":ultimate_at}
func restore(d: Dictionary) -> bool:
    if d.is_empty():return true
    if not Validate.header(d) or not Validate.integer(d.get("chain"),0,2) or not Validate.integer(d.get("combo"),0,1000000) or not Validate.integer(d.get("charge"),0,100):return false
    for key in ["chain_until","combo_until","ultimate_at"]:
        if not (d.get(key) is int or d.get(key) is float) or not is_finite(float(d[key])) or float(d[key])<0:return false
    chain=int(d.chain);chain_until=float(d.chain_until);combo=int(d.combo);combo_until=float(d.combo_until);charge=int(d.charge);ultimate_at=float(d.ultimate_at);return true

static func next_goal(profile: Dictionary) -> String:
    if not unlocked(profile,2):return "Nächstes Ziel: x2 · Level 3 + erste Elite"
    if not ultimate_unlocked(profile):return "Nächstes Ziel: Ultimate · Level 4 + Gartenkoloss"
    if not unlocked(profile,4):return "Nächstes Ziel: x4 · Level 6 + Gartenkoloss"
    return "Meisterziel: Glutkern mit drei Sternen abschließen"

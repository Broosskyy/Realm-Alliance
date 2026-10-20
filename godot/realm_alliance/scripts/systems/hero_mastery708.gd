extends RefCounted
class_name RAHeroMastery
const Validate=preload("res://scripts/systems/domain_validation.gd")
const Roster=preload("res://scripts/systems/hero_roster.gd")
const Progress=preload("res://scripts/systems/player_progress.gd")
const ORDER=["runenpaladin","schattenjager","realmwachter"]
const NAMES=["Basis","I · Geprüft","II · Veredelt","III · Erwacht","IV · Erhaben","V · Legendär"]
const HP=[0,10,24,44,72,110]
const ATTACK=[0,2,5,9,15,24]
const DEFENSE=[0,0,1,2,4,6]
const COSTS=[{}, {"level":2,"gold":75,"shards":2,"forge_dust":5},{"level":4,"gold":180,"shards":6,"forge_dust":12},{"level":7,"gold":400,"shards":12,"forge_dust":30,"ember_core":2},{"level":10,"gold":800,"shards":20,"forge_dust":50,"ember_core":4},{"level":14,"gold":1500,"shards":35,"forge_dust":80,"ember_core":8}]
static func ensure(p:Dictionary) -> bool:
    if not p.has("hero_mastery"):p.hero_mastery={"schema":1,"heroes":{}}
    var d=p.hero_mastery
    if not Validate.header(d) or not d.get("heroes") is Dictionary:return false
    for id in d.heroes:
        if id not in ORDER or not p.hero_roster.owned.has(id) or not d.heroes[id] is Dictionary or not Validate.integer(d.heroes[id].get("rank"),0,5):return false
    d.schema=1
    for id in d.heroes:d.heroes[id].rank=int(d.heroes[id].rank)
    return true
static func rank(p:Dictionary,id:String="") -> int:
    if id=="":id=Roster.active(p)
    return int(p.get("hero_mastery",{}).get("heroes",{}).get(id,{}).get("rank",0))
static func bonuses(p:Dictionary,id:String="") -> Dictionary:
    var r=clampi(rank(p,id),0,5)
    return {"hp":HP[r],"attack":ATTACK[r],"defense":DEFENSE[r]}
static func rarity(p:Dictionary,id:String) -> String:
    var base=str(Roster.catalog().get(id,{}).get("rarity","common"))
    var record=p.get("hero_roster",{}).get("owned",{}).get(id,{})
    if id in ["runenpaladin","schattenjager"] and not record.is_empty() and str(record.get("source","")) not in ["starter709","starter_transition709","roster709"]:base="epic"
    var tiers=["common","uncommon","rare","epic","legendary"]
    return tiers[maxi(tiers.find(base),mini(4,rank(p,id)))] if base in tiers else base
static func cost(p:Dictionary,id:String) -> Dictionary:
    return COSTS[mini(5,rank(p,id)+1)].duplicate(true) if rank(p,id)<5 else {}
static func blockers(p:Dictionary,id:String) -> Array:
    if id not in ORDER or not p.hero_roster.owned.has(id):return ["Held zuerst freischalten"]
    if rank(p,id)>=5:return ["Höchster Rang erreicht"]
    var result=[];var c=cost(p,id)
    if Roster.level(p,id)<int(c.level):result.append("Heldenlevel %d"%c.level)
    for k in ["gold","shards","forge_dust","ember_core"]:
        var have=int(p.get(k,0)) if k in ["gold","shards"] else int(p.economy.materials.get(k,0))
        if have<int(c.get(k,0)):result.append("%d %s"%[int(c[k])-have,{"gold":"Gold","shards":"Splitter","forge_dust":"Runenstaub","ember_core":"Glutkerne"}[k]])
    if rank(p,id)>=3 and int(p.world_progress.stars.get("glutkern:4",0))==0:result.append("Aschenkoloss besiegen")
    return result
static func can_advance(p:Dictionary,id:String) -> bool:return ensure(p) and blockers(p,id).is_empty()
static func advance(p:Dictionary,id:String) -> bool:
    if not can_advance(p,id):return false
    var c=cost(p,id);var next=rank(p,id)+1
    p.gold-=int(c.gold);p.shards-=int(c.shards)
    for k in ["forge_dust","ember_core"]:p.economy.materials[k]-=int(c.get(k,0))
    if not p.hero_mastery.heroes.has(id):p.hero_mastery.heroes[id]={"rank":0}
    p.hero_mastery.heroes[id].rank=next;return true
static func training_cost(p:Dictionary,id:String) -> Dictionary:
    var lv=Roster.level(p,id)
    return {"gold":15+5*(lv-1),"forge_dust":2+lv/5,"xp":30+10*lv}
static func can_train(p:Dictionary,id:String) -> bool:
    if id not in ORDER or not p.hero_roster.owned.has(id) or Roster.level(p,id)>=100:return false
    var c=training_cost(p,id)
    return int(p.gold)>=int(c.gold) and int(p.economy.materials.forge_dust)>=int(c.forge_dust)
static func train(p:Dictionary,id:String) -> bool:
    if not can_train(p,id):return false
    var c=training_cost(p,id);var before=Roster.xp(p,id)
    if p.hero_roster.owned.size()==1 and p.hero_roster.owned.has("realmwachter"):p.hero_roster.owned.realmwachter.xp=Roster.xp(p,"realmwachter")
    p.hero_roster.independent_xp=true
    p.gold-=int(c.gold);p.economy.materials.forge_dust-=int(c.forge_dust)
    p.hero_roster.owned[id].xp=mini(2000000000,before+int(c.xp));return true

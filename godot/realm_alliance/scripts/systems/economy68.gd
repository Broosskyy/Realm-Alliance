extends RefCounted
class_name RAEconomy68
# Local, deterministic economy. Receipts are retained across reloads; a future
# authority can execute these commands without changing the stable content IDs.
const V=preload("res://scripts/systems/domain_validation.gd")
const Gear=preload("res://scripts/systems/hero_equipment.gd")
const Weapons=preload("res://scripts/systems/equipment.gd")
const Pets=preload("res://scripts/systems/companion_progress.gd")
const Progress=preload("res://scripts/systems/player_progress.gd")
const LIMIT=2000000000
const RARITIES={"common":{"name":"Gewöhnlich","color":"#9fbbd8","rank":0},"uncommon":{"name":"Ungewöhnlich","color":"#62d998","rank":1},"rare":{"name":"Selten","color":"#31d9ff","rank":2},"epic":{"name":"Episch","color":"#b65cff","rank":3},"legendary":{"name":"Legendär","color":"#ffca65","rank":4},"mythic":{"name":"Mythisch","color":"#ff6a8d","rank":5}}
const MATERIALS={"forge_dust":{"name":"Runenstaub","icon":"res://assets/work706/items/forge_dust.tres","rarity":"uncommon"},"ember_core":{"name":"Glutkern","icon":"res://assets/work706/items/ember_core.tres","rarity":"rare"},"harvest_token":{"name":"Erntezeichen","icon":"res://assets/work706/items/harvest_token.tres","rarity":"epic"}}
const OFFERS={
 "harvest_pet":{"name":"Laternengeist","kind":"pet","item":"lanternwisp","gold":0,"harvest_token":30,"level":4},
 "crystal_blade":{"name":"Kristallklinge","kind":"weapon","item":"crystal","gold":100,"level":2},
 "astral_plate":{"name":"Sternenpanzer","kind":"gear","item":"astral_plate","gold":35,"shards":2,"level":1},
 "sentinel_circlet":{"name":"Wächterdiadem","kind":"gear","item":"sentinel_circlet","gold":30,"shards":2,"level":2},
 "forge_supply":{"name":"10 Runenstaub","kind":"material","item":"forge_dust","count":10,"gold":90,"level":2},
 "harvest_wings":{"name":"Ernteschwingen","kind":"gear","item":"harvest_wings","gold":0,"harvest_token":20,"level":3}
}
const RECIPES={
 "ember_blade":{"name":"Glutklinge","kind":"weapon","item":"ember","gold":70,"forge_dust":18,"ember_core":1,"level":3},
 "rune_blade":{"name":"Runenklinge","kind":"weapon","item":"rune_gold","gold":120,"forge_dust":30,"ember_core":2,"level":5},
 "sky_wings":{"name":"Himmelsflügel","kind":"gear","item":"sky_wings","gold":60,"forge_dust":20,"shards":4,"level":3},
 "eclipse_plate":{"name":"Eklipsenpanzer","kind":"gear","item":"eclipse_plate","gold":140,"forge_dust":30,"ember_core":2,"shards":6,"level":4}
}

static func ensure(p:Dictionary) -> bool:
    if not p.has("economy"):p.economy={"schema":1,"materials":{"forge_dust":0,"ember_core":0,"harvest_token":0},"enchants":{},"receipts":{},"serial":0}
    var d=p.economy
    if not V.header(d) or not d.get("materials") is Dictionary or not d.get("enchants") is Dictionary or not d.get("receipts") is Dictionary or not V.integer(d.get("serial"),0,LIMIT):return false
    for id in MATERIALS:
        if not V.integer(d.materials.get(id),0,LIMIT):return false
    for id in d.materials:
        if not MATERIALS.has(id):return false
    for id in d.enchants:
        if id not in Weapons.IDS or not p.inventory.has(id) or not V.integer(d.enchants[id],0,5):return false
    for uid in d.receipts:
        if not uid is String or uid.is_empty() or not d.receipts[uid] is String:return false
    return true

static func nonce(p:Dictionary) -> String:
    return "economy:%d"%(int(p.economy.serial)+1) if ensure(p) else ""
static func owned(p:Dictionary,d:Dictionary) -> bool:
    if d.kind=="pet":return Pets.ensure(p) and p.companions.owned.has(d.item)
    return p.inventory.has(d.item) if d.kind=="weapon" else (p.hero_equipment.owned.has(d.item) if d.kind=="gear" else false)
static func cost_text(d:Dictionary) -> String:
    var parts=[]
    for key in ["gold","shards","forge_dust","ember_core","harvest_token"]:
        if int(d.get(key,0))>0:parts.append("%d %s"%[d[key],{"gold":"Gold","shards":"Splitter"}.get(key,MATERIALS.get(key,{}).get("name",key))])
    return " · ".join(parts)
static func affordable(p:Dictionary,d:Dictionary) -> bool:
    if not ensure(p) or Progress.level(int(p.xp))<int(d.get("level",1)):return false
    for key in ["gold","shards"]:
        if int(p[key])<int(d.get(key,0)):return false
    for key in MATERIALS:
        if int(p.economy.materials[key])<int(d.get(key,0)):return false
    return true
static func _debit(p:Dictionary,d:Dictionary) -> void:
    for key in ["gold","shards"]:p[key]-=int(d.get(key,0))
    for key in MATERIALS:p.economy.materials[key]-=int(d.get(key,0))
static func _fresh(p:Dictionary,uid:String) -> bool:
    return ensure(p) and not uid.is_empty() and uid==nonce(p) and not p.economy.receipts.has(uid) and int(p.economy.serial)<LIMIT
static func _receipt(p:Dictionary,uid:String,operation:String) -> void:
    p.economy.receipts[uid]=operation;p.economy.serial+=1
static func transact(p:Dictionary,table:String,id:String,uid:String) -> bool:
    var catalog=OFFERS if table=="shop" else (RECIPES if table=="craft" else {})
    if not _fresh(p,uid) or not Gear.ensure(p) or not catalog.has(id):return false
    var d:Dictionary=catalog[id]
    if owned(p,d) or not affordable(p,d):return false
    if d.kind=="material" and int(p.economy.materials[d.item])+int(d.count)>LIMIT:return false
    _debit(p,d)
    match d.kind:
        "weapon":p.inventory[d.item]={"id":d.item,"level":1,"rarity":Weapons.definition(d.item).rarity,"source":uid}
        "gear":p.hero_equipment.owned[d.item]={"id":d.item,"level":1,"source":uid}
        "material":p.economy.materials[d.item]+=int(d.count)
        "pet":p.companions.owned[d.item]={"xp":0,"evolution":0,"source":uid}
    _receipt(p,uid,table+":"+id)
    return true
static func enchant_cost(p:Dictionary,id:String) -> Dictionary:
    var rank=int(p.economy.enchants.get(id,0)) if ensure(p) else 5
    return {"gold":60*(rank+1),"forge_dust":8*(rank+1),"shards":2,"level":3}
static func enchant(p:Dictionary,id:String,uid:String) -> bool:
    if not _fresh(p,uid) or not p.inventory.has(id) or int(p.economy.enchants.get(id,0))>=5:return false
    var cost=enchant_cost(p,id)
    if not affordable(p,cost):return false
    _debit(p,cost);p.economy.enchants[id]=int(p.economy.enchants.get(id,0))+1;_receipt(p,uid,"enchant:"+id);return true
static func enchant_bonus(p:Dictionary,id:String) -> int:
    return int(p.get("economy",{}).get("enchants",{}).get(id,0))*4
static func can_salvage(p:Dictionary,kind:String,id:String) -> bool:
    if not ensure(p) or not Gear.ensure(p):return false
    if kind=="weapon":return id in Weapons.IDS and p.inventory.has(id) and id!="steel" and id!=p.equipped
    if kind!="gear" or not p.hero_equipment.owned.has(id):return false
    return id not in p.hero_equipment.equipped.values() and id not in p.hero_equipment.cosmetics.values()
static func salvage_yield(p:Dictionary,kind:String,id:String) -> int:
    return 3+int(p.inventory[id].level) if kind=="weapon" else 4+int(p.hero_equipment.owned[id].level)
static func salvage(p:Dictionary,kind:String,id:String,uid:String) -> bool:
    if not _fresh(p,uid) or not can_salvage(p,kind,id):return false
    var amount=salvage_yield(p,kind,id)
    if int(p.economy.materials.forge_dust)+amount>LIMIT:return false
    if kind=="weapon":p.inventory.erase(id);p.economy.enchants.erase(id)
    else:p.hero_equipment.owned.erase(id)
    p.economy.materials.forge_dust+=amount;_receipt(p,uid,"salvage:"+id);return true
static func combat_materials(p:Dictionary,enemy:Dictionary,region:String) -> Dictionary:
    if not ensure(p):return {}
    var result={"forge_dust":5 if enemy.kind=="boss" else (2 if enemy.kind=="elite" else 1)}
    if enemy.kind=="boss" and region=="glutkern":result.ember_core=1
    for id in result:p.economy.materials[id]=mini(LIMIT,int(p.economy.materials[id])+int(result[id]))
    return result
static func set_bonus(p:Dictionary) -> Dictionary:
    var count=0
    if Gear.ensure(p):
        for id in ["astral_plate","sentinel_circlet","sky_wings"]:
            if id in p.hero_equipment.equipped.values():count+=1
    return {"pieces":count,"hp":10 if count>=2 else 0,"defense":2 if count>=2 else 0,"attack":6 if count==3 else 0}

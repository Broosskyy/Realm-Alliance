extends RefCounted
const Validate=preload("res://scripts/systems/domain_validation.gd")
const CATALOG={"wanderer":{"name":"Weltenwanderer","description":"Dein Abenteuer beginnt.","rarity":"common"},"slayer":{"name":"Wolkenbezwinger","description":"Besiege 25 Gegner.","rarity":"uncommon"},"guardian":{"name":"Kolossentöter","description":"Besiege den Gartenkoloss.","rarity":"rare"},"collector":{"name":"Bund der Drei","description":"Besitze drei spielbare Helden.","rarity":"epic"},"ascended":{"name":"Sternengekrönt","description":"Erreiche Aufstiegsrang V mit einem Helden.","rarity":"legendary"}}
static func ensure(p:Dictionary) -> bool:
    if not p.has("titles"):p.titles={"schema":1,"active":"wanderer"}
    return Validate.header(p.titles) and p.titles.get("active") is String and CATALOG.has(p.titles.active)
static func earned(p:Dictionary,id:String) -> bool:
    match id:
        "wanderer":return true
        "slayer":return int(p.kills)>=25
        "guardian":return int(p.world_progress.stars.get("wolkgarten:4",0))>0
        "collector":return ["realmwachter","runenpaladin","schattenjager"].all(func(key):return p.hero_roster.owned.has(key))
        "ascended":return p.get("hero_mastery",{}).get("heroes",{}).values().any(func(value):return int(value.rank)>=5)
    return false
static func equip(p:Dictionary,id:String) -> bool:
    if not ensure(p) or not earned(p,id):return false
    p.titles.active=id;return true

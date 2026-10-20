extends "res://scripts/ui/modal_dialog.gd"
class_name RAHeroEquipmentDialog
signal operation(id: String, kind: String)
const Gear=preload("res://scripts/systems/hero_equipment.gd")
func configure(model,id: String) -> void:
    var d:Dictionary=Gear.CATALOG[id]
    var owned=model.profile.hero_equipment.owned.has(id)
    var current=str(model.profile.hero_equipment.equipped.get(d.slot,""))
    title=d.name
    var equipped_name=str(Gear.CATALOG[current].name) if current!="" else "Basisform"
    var level=int(model.profile.hero_equipment.owned[id].level) if owned else 1
    var values=Gear.item_stats(model.profile,id)
    var equipped_values=Gear.item_stats(model.profile,current)
    dialog_text="%s · Level %d\n+%d HP · +%d Verteidigung\nAktiv: %s\nVergleich: HP %d · DEF %d\n\n"%[str(model.Economy.RARITIES[d.rarity].name),level,values.hp,values.defense,equipped_name,values.hp-equipped_values.hp,values.defense-equipped_values.defense]
    if owned:
        ok_button_text="Ablegen" if current==id else "Anlegen"
        confirmed.connect(func():operation.emit(str(d.slot) if current==id else id,"unequip" if current==id else "equip"))
        var cost=Gear.upgrade_cost(model.profile,id)
        var button=add_button("Stufe +1",true,"upgrade")
        button.custom_minimum_size.y=100
        button.disabled=level>=Gear.max_level(id) or cost.is_empty() or model.gold<int(cost.get("gold",0)) or int(model.profile.shards)<int(cost.get("shards",0)) or model.read_only
        custom_action.connect(func(action):
            if action=="upgrade":operation.emit(id,"upgrade");queue_free())
        dialog_text+="Maximalstufe erreicht." if level>=Gear.max_level(id) else "Aufwertung: %d Gold + %d Splitter\n+3 HP · +1 Verteidigung."%[cost.get("gold",0),cost.get("shards",0)]
    else:
        dialog_text+="Freischaltung: Heldenlevel %d\nKosten: %d Gold + %d Himmelssplitter"%[d.unlock,d.gold,d.shards]
        ok_button_text="Freischalten"
        confirmed.connect(func():operation.emit(id,"acquire"))
    var bonus=model.Economy.set_bonus(model.profile)
    if id in ["astral_plate","sentinel_circlet","sky_wings"]:dialog_text+="\n\nSternenwacht-Set %d/3\n2 Teile: +10 HP / +2 DEF · 3 Teile: +6 Angriff"%bonus.pieces
    if owned:
        var recycle=add_button("Verwerten",true,"salvage")
        recycle.custom_minimum_size.y=100;recycle.disabled=model.read_only or not model.Economy.can_salvage(model.profile,"gear",id)
        var receipt=model.Economy.nonce(model.profile)
        custom_action.connect(func(action):
            if action=="salvage":
                var confirm=preload("res://scripts/ui/modal_dialog.gd").new();add_child(confirm)
                confirm.title="Ausrüstung verwerten?";confirm.dialog_text="%s samt Aufwertungen entfernen und %d Runenstaub erhalten?"%[d.name,model.Economy.salvage_yield(model.profile,"gear",id)];confirm.ok_button_text="Verwerten";confirm.cancel_button_text="Behalten"
                confirm.confirmed.connect(func():operation.emit(id,"salvage_gear|"+receipt);queue_free());confirm.canceled.connect(confirm.queue_free);confirm.popup_centered(Vector2i(550,350)))
    if bool(d.get("event",false)) and not owned:dialog_text="Ernteschwingen · Eventausrüstung\nAus Eventtruhen und dem Erntezeichen-Shop der Herbstabtei."
    get_ok_button().disabled=model.read_only or (not owned and not Gear.can_acquire(model.profile,id))
    cancel_button_text="Zurück"
    confirmed.connect(queue_free);canceled.connect(queue_free)

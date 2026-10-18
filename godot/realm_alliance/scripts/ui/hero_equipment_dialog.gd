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
    dialog_text="%s · Level %d\n+%d HP · +%d Verteidigung\nAktiv: %s\n\n"%["Episch" if d.rarity=="epic" else "Selten",level,int(d.hp)+(level-1)*3,int(d.defense)+level-1,equipped_name]
    if owned:
        ok_button_text="Ablegen" if current==id else "Anlegen"
        confirmed.connect(func():operation.emit(str(d.slot) if current==id else id,"unequip" if current==id else "equip"))
        var cost=Gear.upgrade_cost(model.profile,id)
        var button=add_button("Stufe +1",true,"upgrade")
        button.custom_minimum_size.y=88
        button.disabled=level>=10 or model.gold<int(cost.gold) or int(model.profile.shards)<1 or model.read_only
        custom_action.connect(func(action):
            if action=="upgrade":operation.emit(id,"upgrade");queue_free())
        dialog_text+="Aufwertung: %d Gold +1 Splitter\n+3 HP · +1 Verteidigung."%cost.gold
    else:
        dialog_text+="Freischaltung: Heldenlevel %d\nKosten: %d Gold + %d Himmelssplitter"%[d.unlock,d.gold,d.shards]
        ok_button_text="Freischalten"
        confirmed.connect(func():operation.emit(id,"acquire"))
    get_ok_button().disabled=model.read_only or (not owned and not Gear.can_acquire(model.profile,id))
    cancel_button_text="Zurück"
    confirmed.connect(queue_free);canceled.connect(queue_free)

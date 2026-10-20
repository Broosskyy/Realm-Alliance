extends "res://scripts/ui/modal_dialog.gd"
class_name RAWeaponDialog
signal operation(id: String,kind: String)
func configure(model,id: String) -> void:
    var d=model.Equipment.definition(id);var item:Dictionary=model.profile.inventory[id]
    title=d.name;ok_button_text="Angelegt" if model.profile.equipped==id else "Anlegen";cancel_button_text="Zurück"
    var cost=20+(int(item.level)-1)*17;var shards=1 if int(item.level)>=3 else 0
    dialog_text="Level %d · Angriff %d (%+d)\n%s\n\nAufwertung: %d Gold + %d Splitter\n+6 Waffenangriff"%[item.level,model.Equipment.item_damage(model.profile,id),model.Equipment.item_damage(model.profile,id)-model.Equipment.damage(model.profile),d.description,cost,shards]
    get_ok_button().disabled=model.read_only or model.profile.equipped==id
    confirmed.connect(func():operation.emit(id,"equip");queue_free());canceled.connect(queue_free)
    var b=add_button("Stufe +1",true,"upgrade");b.custom_minimum_size.y=100;b.disabled=model.read_only or int(item.level)>=20 or model.gold<cost or model.profile.shards<shards
    custom_action.connect(func(action):
        if action=="upgrade":operation.emit(id,"upgrade");queue_free())

    var rank=int(model.profile.economy.enchants.get(id,0))
    var enchant_cost=model.Economy.enchant_cost(model.profile,id)
    dialog_text+="\n\nRunenverzauberung %d/5 · +%d Angriff\nNächster Rang: %s"%[rank,rank*4,model.Economy.cost_text(enchant_cost)]
    var enchant_button=add_button("Rune +1",true,"enchant");enchant_button.custom_minimum_size.y=100;enchant_button.disabled=model.read_only or rank>=5 or not model.Economy.affordable(model.profile,enchant_cost)
    var salvage_button=add_button("Verwerten",true,"salvage");salvage_button.custom_minimum_size.y=100;salvage_button.disabled=model.read_only or not model.Economy.can_salvage(model.profile,"weapon",id)
    var receipt=model.Economy.nonce(model.profile)
    custom_action.connect(func(action):
        if action=="enchant":operation.emit(id,"enchant|"+receipt);queue_free()
        elif action=="salvage":
            var confirm=preload("res://scripts/ui/modal_dialog.gd").new();add_child(confirm)
            confirm.title="Waffe verwerten?";confirm.dialog_text="%s wird mit seinen Aufwertungen entfernt.\nDu erhältst %d Runenstaub."%[d.name,model.Economy.salvage_yield(model.profile,"weapon",id)];confirm.ok_button_text="Verwerten";confirm.cancel_button_text="Behalten"
            confirm.confirmed.connect(func():operation.emit(id,"salvage_weapon|"+receipt);queue_free());confirm.canceled.connect(confirm.queue_free);confirm.popup_centered(Vector2i(550,350)))

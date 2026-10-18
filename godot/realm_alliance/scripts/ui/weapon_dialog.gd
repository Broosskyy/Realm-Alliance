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
    var b=add_button("Stufe +1",true,"upgrade");b.custom_minimum_size.y=88;b.disabled=model.read_only or int(item.level)>=20 or model.gold<cost or model.profile.shards<shards
    custom_action.connect(func(action):
        if action=="upgrade":operation.emit(id,"upgrade");queue_free())

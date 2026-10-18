extends "res://scripts/ui/modal_dialog.gd"
class_name RATalentDialog
signal train_requested(id: String)
func configure(model) -> void:
    title="Wächtertalente";ok_button_text="Schließen";get_cancel_button().hide()
    var list=VBoxContainer.new();list.custom_minimum_size=Vector2(540,360);list.add_theme_constant_override("separation",16);add_child(list)
    var label=Label.new();label.add_theme_font_size_override("font_size",24)
    label.text="Freie Punkte: %d\nEin Punkt alle 3 Heldenlevel, maximal 6."%model.Advancement.available_points(model.profile);list.add_child(label)
    var talents=model.profile.skill_progress.talents if model.Advancement.ensure(model.profile) else {}
    for id in model.Advancement.TALENTS:
        var b=Button.new();b.custom_minimum_size.y=88;b.add_theme_font_size_override("font_size",24)
        b.text=("Stärke %d/3 · +2 Angriff" if id=="might" else "Vitalität %d/3 · +8 HP")%int(talents.get(id,0));b.name="Train_"+id
        b.disabled=model.read_only or model.Advancement.available_points(model.profile)<=0 or int(talents.get(id,0))>=3;list.add_child(b)
        b.pressed.connect(func():train_requested.emit(id);queue_free())
    confirmed.connect(queue_free);canceled.connect(queue_free)

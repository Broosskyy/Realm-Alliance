extends "res://scripts/ui/modal_dialog.gd"
class_name RACombatOptionsDialog
signal policy_changed
func configure(model) -> void:
    title="AUTO-Skills";ok_button_text="Schließen";get_cancel_button().hide()
    var list=VBoxContainer.new();list.custom_minimum_size=Vector2(540,540);list.add_theme_constant_override("separation",10);add_child(list)
    var description=Label.new();description.text="Nur ausdrücklich ausgewählte Skills.\nAb 60 Momentum / 80 Zorn.\nSchild nur unter 55% HP; kein doppelter Status.";description.add_theme_font_size_override("font_size",22);list.add_child(description)
    if not model.Tap.ensure(model.profile):return
    var settings=model.profile.combat_mastery.duplicate(true)
    var enabled=CheckButton.new();enabled.text="AUTO-Skills aktivieren";enabled.button_pressed=settings.auto_enabled;enabled.custom_minimum_size.y=100;enabled.disabled=model.read_only;list.add_child(enabled)
    enabled.toggled.connect(func(value):
        settings.auto_enabled=value
        if model.configure_auto_skills(value,settings.auto_skills):policy_changed.emit())
    for id in model.SKILL_IDS:
        var b=CheckButton.new();b.text=model.skills.definitions[id].name;b.button_pressed=id in settings.auto_skills;b.custom_minimum_size.y=100;b.disabled=model.read_only;list.add_child(b)
        b.toggled.connect(func(value):
            if value and id not in settings.auto_skills:settings.auto_skills.append(id)
            elif not value:settings.auto_skills.erase(id)
            if model.configure_auto_skills(settings.auto_enabled,settings.auto_skills):policy_changed.emit())
    confirmed.connect(queue_free);canceled.connect(queue_free)

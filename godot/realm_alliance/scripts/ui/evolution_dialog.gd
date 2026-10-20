extends "res://scripts/ui/modal_dialog.gd"
class_name RAEvolutionDialog
signal activate
const Evolution=preload("res://scripts/systems/hero_evolution.gd")
func configure(model) -> void:
    title="Erwachter Realmwächter"
    if Evolution.unlocked(model.profile):
        dialog_text="Erwachen freigeschaltet\nPermanent: +%d HP · +%d Angriff\n\nAktive Form: %s\nFormwechsel ändert nur die Optik."%[Evolution.HP,Evolution.ATTACK,"Erwacht" if Evolution.active(model.profile) else "Basis"]
        ok_button_text="Basisform" if Evolution.active(model.profile) else "Erwachen"
    else:
        dialog_text="Erwachen · Ab Heldenlevel %d\nPermanent: +%d HP · +%d Angriff\nGoldenes Wächter-Siegel als eigene Effektebene\n\nKosten: %d Gold + %d Himmelssplitter"%[Evolution.UNLOCK_LEVEL,Evolution.HP,Evolution.ATTACK,Evolution.GOLD,Evolution.SHARDS]
        ok_button_text="Freischalten"
    get_ok_button().disabled=model.read_only or (not Evolution.unlocked(model.profile) and not Evolution.can_unlock(model.profile))
    cancel_button_text="Zurück"
    confirmed.connect(func():activate.emit();queue_free());canceled.connect(queue_free)

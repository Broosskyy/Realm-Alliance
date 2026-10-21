extends CanvasLayer
var family="wander_leather"
func _ready() -> void:
    name="OutfitGallery711";layer=99
    var size=get_viewport().get_visible_rect().size
    var bg=ColorRect.new();bg.color=Color("#101c2c");bg.size=size;add_child(bg)
    var cell=Vector2(size.x/6.0,size.y/3.0)
    var poses=["idle","ready","windup","attack_contact","recovery","hit"]
    var heroes=["runenpaladin","schattenjager","realmwachter"]
    for row in 3:
        for col in 6:
            var origin=Vector2(col*cell.x,row*cell.y)
            var label=Label.new();label.text=heroes[row]+"\n"+family+" · "+poses[col];label.position=origin+Vector2(6,8);label.add_theme_font_size_override("font_size",14);add_child(label)
            var rig=preload("res://scripts/production_hero.gd").new();rig.preview_mode=true;rig.z_index=4;add_child(rig)
            rig.set_hero(heroes[row])
            var model=preload("res://scripts/systems/combat_session.gd").new()
            if family in model.Wardrobe.IDS:model.profile.wardrobe.owned[family]={};model.profile.wardrobe.active=family
            else:model.profile.hero_equipment.owned[family]={"level":5};model.profile.hero_equipment.equipped.chest=family
            rig.set_gear(model.profile);rig._set_pose(poses[col]);rig.set_process(false);rig._weapon.visible=false;rig._grip.visible=false
            rig.position=origin+Vector2(cell.x*.43,cell.y-10)
            rig.scale=Vector2.ONE*minf(cell.x/650.0,(cell.y-60)/520.0)

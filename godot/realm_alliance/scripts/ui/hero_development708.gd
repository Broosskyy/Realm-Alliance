extends "res://scripts/ui/game_sheet708.gd"
signal changed(message:String)
const Mastery=preload("res://scripts/systems/hero_mastery708.gd")
const Progress=preload("res://scripts/systems/player_progress.gd")
var model
var hero_id=""
var preview_rank=0
func configure(value,id:String="") -> void:
    model=value;hero_id=model.hero_id if id=="" else id;preview_rank=Mastery.rank(model.profile,hero_id);setup_sheet("Heldenentwicklung");_build()
func _build() -> void:
    var offset=clear_sheet();var actual=Mastery.rank(model.profile,hero_id);var owned=model.profile.hero_roster.owned.has(hero_id);var rarity=model.Economy.RARITIES[Mastery.rarity(model.profile,hero_id)]
    label_at(content,model.Roster.catalog()[hero_id].name+" · "+rarity.name,28,Color(rarity.color))
    label_at(content,"Eigener Heldenlevel · eigener Aufstiegsrang",21,Color("#a8bdd2"))
    var stage=Control.new();stage.custom_minimum_size=Vector2(0,360);stage.clip_contents=true;content.add_child(stage)
    var bg=TextureRect.new();bg.texture=load("res://assets/work705/ruins_courtyard.webp");bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;bg.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT);bg.mouse_filter=Control.MOUSE_FILTER_IGNORE;stage.add_child(bg)
    var rig=preload("res://scripts/production_hero.gd").new();rig.name="DevelopmentHeroRig";rig.preview_mode=true;rig.z_index=4;stage.add_child(rig);rig.set_hero(hero_id);rig.equip_weapon(model.weapon_index);rig.set_gear(model.profile);rig.set_mastery_visual(preview_rank);rig.scale=Vector2.ONE*.65;rig.position=Vector2(280,340)
    stage.resized.connect(func():
        if is_instance_valid(rig):rig.position=Vector2(stage.size.x*.5,340))
    var selector=HBoxContainer.new();selector.add_theme_constant_override("separation",6);content.add_child(selector)
    for r in 6:
        var b=button_at(selector,["Basis","I","II","III","IV","V"][r],func():preview_rank=r;_build());b.custom_minimum_size.x=100;b.name="RankPreview_"+str(r);b.add_theme_stylebox_override("normal",Kit.box("primary" if r==preview_rank else "slot"))
    label_at(content,("Aktiver Rang: " if preview_rank==actual else "Optische Vorschau: ")+Mastery.NAMES[preview_rank],24,Color("#ffd16b"))
    var lv=model.Roster.level(model.profile,hero_id);var xp=Progress.xp_in_level(model.Roster.xp(model.profile,hero_id));var required=Progress.required(lv)
    label_at(content,"Heldenlevel %d · %d / %d XP"%[lv,xp,required],24)
    var bar=ProgressBar.new();bar.custom_minimum_size.y=18;bar.max_value=required;bar.value=xp;bar.show_percentage=false;content.add_child(bar)
    var training=section(content);var train=Mastery.training_cost(model.profile,hero_id)
    art_at(training,"res://assets/work708/ui/codex.tres",110)
    button_at(training,"Trainieren · +%d Helden-XP\n%d Gold · %d Runenstaub"%[train.xp,train.gold,train.forge_dust],_train,not model.read_only and owned and Mastery.can_train(model.profile,hero_id)).name="HeroTrain"
    label_at(training,"Kampf-XP erhält dein aktiver Held. Training gilt nur für diese Figur.",20,Color("#a9c1dc"))
    var body=section(content,"hero");var growth=Mastery.bonuses(model.profile,hero_id)
    art_at(body,"res://assets/work708/ui/ascension.tres",120)
    label_at(body,"Aufstiegsrang %d / 5\n+%d HP · +%d Angriff · +%d DEF"%[actual,growth.hp,growth.attack,growth.defense],24,Color(rarity.color))
    if actual<5:
        var c=Mastery.cost(model.profile,hero_id);var next=actual+1
        label_at(body,"Nächster Rang: "+Mastery.NAMES[next],25,Color("#ffd16b"))
        label_at(body,"Zusätzlich: +%d HP · +%d Angriff · +%d DEF"%[Mastery.HP[next]-Mastery.HP[actual],Mastery.ATTACK[next]-Mastery.ATTACK[actual],Mastery.DEFENSE[next]-Mastery.DEFENSE[actual]],22)
        label_at(body,"Heldenlevel %d · %d G · %d Splitter\n%d Runenstaub · %d Glutkerne"%[c.level,c.gold,c.shards,c.forge_dust,c.get("ember_core",0)],22,Color("#a9c1dc"))
        var missing=Mastery.blockers(model.profile,hero_id)
        if not missing.is_empty():label_at(body,"Noch nötig: "+" · ".join(missing),20,Color("#ffbb98"))
        button_at(body,"Auf Rang %s aufsteigen"%["","I","II","III","IV","V"][next],_ascend,not model.read_only and Mastery.can_advance(model.profile,hero_id)).name="HeroAscend"
    else:label_at(body,"Legendärer Aufstieg vollendet",25,Color("#ffd16b"))
    finish_sheet(offset)
func _train() -> void:
    if model.train_hero(hero_id):changed.emit("Held trainiert");_build()
func _ascend() -> void:
    if model.advance_hero(hero_id):preview_rank=Mastery.rank(model.profile,hero_id);changed.emit("Aufstieg: "+Mastery.NAMES[preview_rank]);_build()

extends ScrollContainer
class_name RARPGPages
signal action(id: String)
const Kit=preload("res://scripts/ui/fantasy_theme.gd")
const Inventory=preload("res://scripts/systems/inventory_view.gd")
const Card=preload("res://scripts/ui/inventory_card.gd")
var filter="all"
var rarity_sort=false
var selected_region="wolkgarten"
var _key=""
var model
var content: VBoxContainer
func _ready() -> void:
    theme=Kit.native_theme();horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
    content=VBoxContainer.new();content.size_flags_horizontal=Control.SIZE_EXPAND_FILL;content.add_theme_constant_override("separation",16);add_child(content)
func refresh(tab: String,session,height: float) -> void:
    model=session;visible=tab in ["Abenteuer","Beute"]
    position=Vector2(38,178);size=Vector2(644,height-390)
    if not visible:return
    var key=tab+JSON.stringify(model.profile)+filter+str(rarity_sort)+selected_region+str(height)
    if key==_key:return
    _key=key
    for c in content.get_children():content.remove_child(c);c.queue_free()
    if tab=="Abenteuer":_world()
    else:_inventory()
func _label(value: String,color: Color=Kit.INK) -> Label:
    var l=Label.new();l.text=value;l.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART;l.add_theme_color_override("font_color",color);l.add_theme_font_size_override("font_size",23);content.add_child(l);return l
func _button(parent: Node,label: String,callback: Callable,disabled: bool=false) -> Button:
    var b=Button.new();b.text=label;b.custom_minimum_size.y=88;b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;b.disabled=disabled;b.pressed.connect(callback);parent.add_child(b);return b
func _world() -> void:
    var map=TextureRect.new();map.texture=preload("res://assets/world65/world_map.webp");map.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;map.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED;map.custom_minimum_size.y=258;content.add_child(map)
    var tabs=HBoxContainer.new();content.add_child(tabs)
    for id in model.World.IDS:
        _button(tabs,("◆ " if id==selected_region else "")+model.World.NAMES[id],func():selected_region=id;_key="";refresh("Abenteuer",model,size.y+390))
    _label("Tempel über den Wolken. Bezwinge den Gartenkoloss, um Glutkern zu öffnen." if selected_region=="wolkgarten" else "Basalt, Glutkeiler und der Aschenkoloss. Achte auf Einschlag und Nachbeben.")
    for i in 5:
        var d=model.World.encounter(selected_region,i)
        var stars=model.World.stars(model.profile,selected_region,i)
        var label="%d-%d · %s · %s\n%s"%[model.World.IDS.find(selected_region)+1,i+1,d.name,{"normal":"Normal","elite":"Elite","boss":"Boss"}[d.kind],"★".repeat(stars)+"☆".repeat(3-stars)]
        var b=_button(content,label,func():action.emit("stage:"+selected_region+":"+str(i)),not model.World.can_enter(model.profile,selected_region,i) or model.read_only)
        b.name="Stage_"+selected_region+"_"+str(i);b.add_theme_font_size_override("font_size",22)
    _label("Sterne: Sieg · mindestens 50% HP · mindestens 85% HP. Betreten startet einen neuen Lauf ab der gewählten Stage.",Color("#9fbbd8"))
func _inventory() -> void:
    _label("%d Gold · %d Himmelssplitter"%[model.gold,model.profile.shards],Color("#ffd16b"))
    var row=HBoxContainer.new();content.add_child(row)
    var ids=["all","weapon","gear","material"]
    for i in 4:
        var id=ids[i]
        var b=_button(row,["Alles","Waffen","Rüstung","Material"][i],func():filter=id;_key="";refresh("Beute",model,size.y+390));b.add_theme_font_size_override("font_size",20)
    var sort_button=_button(content,"Sortierung: "+("Seltenheit" if rarity_sort else "Name"),func():rarity_sort=not rarity_sort;_key="";refresh("Beute",model,size.y+390));sort_button.add_theme_font_size_override("font_size",22)
    var grid=GridContainer.new();grid.columns=3;grid.add_theme_constant_override("h_separation",10);grid.add_theme_constant_override("v_separation",10);content.add_child(grid)
    var items=Inventory.items(model.profile,filter,rarity_sort)
    for item in items:
        var b=Card.new();b.configure(item);b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;grid.add_child(b);b.pressed.connect(func():action.emit("item:"+item.kind+":"+item.id))
    if items.is_empty():_label("Noch keine Gegenstände in dieser Kategorie.")
    _label("Letzte Funde",Color("#ffd16b"))
    for i in mini(4,model.profile.loot.size()):
        var item:Dictionary=model.profile.loot[i];_label("%s · %s"%[item.name,{"common":"Gewöhnlich","rare":"Selten","epic":"Episch"}.get(item.rarity,item.rarity)],Color("#9fbbd8"))

extends "res://scripts/ui/touch_scroll.gd"
class_name RARPGPages
signal action(id: String)
const Kit=preload("res://scripts/ui/fantasy_theme.gd")
const Inventory=preload("res://scripts/systems/inventory_view.gd")
const Card=preload("res://scripts/ui/inventory_card.gd")
var filter="all"
var rarity_sort=false
var selected_region="wolkgarten"
var search_query=""
var _key=""
var model
var content: VBoxContainer
func _ready() -> void:
    super._ready()
    theme=Kit.native_theme();horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
    content=VBoxContainer.new();content.size_flags_horizontal=Control.SIZE_EXPAND_FILL;content.add_theme_constant_override("separation",16);add_child(content)
func refresh(tab: String,session,height: float) -> void:
    model=session;visible=tab in ["Abenteuer","Beute"]
    position=Vector2(22,166);size=Vector2(676,height-286)
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
    var b=Button.new();b.text=label;b.custom_minimum_size.y=100;b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;b.disabled=disabled;b.pressed.connect(callback);parent.add_child(b);return b
func _world() -> void:
    var tabs=HBoxContainer.new();tabs.add_theme_constant_override("separation",12);content.add_child(tabs)
    for id in model.World.IDS:
        var b=_button(tabs,("◆ " if id==selected_region else "")+model.World.NAMES[id],func():selected_region=id;_key="";refresh("Abenteuer",model,size.y+286))
        b.add_theme_stylebox_override("normal",Kit.box("primary" if id==selected_region else "panel"))
    _button(content,"Dungeons & Bossprüfung",func():action.emit("activities"))
    var map=preload("res://scripts/ui/world_map.gd").new()
    map.configure(model,selected_region)
    map.stage_selected.connect(func(i):action.emit("stage:"+selected_region+":"+str(i)))
    content.add_child(map)
    _label("Wolkgarten · Himmelsinseln" if selected_region=="wolkgarten" else "Glutkern · Aschenpfade",Color("#ffd16b"))
    _label((("Glutkern ist freigeschaltet. Wähle die nächste Region oder wiederhole Wolkgarten." if model.World.unlocked(model.profile,"glutkern") else "Bezwinge den Gartenkoloss, um Glutkern zu öffnen.") if selected_region=="wolkgarten" else "Glutkeiler und Aschenkoloss: Achte auf Einschlag und Nachbeben."))
    _label("Stage antippen zum Betreten. Sterne: Sieg · 50% HP · 85% HP. Gesperrte Etappen werden im Kampf freigeschaltet.",Color("#9fbbd8"))
func _inventory() -> void:
    var top=HBoxContainer.new();top.add_theme_constant_override("separation",12);content.add_child(top)
    var funds=Label.new();funds.text="%d G · %d Splitter"%[model.gold,model.profile.shards];funds.size_flags_horizontal=Control.SIZE_EXPAND_FILL;funds.add_theme_font_size_override("font_size",22);top.add_child(funds)
    _button(top,"Shop / Schmiede",func():action.emit("economy")).add_theme_font_size_override("font_size",20)
    var row=HBoxContainer.new();row.add_theme_constant_override("separation",8);content.add_child(row)
    var ids=["all","weapon","gear","material","better"]
    for i in 5:
        var id=ids[i];var b=_button(row,["Alles","Waffen","Rüstung","Material","Besser"][i],func():filter=id;_key="";refresh("Beute",model,size.y+286));b.add_theme_font_size_override("font_size",21);b.add_theme_stylebox_override("normal",Kit.box("primary" if filter==id else "panel"))
    var search=LineEdit.new();search.name="InventorySearch";search.placeholder_text="Gegenstand suchen …";search.text=search_query;search.custom_minimum_size.y=100;search.add_theme_font_size_override("font_size",24);content.add_child(search)
    var grid=GridContainer.new();grid.columns=3;grid.add_theme_constant_override("h_separation",10);grid.add_theme_constant_override("v_separation",10);content.add_child(grid)
    var footer=HBoxContainer.new();content.add_child(footer)
    var count=Label.new();count.size_flags_horizontal=Control.SIZE_EXPAND_FILL;count.add_theme_font_size_override("font_size",21);footer.add_child(count)
    _button(footer,"Sortieren: "+("Seltenheit" if rarity_sort else "Name"),func():rarity_sort=not rarity_sort;_key="";refresh("Beute",model,size.y+286)).add_theme_font_size_override("font_size",20)
    _populate_inventory(grid,count)
    search.text_changed.connect(func(value):search_query=value;_populate_inventory(grid,count))
    _button(content,"Ausrüstung öffnen",func():action.emit("equipment"))
    if not model.profile.loot.is_empty():_label("Letzter Fund: "+str(model.profile.loot[0].name),Color("#ffd16b"))

func _populate_inventory(grid:GridContainer,count:Label) -> void:
    for child in grid.get_children():grid.remove_child(child);child.queue_free()
    var items=Inventory.items(model.profile,"all" if filter=="better" else filter,rarity_sort)
    var visible_count=0
    for item in items:
        if filter=="better" and not item.get("better",false):continue
        if not search_query.strip_edges().is_empty() and not str(item.name).to_lower().contains(search_query.strip_edges().to_lower()):continue
        var b=Card.new();b.configure(item);b.size_flags_horizontal=Control.SIZE_EXPAND_FILL;grid.add_child(b);b.pressed.connect(func():action.emit("item:"+item.kind+":"+item.id));visible_count+=1
    count.text="%d Gegenstände"%visible_count
    if visible_count==0:
        var empty=Label.new();empty.text="Kein Treffer" if not search_query.is_empty() else "Noch leer";empty.add_theme_font_size_override("font_size",23);grid.add_child(empty)

extends Control
const Gate=preload("res://scripts/launcher/update_gate713.gd")
const Cache=preload("res://scripts/launcher/content_cache713.gd")
const Kit=preload("res://scripts/ui/fantasy_theme.gd")
const ArtGate=preload("res://scripts/launcher/update_gate714.gd")
const ArtCache=preload("res://scripts/launcher/content_cache714.gd")
const NewGate=preload("res://scripts/launcher/update_gate715.gd")
const NewCache=preload("res://scripts/launcher/content_cache715.gd")
const VERSION_CODE=715
const SETTINGS="res://data/update715_config.json"
var auto_check=true
var _busy=false
var _launching=false
var _request:HTTPRequest
var _title:Label
var _status:Label
var _detail:Label
var _progress:ProgressBar
var _retry:Button
var _card:PanelContainer
var _center:CenterContainer
var _config:Dictionary={}
var _want_account=false
var _phase="manifest"
var _pack:Dictionary={}
var _new_packs:Array=[]
var _new_downloads=0
var _art:TextureRect
var _art_label:Label

func _ready() -> void:
    theme=Kit.native_theme()
    _build()
    _show_art()
    get_viewport().size_changed.connect(_fit)
    _fit()
    if auto_check:call_deferred("_check")

func _build() -> void:
    var bg=TextureRect.new()
    bg.name="LaunchBackdrop"
    bg.texture=load("res://assets/work705/ruins_courtyard.webp")
    bg.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    bg.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_COVERED
    bg.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    bg.mouse_filter=Control.MOUSE_FILTER_IGNORE
    add_child(bg)
    var shadow=ColorRect.new()
    shadow.color=Color(0.035,0.055,0.105,0.84)
    shadow.mouse_filter=Control.MOUSE_FILTER_IGNORE
    shadow.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    add_child(shadow)
    var margin=MarginContainer.new()
    margin.name="LaunchSafeArea"
    margin.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
    for side in ["left","right","top","bottom"]:
        margin.add_theme_constant_override("margin_"+side,20)
    add_child(margin)
    var scroll=ScrollContainer.new()
    scroll.name="LaunchScroll"
    scroll.horizontal_scroll_mode=ScrollContainer.SCROLL_MODE_DISABLED
    scroll.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    scroll.size_flags_vertical=Control.SIZE_EXPAND_FILL
    margin.add_child(scroll)
    _center=CenterContainer.new()
    _center.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    scroll.add_child(_center)
    _card=PanelContainer.new()
    _card.name="LaunchCard"
    var frame=StyleBoxFlat.new()
    frame.bg_color=Color(0.07,0.09,0.16,0.96)
    frame.border_color=Color(0.68,0.58,0.36)
    frame.set_border_width_all(2)
    frame.set_corner_radius_all(20)
    frame.set_content_margin_all(18)
    _card.add_theme_stylebox_override("panel",frame)
    _center.add_child(_card)
    var stack=VBoxContainer.new()
    stack.add_theme_constant_override("separation",14)
    _card.add_child(stack)
    _title=_label(stack,"REALM ALLIANCE",36,Color("#ffe3a2"))
    _title.name="LaunchTitle"
    _label(stack,"Dein Abenteuer beginnt hier",21,Color("#a9c4e4"))
    _art=TextureRect.new()
    _art.name="RemotePatchBanner"
    _art.expand_mode=TextureRect.EXPAND_IGNORE_SIZE
    _art.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
    _art.custom_minimum_size.y=135
    _art.visible=false
    stack.add_child(_art)
    _art_label=_label(stack,"",18,Color("#e0d4ff"))
    _art_label.name="PatchAnnouncement"
    _art_label.visible=false
    stack.add_child(HSeparator.new())
    _status=_label(stack,"Vorbereitung …",24,Color("#f5ebd2"))
    _status.name="LaunchStatus"
    _detail=_label(stack,"Version 713 · Testkanal",19,Color("#c5d5e9"))
    _detail.name="LaunchDetail"
    _progress=ProgressBar.new()
    _progress.name="LaunchProgress"
    _progress.show_percentage=false
    _progress.indeterminate=true
    _progress.custom_minimum_size.y=16
    stack.add_child(_progress)
    var play=_button(stack,"Abenteuer beginnen",func():_start_game(false))
    play.name="LaunchPlay"
    var account=_button(stack,"Zum Konto / Anmelden",func():_start_game(true))
    account.name="LaunchAccount"
    _retry=_button(stack,"Updateprüfung wiederholen",_check)
    _retry.name="LaunchRetry"
    _label(stack,"Gast- und Offline-Spiel bleiben möglich. Konto und Registrierung erreichst du im Spiel unter Gemeinschaft.",17,Color("#a6b9cc"))
    _request=HTTPRequest.new()
    _request.name="LaunchRequest"
    _request.timeout=8
    _request.body_size_limit=8500000
    add_child(_request)
    _request.request_completed.connect(_on_manifest)
    _display("Bereit","Version 713 · Testkanal",false)

func _label(parent:Node,value:String,sz:int,color:Color) -> Label:
    var label=Label.new()
    label.text=value
    label.autowrap_mode=TextServer.AUTOWRAP_WORD_SMART
    label.horizontal_alignment=HORIZONTAL_ALIGNMENT_CENTER
    label.add_theme_font_size_override("font_size",sz)
    label.add_theme_color_override("font_color",color)
    parent.add_child(label)
    return label

func _button(parent:Node,value:String,action:Callable) -> Button:
    var button=Button.new()
    button.text=value
    button.custom_minimum_size.y=75
    button.size_flags_horizontal=Control.SIZE_EXPAND_FILL
    button.pressed.connect(action)
    parent.add_child(button)
    return button

func _fit() -> void:
    if not is_instance_valid(_card):return
    var size=get_viewport_rect().size
    _card.custom_minimum_size.x=minf(590,maxf(200,size.x-48))
    _center.custom_minimum_size=Vector2(maxf(200,size.x-48),maxf(0,size.y-48))
    _title.add_theme_font_size_override("font_size",29 if size.x<380 else 36)

func _display(message:String,detail:String,loading:bool) -> void:
    _busy=loading
    _status.text=message
    _detail.text=detail
    _progress.visible=loading
    _retry.disabled=loading

func _check() -> void:
    if _busy or _launching:return
    _phase="manifest"
    _progress.indeterminate=true
    _progress.value=0
    var settings=JSON.parse_string(FileAccess.get_file_as_string(SETTINGS))
    if not settings is Dictionary:
        _display("Offline bereit","Die Updatekonfiguration ist ungültig.",false)
        return
    _config=settings
    var address=str(settings.get("manifest_url",""))
    var channel=str(settings.get("channel","test"))
    if channel not in ["test","stable"] or not address.begins_with("https://") or address.contains(" ") or address.length()>1024:
        _display("Offline bereit","Keine sichere HTTPS-Updatequelle eingerichtet.",false)
        return
    _display("Updates werden geprüft …","Verbindung zum Versionsdienst wird aufgebaut.",true)
    if _request.request(address,PackedStringArray(["Accept: application/json"]))!=OK:
        _display("Offline bereit","Verbindung konnte nicht gestartet werden.",false)

func _process(_delta:float) -> void:
    if _phase=="pack" and _busy and not _pack.is_empty() and int(_pack.bytes)>0:
        _progress.value=clampf(100.0*float(_request.get_downloaded_bytes())/float(_pack.bytes),0.0,99.0)

func _on_manifest(result:int,status_code:int,_headers:PackedStringArray,body:PackedByteArray) -> void:
    if not _busy:return
    if _phase=="pack":
        _finish_pack(result,status_code,body)
        return
    if result!=HTTPRequest.RESULT_SUCCESS or status_code!=200:
        _display("Offline bereit","Inhaltsdienst nicht erreichbar. Bereits gespeicherte Inhalte bleiben verfügbar.",false)
        return
    var manifest=JSON.parse_string(body.get_string_from_utf8())
    var state=NewGate.inspect(manifest,VERSION_CODE,str(_config.get("channel","test")))
    match str(state.status):
        "app_optional":_display("App-Update verfügbar","Für neue Spielfunktionen ist eine Android-App-Version notwendig.",false)
        "app_required":_display("App-Update erforderlich","Bitte neue App-Version installieren. Offline spielen bleibt möglich.",false)
        "content":
            _new_packs=manifest.packs.duplicate(true)
            _new_downloads=0
            _next_pack()
        _:_display("Offline bereit","Nicht unterstütztes Manifest; vorhandene Inhalte bleiben erhalten.",false)

func _next_pack() -> void:
    if _launching:return
    while not _new_packs.is_empty():
        var candidate:Dictionary=_new_packs.pop_front()
        if NewCache.installed(candidate):continue
        _pack=candidate
        _phase="pack"
        _progress.indeterminate=false
        _progress.value=0
        _display("Spielinhalte werden geladen …",str(_pack.id)+" · "+str(_pack.bytes)+" Bytes",true)
        call_deferred("_fetch_pack")
        return
    _phase="manifest"
    _pack={}
    _show_art()
    _display("Spielinhalte aktualisiert" if _new_downloads>0 else "Spielinhalte aktuell",str(_new_downloads)+" Dateien heruntergeladen. Alle Daten geprüft.",false)

func _fetch_pack() -> void:
    if not _busy or _phase!="pack" or _launching:return
    if _request.request(str(_pack.url),PackedStringArray(["Accept: application/octet-stream"]))!=OK:
        _display("Offline bereit","Dateidownload fehlgeschlagen. Vorherige Inhalte bleiben erhalten.",false)

func _finish_pack(result:int,code:int,body:PackedByteArray) -> void:
    if result!=HTTPRequest.RESULT_SUCCESS or code!=200:
        _display("Download unterbrochen","Bisherige Grafiken und Spielstände bleiben erhalten.",false)
        return
    if not NewCache.install(_pack,body):
        _display("Update abgelehnt","Die neue Datei war beschädigt oder unsicher.",false)
        return
    _new_downloads+=1
    _next_pack()

func _show_art() -> void:
    if not is_instance_valid(_art):return
    var item=NewCache.catalog()
    var texture=NewCache.texture("realm_stage_ornament")
    if texture!=null:
        _art.texture=texture
        _art.visible=true
        _art_label.visible=true
        _art_label.text="Neues Spielasset · "+str(item.items[0].name) if not item.is_empty() and not item.items.is_empty() else "Neues 2D-Spielasset geladen"
        return
    var old=ArtCache.last()
    texture=ArtCache.preview_texture()
    _art.texture=texture
    _art.visible=texture!=null
    _art_label.visible=not old.is_empty()
    if not old.is_empty():_art_label.text=str(old.get("title","Neues aus dem Reich"))+" · "+str(old.get("message",""))

func _start_game(open_account:bool) -> void:
    if _launching:return
    _launching=true
    _want_account=open_account
    if _busy:_request.cancel_request()
    _display("Abenteuer wird gestartet …","Dein bestehender Spielstand wird im Spiel geladen.",false)
    call_deferred("_finish_start")

func _finish_start() -> void:
    get_tree().root.set_meta("realm_launcher_open_account",_want_account)
    var error=get_tree().change_scene_to_file("res://scenes/main.tscn")
    if error!=OK:
        get_tree().root.remove_meta("realm_launcher_open_account")
        _launching=false
        _display("Start fehlgeschlagen","Fehler %d. Du kannst es erneut versuchen."%error,false)

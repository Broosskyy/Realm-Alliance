extends Node
class_name RASaveTransfer
signal import_ready(data: Dictionary)
signal notice(title: String, detail: String)
const Store=preload("res://scripts/save_store.gd")
var _callback
var _export_text: String = ""

static func parse_import(text: String) -> Dictionary:
    if text.length()>1048576:
        return {}
    var parser=JSON.new()
    if parser.parse(text)!=OK or not parser.data is Dictionary:
        return {}
    var d:Dictionary=parser.data
    if int(d.get("version",0))==2:
        return d if Store._valid(d) else {}
    if int(d.get("version",0))!=1:
        return {}
    for key in ["gold","wave","weapon_index","upgrade_level","total_kills"]:
        if not d.has(key) or not (d[key] is int or d[key] is float):return {}
    return d

func export_save(data: Dictionary) -> void:
    _export_text=JSON.stringify(data,"  ")
    if OS.has_feature("web"):
        JavaScriptBridge.download_buffer(_export_text.to_utf8_buffer(),"REALM_ALLIANCE_save_v2.json","application/json")
        notice.emit("Sicherung","Download gestartet")
    else:
        _dialog(true)

func import_save() -> void:
    if OS.has_feature("web"):
        _callback=JavaScriptBridge.create_callback(_from_browser)
        JavaScriptBridge.get_interface("window").realmSaveImport=_callback
        JavaScriptBridge.eval("var f=document.createElement('input');f.type='file';f.accept='.json,application/json';f.onchange=async()=>{if(f.files[0])window.realmSaveImport(await f.files[0].text());};f.click();",true)
    else:
        _dialog(false)

func _from_browser(args: Array) -> void:
    if not args.is_empty():receive_text(str(args[0]))

func receive_text(text: String) -> void:
    var d=parse_import(text)
    if d.is_empty():notice.emit("Import abgelehnt","Keine gültige V1- oder V2-Sicherung")
    else:import_ready.emit(d)

func _dialog(exporting: bool) -> void:
    var dialog=FileDialog.new()
    dialog.use_native_dialog=true
    dialog.access=FileDialog.ACCESS_FILESYSTEM
    dialog.file_mode=FileDialog.FILE_MODE_SAVE_FILE if exporting else FileDialog.FILE_MODE_OPEN_FILE
    dialog.filters=PackedStringArray(["*.json ; REALM-Spielstand"])
    if exporting:dialog.current_file="REALM_ALLIANCE_save_v2.json"
    add_child(dialog)
    dialog.file_selected.connect(func(path: String):
        if exporting:
            var f=FileAccess.open(path,FileAccess.WRITE)
            if f:
                f.store_string(_export_text);f.flush()
                var ok=f.get_error()==OK
                f.close()
                notice.emit("Sicherung","Datei gespeichert" if ok else "Speichern fehlgeschlagen")
            else:notice.emit("Sicherung","Datei konnte nicht geschrieben werden")
        else:receive_text(FileAccess.get_file_as_string(path))
        dialog.queue_free())
    dialog.canceled.connect(dialog.queue_free)
    dialog.popup_centered_clamped(Vector2i(620,620))

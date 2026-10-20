extends Node
signal changed
signal backup_received(save:Dictionary)
var endpoint=""
var token=""
var state:Dictionary={}
var busy=false
var connected=false
var message="Nicht verbunden · lokales Abenteuer bleibt spielbar"
var last_result:Dictionary={}
var _route=""
var _queued_action:Dictionary={}
var _http:HTTPRequest
const STORAGE="realm-alliance-online708-session"
func _ready() -> void:
    _http=HTTPRequest.new();_http.timeout=12;_http.body_size_limit=600000;add_child(_http);_http.request_completed.connect(_complete)
    if OS.has_feature("web"):endpoint=str(JavaScriptBridge.eval("window.location.origin",true))
    var stored={}
    if OS.has_feature("web"):
        var raw=JavaScriptBridge.eval("window.localStorage.getItem('"+STORAGE+"')",true)
        if raw is String:stored=JSON.parse_string(raw) if JSON.parse_string(raw) is Dictionary else {}
    else:
        var config=ConfigFile.new()
        if config.load("user://online708.cfg")==OK:stored={"endpoint":config.get_value("session","endpoint",""),"token":config.get_value("session","token","")}
    if not str(stored.get("endpoint","")).is_empty():endpoint=str(stored.endpoint);token=str(stored.get("token",""))
    if not token.is_empty() and valid_endpoint(endpoint):call_deferred("refresh")
func valid_endpoint(value:String) -> bool:
    var pattern=RegEx.new();pattern.compile("^https://[A-Za-z0-9.-]+(:[0-9]{1,5})?(/[A-Za-z0-9_/-]*)?$")
    if pattern.search(value)!=null:return true
    pattern.compile("^http://(127\\.0\\.0\\.1|localhost)(:[0-9]{1,5})?$")
    if pattern.search(value)!=null:return true
    # The local test server may be served on a LAN origin; never send tokens to
    # another unencrypted remote origin entered by hand.
    return OS.has_feature("web") and value==str(JavaScriptBridge.eval("window.location.origin",true))
func set_endpoint(value:String) -> bool:
    if busy:return false
    value=value.strip_edges().trim_suffix("/")
    if not valid_endpoint(value):message="Bitte eine HTTPS-Adresse oder lokalen Testserver verwenden.";changed.emit();return false
    if value!=endpoint:endpoint=value;token="";state.clear();connected=false;_store()
    return true
func _store() -> void:
    if OS.has_feature("web"):JavaScriptBridge.eval("window.localStorage.setItem('"+STORAGE+"',"+JSON.stringify(JSON.stringify({"endpoint":endpoint,"token":token}))+ ")",true)
    else:
        var config=ConfigFile.new();config.set_value("session","endpoint",endpoint);config.set_value("session","token",token);config.save("user://online708.cfg")
func refresh() -> bool:return send("state",{},HTTPClient.METHOD_GET)
func send(route:String,payload:Dictionary={},method:int=HTTPClient.METHOD_POST) -> bool:
    if busy:
        if _route=="state" and route!="state" and _queued_action.is_empty():
            _queued_action={"route":route,"payload":payload.duplicate(true),"method":method};return true
        return false
    if not valid_endpoint(endpoint):message="Für die Gemeinschaft einen Realm-Server verbinden.";changed.emit();return false
    _route=route;busy=true
    if route!="state" or not connected:message="Verbinde …";changed.emit()
    var headers=PackedStringArray(["Content-Type: application/json"])
    if not token.is_empty():headers.append("Authorization: Bearer "+token)
    var error=_http.request(endpoint+"/api/v1/"+route,headers,method,JSON.stringify(payload) if method==HTTPClient.METHOD_POST else "")
    if error!=OK:busy=false;connected=false;message="Verbindung konnte nicht gestartet werden.";changed.emit();return false
    return true
func _complete(result:int,code:int,_headers:PackedStringArray,body:PackedByteArray) -> void:
    busy=false
    if not _queued_action.is_empty():call_deferred("_flush_action")
    var data=JSON.parse_string(body.get_string_from_utf8())
    if result!=HTTPRequest.RESULT_SUCCESS or not data is Dictionary:
        connected=false;message="Realm-Dienst nicht erreichbar. Lokales Abenteuer bleibt erhalten.";changed.emit();return
    if code<200 or code>=300:
        if code==401:token="";state.clear();connected=false;_store()
        message=str(data.get("error","Online-Aktion fehlgeschlagen."));changed.emit();return
    if data.has("token"):token=str(data.token);_store()
    if data.get("state") is Dictionary:state=data.state;connected=state.has("me")
    elif data.has("me"):state=data;connected=true
    if data.get("result") is Dictionary:last_result=data.result
    message="Verbunden als "+str(state.get("me",{}).get("name","Gast"))
    if _route=="logout":token="";state.clear();connected=false;message="Abgemeldet";_store()
    elif _route=="backup" and data.get("save") is Dictionary:backup_received.emit(data.save)
    changed.emit()
func nonce() -> String:return Crypto.new().generate_random_bytes(16).hex_encode()

func _flush_action() -> void:
    var action=_queued_action;_queued_action={}
    if not action.is_empty():send(action.route,action.payload,action.method)

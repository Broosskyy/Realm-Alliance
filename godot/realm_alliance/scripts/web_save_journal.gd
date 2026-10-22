extends RefCounted
class_name RAWebSaveJournal
# Local durability only, never a server/economy revision. IndexedDB user:// remains
# the file/backup store; this small synchronous mirror closes rapid-reload gaps.
const KEY="realm_alliance:combat:v2:journal"
static func read() -> Dictionary:
    if not OS.has_feature("web"):return {}
    var text=JavaScriptBridge.eval("(function(){try{return localStorage.getItem('"+KEY+"')||'';}catch(e){return '';}})()",true)
    if not text is String or text.is_empty():return {}
    var parser=JSON.new()
    if parser.parse(text)!=OK or not parser.data is Dictionary:return {}
    return parser.data
static func commit(data: Dictionary) -> bool:
    if not OS.has_feature("web"):return true
    var literal=JSON.stringify(JSON.stringify(data))
    return JavaScriptBridge.eval("(function(){try{localStorage.setItem('"+KEY+"',"+literal+");return 1;}catch(e){return 0;}})()",true)==1
static func backup_before_import() -> bool:
    if not OS.has_feature("web"):return true
    var suffix=str(int(Time.get_unix_time_from_system()*1000000))
    return JavaScriptBridge.eval("(function(){try{var v=localStorage.getItem('"+KEY+"');if(v!==null)localStorage.setItem('"+KEY+":before-import:"+suffix+"',v);return 1;}catch(e){return 0;}})()",true)==1

static func clear_guest() -> bool:
    if not OS.has_feature("web"):return true
    # Erase only REALM's own local-save journal keys, not account sessions.
    var js="(function(){try{var keys=[];for(var i=0;i<localStorage.length;i++){var k=localStorage.key(i);if(k==='"+KEY+"'||k.indexOf('"+KEY+":before-import:')===0)keys.push(k);}keys.forEach(function(k){localStorage.removeItem(k)});return 1;}catch(e){return 0;}})()"
    return JavaScriptBridge.eval(js,true)==1

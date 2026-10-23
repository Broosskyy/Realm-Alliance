extends RefCounted
class_name RAAppUpdate717

# Only pinned project release locations are accepted. A matching release still
# MUST pass APK signature verification inside the Android native installer.
const RELEASE_ROOT="https://github.com/Broosskyy/Realm-Alliance/releases/download/"
const PACKAGE="com.avenor.realmalliance.mockuptest"
const CERT_SHA256="317eb8e2e5bf1c8a5bd8b0433a7536bcc903da97d5ba437c20e9474cdd4af219"
const MAX_BYTES=350000000
static func _whole_number(value:Variant) -> bool:
    # Godot JSON.parse_string normalizes integer JSON numbers to floats.
    # Only exact, finite whole numbers are accepted as APK metadata.
    return (value is int or value is float) and is_finite(float(value)) and float(value)==float(int(value))

static func check(value:Variant,current:int,latest:int) -> bool:
    if not value is Dictionary:return false
    if not _whole_number(value.get("version_code")) or int(value.version_code)!=latest or latest<=current or latest>1000000:return false
    if value.get("package")!=PACKAGE or value.get("certificate_sha256")!=CERT_SHA256:return false
    if not _whole_number(value.get("bytes")) or int(value.bytes)<1000000 or int(value.bytes)>MAX_BYTES:return false
    var digest=value.get("sha256")
    if not digest is String or digest.length()!=64:return false
    var regex=RegEx.new()
    regex.compile("^[0-9a-f]{64}$")
    if regex.search(digest)==null:return false
    var code=str(latest)
    return value.get("url")==RELEASE_ROOT+"realm-"+code+"-android/REALM_ALLIANCE_"+code+".apk"

# Godot HTTPRequest documentation recommends timeout 0.0 for large files.
static func download_timeout(bytes:int) -> float:
    return 0.0 if bytes>=1000000 else 8.0

static func error_text(result:int,http_code:int) -> String:
    match result:
        HTTPRequest.RESULT_TIMEOUT:return "Zeitlimit erreicht"
        HTTPRequest.RESULT_CANT_RESOLVE:return "Downloadserver nicht erreichbar (DNS)"
        HTTPRequest.RESULT_CANT_CONNECT:return "Keine Verbindung zum Downloadserver"
        HTTPRequest.RESULT_CONNECTION_ERROR:return "Netzwerkverbindung unterbrochen"
        HTTPRequest.RESULT_TLS_HANDSHAKE_ERROR:return "Sichere Verbindung fehlgeschlagen"
        HTTPRequest.RESULT_DOWNLOAD_FILE_CANT_OPEN:return "APK-Zieldatei konnte nicht geöffnet werden"
        HTTPRequest.RESULT_DOWNLOAD_FILE_WRITE_ERROR:return "APK-Datei konnte nicht gespeichert werden"
        HTTPRequest.RESULT_REDIRECT_LIMIT_REACHED:return "Zu viele Download-Weiterleitungen"
        HTTPRequest.RESULT_BODY_SIZE_LIMIT_EXCEEDED:return "Datei größer als erlaubt"
        HTTPRequest.RESULT_SUCCESS:return "HTTP-Code %d" % http_code
        _:return "Netzwerkfehler %d (HTTP %d)" % [result,http_code]

static func sha256_file(path:String,max_bytes:int=MAX_BYTES) -> String:
    if not FileAccess.file_exists(path):return ""
    var fd=FileAccess.open(path,FileAccess.READ)
    if fd==null:return ""
    var size=fd.get_length()
    if size<1000000 or size>max_bytes:
        fd.close()
        return ""
    var ctx=HashingContext.new()
    if ctx.start(HashingContext.HASH_SHA256)!=OK:
        fd.close()
        return ""
    while not fd.eof_reached():
        var chunk=fd.get_buffer(mini(524288,fd.get_length()-fd.get_position()))
        if chunk.is_empty():break
        if ctx.update(chunk)!=OK:
            fd.close()
            return ""
    var consumed=fd.get_position()
    fd.close()
    return ctx.finish().hex_encode() if consumed==size else ""

static func ready(spec:Dictionary,path:String) -> bool:
    var f=FileAccess.open(path,FileAccess.READ)
    if f==null:return false
    var n=f.get_length()
    f.close()
    return check(spec,721,int(spec.get("version_code",0))) and n==int(spec.bytes) and sha256_file(path,int(spec.bytes))==spec.sha256

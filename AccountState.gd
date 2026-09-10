extends Node

signal account_changed

const MODE_GUEST := "guest"
const MODE_LOCAL_PROFILE := "local_profile"
const MODE_ONLINE_ACCOUNT := "online_account"

var mode: String = MODE_GUEST
var display_name: String = "RealmHero"
var email_hint: String = ""
var cloud_status: String = "not_connected"
var guest_link_available: bool = true
var server_player_id: String = ""
var auth_provider: String = ""

func is_guest() -> bool:
	return mode == MODE_GUEST

func set_guest() -> void:
	mode = MODE_GUEST
	cloud_status = "not_connected"
	guest_link_available = true
	account_changed.emit()

func create_local_profile(name: String, email: String = "") -> Dictionary:
	var clean_name := name.strip_edges()
	if clean_name.length() < 3:
		return {"ok":false,"message":"Spielername: mindestens 3 Zeichen"}
	if clean_name.length() > 16:
		return {"ok":false,"message":"Spielername: maximal 16 Zeichen"}
	mode = MODE_LOCAL_PROFILE
	display_name = clean_name
	email_hint = email.strip_edges()
	cloud_status = "local_only"
	guest_link_available = false
	account_changed.emit()
	return {"ok":true}


func mark_online_account(player_id: String, provider_id: String) -> void:
	if player_id.is_empty():
		return
	mode = MODE_ONLINE_ACCOUNT
	server_player_id = player_id
	auth_provider = provider_id
	cloud_status = "connected"
	guest_link_available = false
	account_changed.emit()

func mark_cloud_pending() -> void:
	# Backend/cloud transport is intentionally not implemented in V1.35.
	cloud_status = "backend_required"
	account_changed.emit()

func export_save_data() -> Dictionary:
	return {
		"mode":mode,
		"display_name":display_name,
		"email_hint":email_hint,
		"cloud_status":cloud_status,
		"guest_link_available":guest_link_available,
		"server_player_id":server_player_id,
		"auth_provider":auth_provider
	}

func apply_save_data(data: Dictionary) -> void:
	mode = str(data.get("mode",MODE_GUEST))
	if mode not in [MODE_GUEST,MODE_LOCAL_PROFILE,MODE_ONLINE_ACCOUNT]:
		mode = MODE_GUEST
	display_name = str(data.get("display_name","RealmHero")).left(16)
	email_hint = str(data.get("email_hint",""))
	cloud_status = str(data.get("cloud_status","not_connected"))
	guest_link_available = bool(data.get("guest_link_available",mode == MODE_GUEST))
	server_player_id = str(data.get("server_player_id",""))
	auth_provider = str(data.get("auth_provider",""))
	account_changed.emit()

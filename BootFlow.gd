extends Control

# Compatibility/status contract: BACKEND FOLGT; no live auth is claimed in V1.35.

@onready var splash: Control = %Splash
@onready var bootstrap: Control = %Bootstrap
@onready var welcome: Control = %Welcome
@onready var login: Control = %Login
@onready var register: Control = %Register
@onready var bootstrap_status: Label = %BootstrapStatus
@onready var login_status: Label = %LoginStatus
@onready var register_status: Label = %RegisterStatus
@onready var register_name: LineEdit = %RegisterUsername
@onready var register_email: LineEdit = %RegisterEmail
@onready var register_consent: CheckBox = %RegisterConsent
@onready var register_password: LineEdit = %RegisterPassword
@onready var register_password2: LineEdit = %RegisterPassword2

func _ready() -> void:
	_show_only(splash)
	await get_tree().create_timer(0.9).timeout
	_show_only(bootstrap)
	bootstrap_status.text = "SPIELSTAND · EINSTELLUNGEN · KONTO"
	await get_tree().create_timer(0.55).timeout
	bootstrap_status.text = "BEREIT"
	await get_tree().create_timer(0.25).timeout
	_show_only(welcome)
	if OS.get_name() == "Android":
		bootstrap_status.text = "ANDROID · GAST-START IN 2 SEKUNDEN"
		await get_tree().create_timer(2.0).timeout
		_guest_game()

func _show_only(target: Control) -> void:
	for view in [splash,bootstrap,welcome,login,register]:
		view.visible = view == target

func _start_game() -> void:
	get_tree().change_scene_to_file("res://MainGame.tscn")

func _guest_game() -> void:
	AccountState.set_guest()
	_start_game()

func _open_login() -> void:
	login_status.text = "ONLINE-KONTO IST IN DIESER TESTVERSION NOCH NICHT AKTIV"
	_show_only(login)

func _open_register() -> void:
	register_status.text = "ONLINE-KONTO IST IN DIESER TESTVERSION NOCH NICHT AKTIV"
	_show_only(register)

func _login_submit() -> void:
	login_status.text = "ANMELDUNG IST IN DIESER TESTVERSION NOCH NICHT AKTIV · DEIN LOKALER SPIELSTAND BLEIBT VERFÜGBAR"

func _register_submit() -> void:
	if register_password.text.length() < 6:
		register_status.text = "PASSWORT · MINDESTENS 6 ZEICHEN"
		return
	if register_password.text != register_password2.text:
		register_status.text = "PASSWÖRTER STIMMEN NICHT ÜBEREIN"
		return
	if not register_consent.button_pressed:
		register_status.text = "BITTE DATENSCHUTZ / NUTZUNGSBEDINGUNGEN BESTÄTIGEN"
		return
	var result := AccountState.create_local_profile(register_name.text, register_email.text)
	if bool(result.get("ok",false)):
		register_status.text = "LOKALES PROFIL ERSTELLT · ONLINE-SICHERUNG FOLGT SPÄTER"
	else:
		register_status.text = str(result.get("message","Eingaben prüfen"))

func _social_placeholder(channel: String) -> void:
	%CommunityStatus.text = "%s · OFFIZIELLER LINK WIRD SPÄTER KONFIGURIERT" % channel.to_upper()

func _back_to_welcome() -> void:
	_show_only(welcome)

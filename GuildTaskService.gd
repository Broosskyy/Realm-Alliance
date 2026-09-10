extends Node

signal tasks_changed
signal contribution_result(result: Dictionary)
signal donation_result(result: Dictionary)

const CONTRACT_VERSION := "guild-donation-ledger-v1"

var tasks: Array[Dictionary] = []
var guild_resources: Dictionary = {}
var task_revision: int = 0
var last_donation_request_id: String = ""
var last_donation_receipt: Dictionary = {}

func request_snapshot() -> Dictionary:
	return _post("guild_tasks_snapshot",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("guild_tasks")
	})

func contribute(task_id: String, amount: int = 1) -> Dictionary:
	if task_id.is_empty() or amount <= 0:
		return {"ok":false,"error_code":"INVALID_TASK_CONTRIBUTION"}
	return _post("guild_task_contribute",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("guild_task_contribute"),
		"guild_id":str(GuildService.guild.get("guild_id","")),
		"task_id":task_id,
		"amount":amount,
		"expected_revision":task_revision
	})

func donate(resource_id: String, amount: int) -> Dictionary:
	if resource_id.is_empty() or amount <= 0:
		return {"ok":false,"error_code":"INVALID_DONATION"}
	var request_id := OnlineAuthorityService.new_request_id("guild_donation")
	last_donation_request_id = request_id
	return _post("guild_donation",{
		"contract_version":CONTRACT_VERSION,
		"request_id":request_id,
		"guild_id":str(GuildService.guild.get("guild_id","")),
		"resource_id":resource_id,
		"amount":amount,
		"expected_revision":task_revision
	})

func accept_snapshot(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < task_revision:
		return false
	var incoming = envelope.get("tasks",[])
	if typeof(incoming) != TYPE_ARRAY:
		return false
	tasks.clear()
	for item in incoming:
		if typeof(item) != TYPE_DICTIONARY:
			continue
		var target := maxi(int(item.get("target",1)),1)
		tasks.append({
			"task_id":str(item.get("task_id","")),
			"title":str(item.get("title","Aufgabe")).left(48),
			"progress":clampi(int(item.get("progress",0)),0,target),
			"target":target,
			"ends_unix":maxi(int(item.get("ends_unix",0)),0),
			"reward_claim_id":str(item.get("reward_claim_id","")),
			"completed":bool(item.get("completed",false))
		})
	var resources = envelope.get("guild_resources",{})
	if typeof(resources) == TYPE_DICTIONARY:
		guild_resources = Dictionary(resources).duplicate(true)
	task_revision = revision
	tasks_changed.emit()
	return true

func accept_contribution(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)):
		contribution_result.emit(envelope)
		return false
	var accepted := accept_snapshot(envelope) if envelope.has("tasks") else true
	contribution_result.emit(envelope)
	return accepted

func accept_donation(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)):
		donation_result.emit(envelope)
		return false
	var response_request_id := str(envelope.get("request_id",""))
	if not last_donation_request_id.is_empty() and response_request_id != last_donation_request_id:
		return false
	var accepted := accept_snapshot(envelope) if envelope.has("tasks") else true
	last_donation_receipt = {"request_id":response_request_id,"receipt_id":str(envelope.get("receipt_id","")),"reward_claim_id":str(envelope.get("reward_claim_id","")),"server_unix":maxi(int(envelope.get("server_unix",0)),0)}
	donation_result.emit(envelope)
	return accepted

func request_last_donation_receipt() -> Dictionary:
	if last_donation_request_id.is_empty():
		return {"ok":false,"error_code":"NO_DONATION_REQUEST"}
	return _post("guild_donation_receipt",{"contract_version":CONTRACT_VERSION,"request_id":OnlineAuthorityService.new_request_id("guild_donation_receipt"),"donation_request_id":last_donation_request_id})

func accept_donation_receipt(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)):
		return false
	var donation_request_id := str(envelope.get("donation_request_id",""))
	if donation_request_id.is_empty() or donation_request_id != last_donation_request_id:
		return false
	last_donation_receipt = {"request_id":donation_request_id,"receipt_id":str(envelope.get("receipt_id","")),"reward_claim_id":str(envelope.get("reward_claim_id","")),"server_unix":maxi(int(envelope.get("server_unix",0)),0)}
	return true

func _post(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready():
		return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())

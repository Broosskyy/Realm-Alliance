extends Node

signal inventory_changed
signal entitlements_changed
signal purchase_validation_result(result: Dictionary)

const CONTRACT_VERSION := "inventory-entitlements-v1"

var inventory_items: Dictionary = {}
var entitlements: Dictionary = {}
var inventory_revision: int = 0
var entitlement_revision: int = 0

func request_inventory_snapshot() -> Dictionary:
	return _post("inventory_snapshot",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("inventory_snapshot")
	})

func request_entitlements_snapshot() -> Dictionary:
	return _post("entitlements_snapshot",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("entitlements_snapshot")
	})

func validate_store_purchase(product_id: String, store: String, receipt_token: String) -> Dictionary:
	if product_id.is_empty() or store.is_empty() or receipt_token.is_empty():
		return {"ok":false,"error_code":"MISSING_PURCHASE_VALIDATION_DATA"}
	return _post("purchase_validate",{
		"contract_version":CONTRACT_VERSION,
		"request_id":OnlineAuthorityService.new_request_id("purchase_validate"),
		"product_id":product_id,
		"store":store,
		"receipt_token":receipt_token,
		"client_build":BuildInfo.SOURCE_VERSION
	})

func has_entitlement(entitlement_id: String) -> bool:
	return bool(entitlements.get(entitlement_id,false))

func item_quantity(item_id: String) -> int:
	return maxi(int(inventory_items.get(item_id,0)),0)

func accept_inventory_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < inventory_revision:
		return false
	var items = envelope.get("items",{})
	if typeof(items) != TYPE_DICTIONARY:
		return false
	var normalized: Dictionary = {}
	for key in items.keys():
		var item_id := str(key)
		if item_id.is_empty():
			continue
		normalized[item_id] = maxi(int(items[key]),0)
	inventory_items = normalized
	inventory_revision = revision
	inventory_changed.emit()
	return true

func accept_entitlements_envelope(envelope: Dictionary) -> bool:
	var revision := int(envelope.get("revision",-1))
	if revision < entitlement_revision:
		return false
	var incoming = envelope.get("entitlements",{})
	if typeof(incoming) != TYPE_DICTIONARY:
		return false
	var normalized: Dictionary = {}
	for key in incoming.keys():
		var entitlement_id := str(key)
		if entitlement_id.is_empty():
			continue
		normalized[entitlement_id] = bool(incoming[key])
	entitlements = normalized
	entitlement_revision = revision
	_apply_legacy_projection()
	entitlements_changed.emit()
	return true

func accept_purchase_validation_envelope(envelope: Dictionary) -> bool:
	if not bool(envelope.get("ok",false)):
		purchase_validation_result.emit(envelope)
		return false
	var inventory_ok := true
	var entitlement_ok := true
	if envelope.has("items"):
		inventory_ok = accept_inventory_envelope({
			"revision":int(envelope.get("inventory_revision",inventory_revision)),
			"items":envelope.get("items",{})
		})
	if envelope.has("entitlements"):
		entitlement_ok = accept_entitlements_envelope({
			"revision":int(envelope.get("entitlement_revision",entitlement_revision)),
			"entitlements":envelope.get("entitlements",{})
		})
	purchase_validation_result.emit(envelope)
	return inventory_ok and entitlement_ok

func _apply_legacy_projection() -> void:
	# Compatibility projection only. The server snapshot remains authoritative.
	PlayerData.no_ads_owned = has_entitlement("no_ads")
	var cosmetics: Array[String] = []
	for key in entitlements.keys():
		var id := str(key)
		if id.begins_with("cosmetic:") and bool(entitlements[key]):
			cosmetics.append(id.trim_prefix("cosmetic:"))
	PlayerData.owned_cosmetics = cosmetics
	PlayerData.stats_changed.emit()

func _post(route_key: String, payload: Dictionary) -> Dictionary:
	if not AuthSessionService.is_authenticated():
		return {"ok":false,"error_code":"AUTH_REQUIRED"}
	if not OnlineTransportService.is_ready():
		return {"ok":false,"error_code":"TRANSPORT_NOT_CONFIGURED"}
	var route := str(OnlineAuthorityService.config.get("routes",{}).get(route_key,""))
	return OnlineTransportService.post_json(route,payload,AuthSessionService.auth_header())

func snapshot() -> Dictionary:
	return {
		"contract_version":CONTRACT_VERSION,
		"inventory_revision":inventory_revision,
		"entitlement_revision":entitlement_revision,
		"items":inventory_items.duplicate(true),
		"entitlements":entitlements.duplicate(true)
	}

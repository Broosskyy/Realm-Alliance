extends Node

signal purchase_started(product_id: String)
signal purchase_succeeded(product_id: String)
signal purchase_failed(product_id: String, reason: String)

# V0.2: sichere Abstraktionsschicht.
# KEINE echten Zahlungen im Prototyp.
# Spaeter werden Google Play Billing / Apple StoreKit / optional Web-Provider
# hinter dieser Schnittstelle angebunden und serverseitig validiert.

const PRODUCTION_PURCHASES_ENABLED := false

var catalog := {
	"starter_pack": {
		"display_name": "Starter-Paket",
		"type": "one_time",
		"price_tier": "TIER_1",
		"payload": {"gold": 2500, "spins": 25, "gems": 100}
	},
	"spin_pack_small": {
		"display_name": "Spin-Paket S",
		"type": "consumable",
		"price_tier": "TIER_1",
		"payload": {"spins": 30}
	},
	"gem_pack_small": {
		"display_name": "Juwelen S",
		"type": "consumable",
		"price_tier": "TIER_2",
		"payload": {"gems": 250}
	},
	"no_ads": {
		"display_name": "Werbung entfernen",
		"type": "non_consumable",
		"price_tier": "TIER_3",
		"payload": {"no_ads": true}
	},
	"halloween_cosmetic_pack": {
		"display_name": "Halloween-Kosmetik",
		"type": "one_time",
		"price_tier": "TIER_2",
		"payload": {"cosmetic":"halloween_2026_emblem"},
		"seasonal": true
	}
}

func get_products() -> Dictionary:
	return catalog.duplicate(true)

func purchase(product_id: String) -> void:
	if not catalog.has(product_id):
		purchase_failed.emit(product_id, "Unbekanntes Produkt")
		return

	purchase_started.emit(product_id)
	var authority_intent := OnlineAuthorityService.build_intent("purchase_product", {"product_id":product_id})
	if not PRODUCTION_PURCHASES_ENABLED:
		OnlineAuthorityService.rejected_result(authority_intent, "STORE_VALIDATION_UNAVAILABLE", "Store-/Server-Validierung noch nicht verbunden", false)
		purchase_failed.emit(product_id, "Store-/Server-Validierung noch nicht verbunden")
		return

	# V1.82: even when store UI is enabled later, product delivery must come
	# from InventoryEntitlementService after server-side receipt validation.
	purchase_failed.emit(product_id, "Store-Beleg muss serverseitig validiert werden")


func submit_store_receipt(product_id: String, store: String, receipt_token: String) -> Dictionary:
	if not catalog.has(product_id):
		return {"ok":false,"error_code":"UNKNOWN_PRODUCT"}
	# The client never grants a product here. Server validation must return
	# authoritative inventory/entitlement snapshots.
	return InventoryEntitlementService.validate_store_purchase(product_id,store,receipt_token)

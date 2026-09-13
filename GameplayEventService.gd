extends Node
## V2.05 — event-driven gameplay contract for quest/objective tracking.

signal event_emitted(event_name: String, amount: int, context: Dictionary)

const EVENT_MONSTER_DEFEATED := "monster_defeated"
const EVENT_TAP_PERFORMED := "tap_performed"
const EVENT_CRITICAL_HIT := "critical_hit"
const EVENT_UPGRADE_PURCHASED := "upgrade_purchased"
const EVENT_BOSS_DEFEATED := "boss_defeated"
const EVENT_SPIN_COMPLETED := "spin_completed"
const EVENT_AFK_CLAIMED := "afk_claimed"
const EVENT_DAILY_CLAIMED := "daily_claimed"
const EVENT_VILLAGE_UPGRADE := "village_upgrade"
const EVENT_GOLDMINE_CLAIM := "goldmine_claim"
const EVENT_HERO_UNLOCKED := "hero_unlocked"
const EVENT_HERO_DEPLOYED := "hero_deployed"
const EVENT_HERO_LEVELED := "hero_leveled"
const EVENT_HERO_ATTACK := "hero_attack"
const EVENT_HERO_DEFEAT_CONTRIBUTION := "hero_defeat_contribution"
const EVENT_ITEM_ACQUIRED := "item_acquired"
const EVENT_ITEM_EQUIPPED := "item_equipped"
const EVENT_ITEM_UNEQUIPPED := "item_unequipped"

func publish(event_name: String, amount: int = 1, context: Dictionary = {}) -> void:
	if event_name.is_empty() or amount <= 0:
		return
	event_emitted.emit(event_name, amount, context)

func publish_metric(metric: String, amount: int = 1, context: Dictionary = {}) -> void:
	ObjectiveSystem.register_action(metric, amount, context)

func metric_for(event_name: String) -> String:
	match event_name:
		EVENT_MONSTER_DEFEATED:
			return "monster_defeat"
		EVENT_TAP_PERFORMED:
			return "tap"
		EVENT_CRITICAL_HIT:
			return "critical_hit"
		EVENT_UPGRADE_PURCHASED:
			return "upgrade_purchased"
		EVENT_BOSS_DEFEATED:
			return "boss_defeat"
		EVENT_SPIN_COMPLETED:
			return "spin"
		EVENT_AFK_CLAIMED:
			return "afk_claimed"
		EVENT_DAILY_CLAIMED:
			return "daily_claimed"
		EVENT_VILLAGE_UPGRADE:
			return "village_upgrade"
		EVENT_GOLDMINE_CLAIM:
			return "goldmine_claim"
		EVENT_HERO_UNLOCKED:
			return "hero_unlocked"
		EVENT_HERO_DEPLOYED:
			return "hero_deployed"
		EVENT_HERO_LEVELED:
			return "hero_leveled"
		EVENT_HERO_ATTACK:
			return "hero_attack"
		EVENT_HERO_DEFEAT_CONTRIBUTION:
			return "hero_defeat_contribution"
		EVENT_ITEM_ACQUIRED:
			return "item_acquired"
		EVENT_ITEM_EQUIPPED:
			return "item_equipped"
		EVENT_ITEM_UNEQUIPPED:
			return "item_unequipped"
	return ""

extends Node

const ROLE_LABELS := {
	"calibration_reference":"AUSGEWOGEN",
	"agile_beast":"FLINK",
	"heavy_silhouette":"WUCHTIG",
	"humor_variant":"UNBERECHENBAR",
	"armored_small":"GEPANZERT",
	"flying_scout":"FLINK",
	"forest_spirit":"MAGISCH",
	"defender":"ZÄH",
	"slime":"ZÄH",
	"crystal_construct":"GEPANZERT",
	"predator":"AGGRESSIV"
}

static func encounter_tag(level: int) -> String:
	if P0MonsterVisualSystem.is_boss(level):
		return "BOSS"
	var def := P0MonsterVisualSystem.encounter_definition(level)
	var role := str(def.get("role",""))
	return str(ROLE_LABELS.get(role, "MONSTER"))

static func hit_punch_scale(level: int) -> Vector2:
	var def := P0MonsterVisualSystem.encounter_definition(level)
	var role := str(def.get("role",""))
	if P0MonsterVisualSystem.is_boss(level):
		return Vector2(0.92,0.92)
	if role in ["heavy_silhouette","armored_small","defender","crystal_construct"]:
		return Vector2(0.945,0.945)
	if role in ["agile_beast","flying_scout","predator"]:
		return Vector2(0.965,0.965)
	return Vector2(0.955,0.955)

static func hero_role_label(hero_id: String) -> String:
	var card := HeroSystem.get_card_data(hero_id)
	var role := str(card.get("role",""))
	match role:
		"Nahkampf":
			return "NAHKAMPF · DRUCK"
		"Fernkampf":
			return "FERNKAMPF · PRÄZISION"
		"Magie":
			return "MAGIE · IMPULS"
	return role.to_upper()

static func hero_assist_scale(hero_id: String) -> float:
	var card := HeroSystem.get_card_data(hero_id)
	match str(card.get("role","")):
		"Nahkampf":
			return 1.06
		"Fernkampf":
			return 1.00
		"Magie":
			return 1.03
	return 1.0

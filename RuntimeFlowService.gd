extends Node

const FLOW_VERSION:="v1.54-runtime-flow-01"
const PRIORITY:=["spin","journey","puzzle","tower_defense","lane_battle","village_upgrade","afk"]

func pending_kind()->String:
	if SpinPresentationState.has_pending_result():return "spin"
	if DiceJourneySystem.has_pending_result():return "journey"
	if PuzzleSystem.has_pending_completion():return "puzzle"
	if TowerDefenseSystem.has_pending_run_result():return "tower_defense"
	if LaneAttackSystem.has_pending_battle_result():return "lane_battle"
	if P0VillageSystem.has_pending_upgrade_result():return "village_upgrade"
	if AfkRewardSystem.has_pending_reward():return "afk"
	return ""

func has_pending_presentation()->bool:
	return not pending_kind().is_empty()

func pending_count()->int:
	var count:=0
	if SpinPresentationState.has_pending_result():count+=1
	if DiceJourneySystem.has_pending_result():count+=1
	if PuzzleSystem.has_pending_completion():count+=1
	if TowerDefenseSystem.has_pending_run_result():count+=1
	if LaneAttackSystem.has_pending_battle_result():count+=1
	if P0VillageSystem.has_pending_upgrade_result():count+=1
	if AfkRewardSystem.has_pending_reward():count+=1
	return count

func attention_count()->int:
	var count:=SocialHubSystem.unread_count()
	if FeatureFlags.SHOW_DAILY and DailyRewards.can_claim():count+=1
	if FeatureFlags.SHOW_QUESTS:
		for quest in QuestSystem.QUESTS:
			if QuestSystem.is_ready(str(quest.get("id",""))):count+=1
	if VillageProgressionSystem.can_claim_prosperity():count+=1
	if FeatureFlags.SHOW_PUZZLE and PuzzleProgressionSystem.can_claim_mastery_reward():count+=1
	if FeatureFlags.SHOW_TOWER_DEFENSE and TowerDefenseProgressionSystem.can_claim_mastery_reward():count+=1
	if FeatureFlags.SHOW_HEROES and HeroProgressionSystem.can_claim(HeroSystem.get_selected_hero_id()):count+=1
	if FeatureFlags.SHOW_LANE_BATTLE and LaneBattleProgressionSystem.can_claim_mastery_reward():count+=1
	if MetaProgressSystem.can_open_chest():count+=1
	return count

func feature_hub_status()->String:
	var pending:=pending_kind()
	if not pending.is_empty():
		return "FORTSETZEN · %s wartet auf Präsentation" % display_name(pending)
	var attention:=attention_count()
	if attention>0:
		return "%d BELOHNUNGEN / AKTIONEN BEREIT · freie Wahl der Spielsäule" % attention
	return "ALLE SPIELSÄULEN BEREIT · Fortschritt wird Realm-weit verbunden"

func display_name(kind:String)->String:
	match kind:
		"spin":return "SPIN"
		"journey":return "REALM-REISE"
		"puzzle":return "PUZZLE"
		"tower_defense":return "VERTEIDIGUNG"
		"lane_battle":return "ANGRIFF"
		"village_upgrade":return "DORF-AUSBAU"
		"afk":return "OFFLINE-BELOHNUNG"
	return kind.to_upper()

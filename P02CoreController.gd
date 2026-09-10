extends Node

func apply(root: Node) -> void:
	# Master V1.4: visible P0 is Home/Tap + Wheel + Village.
	_set_visible(root, "DailyButton", FeatureFlags.SHOW_DAILY)
	_set_visible(root, "QuestButton", FeatureFlags.SHOW_QUESTS)
	_set_visible(root, "MoreFeaturesButtonP0", true)
	_set_visible(root, "Btn_Heroes", false)
	_set_visible(root, "Btn_Attack", false)
	_set_visible(root, "Btn_Defense", false)

	_set_visible(root, "JourneyButton", FeatureFlags.SHOW_REALM_JOURNEY)
	_set_visible(root, "MetaButton", false)
	_set_visible(root, "PuzzleButton", false)
	_set_visible(root, "DefenseGameButton", false)
	_set_visible(root, "LaneBattleButton", false)
	_set_visible(root, "HeroesGameButton", false)
	var quick := root.find_child("QuickActions", true, false)
	if quick:
		quick.visible = true

	# Future/P1 views stay in source but never occupy the P0 presentation.
	_set_visible(root, "View_Daily", false)
	_set_visible(root, "View_Quests", false)
	_set_visible(root, "View_Heroes", false)
	_set_visible(root, "View_LaneAttack", false)
	_set_visible(root, "View_TowerDefense", false)

func _set_visible(root: Node, node_name: String, state: bool) -> void:
	var node := root.find_child(node_name, true, false)
	if node:
		node.visible = state

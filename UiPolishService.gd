extends Node

const CONFIG_VERSION := "v1.54-ui-polish-02"
const MIN_TOUCH_HEIGHT := 78.0
const PRIMARY_TOUCH_HEIGHT := 96.0

const POLISHED_OVERLAYS := [
	"FeatureHubOverlayP0","LiveOpsOverlayP0","ShopOverlayP0",
	"ProgressionOverlayP0","AfkOverlayP0","AccountOverlayP0",
	"SocialOverlayP0","SupportOverlayP0","SettingsOverlayP0"
]

func apply(root: Control) -> void:
	for overlay_name in POLISHED_OVERLAYS:
		var overlay := root.find_child(overlay_name,true,false)
		if overlay:
			_polish_overlay(overlay)
	_polish_primary(root.find_child("SpinButton",true,false))
	_polish_primary(root.find_child("HomeWheelCTA",true,false))
	_polish_primary(root.find_child("AfkClaimP0",true,false))
	_polish_primary(root.find_child("HalloweenClaimP0",true,false))
	_polish_primary(root.find_child("HalloweenQuestClaimP0",true,false))
	_polish_primary(root.find_child("HalloweenChestP0",true,false))
	_polish_primary(root.find_child("RankingClaimP0",true,false))
	_polish_primary(root.find_child("HeroUpgradeButtonP0",true,false))
	_polish_primary(root.find_child("BuildingUpgradeButtonP0",true,false))
	_polish_primary(root.find_child("TDFightButtonP0",true,false))
	_polish_primary(root.find_child("TDRestartButtonP0",true,false))
	_polish_primary(root.find_child("TDTechButtonP0",true,false))
	_polish_primary(root.find_child("TDMasteryClaimP0",true,false))
	_polish_primary(root.find_child("LaneLeftButton",true,false))
	_polish_primary(root.find_child("LaneRightButton",true,false))
	_polish_primary(root.find_child("LaneTechButtonP0",true,false))
	_polish_primary(root.find_child("LaneMasteryClaimP0",true,false))
	_polish_primary(root.find_child("LaneNextBattleP0",true,false))
	_polish_primary(root.find_child("HeroSpecializationButtonP0",true,false))
	_polish_primary(root.find_child("HeroMasteryClaimP0",true,false))
	_polish_primary(root.find_child("VillageForgeActionV153",true,false))
	_polish_primary(root.find_child("VillageTempleActionV153",true,false))
	_polish_primary(root.find_child("VillageProsperityClaimV153",true,false))
	_polish_tabs(root)
	_polish_navigation_v154(root)

func _polish_overlay(overlay: Control) -> void:
	if overlay is PanelContainer:
		var panel := StyleBoxFlat.new()
		panel.bg_color = Color(0.055,0.105,0.12,0.985)
		panel.border_color = Color(0.72,0.58,0.24,0.92)
		panel.set_border_width_all(3)
		panel.corner_radius_top_left = 26
		panel.corner_radius_top_right = 26
		panel.corner_radius_bottom_left = 26
		panel.corner_radius_bottom_right = 26
		panel.content_margin_left = 28
		panel.content_margin_right = 28
		panel.content_margin_top = 26
		panel.content_margin_bottom = 26
		overlay.add_theme_stylebox_override("panel",panel)
	_polish_children(overlay)

func _polish_children(node: Node) -> void:
	for child in node.get_children():
		if child is Button:
			var button := child as Button
			if button.custom_minimum_size.y < MIN_TOUCH_HEIGHT:
				button.custom_minimum_size.y = MIN_TOUCH_HEIGHT
			if button.get_theme_font_size("font_size") < 20:
				button.add_theme_font_size_override("font_size",20)
			button.add_theme_constant_override("outline_size",2)
			button.add_theme_color_override("font_outline_color",Color(0.03,0.05,0.06,0.72))
		elif child is Label:
			var label := child as Label
			if label.get_theme_font_size("font_size") < 18:
				label.add_theme_font_size_override("font_size",18)
		_polish_children(child)

func _polish_primary(button: Control) -> void:
	if button == null or not (button is Button):
		return
	var b := button as Button
	b.custom_minimum_size.y = max(b.custom_minimum_size.y,PRIMARY_TOUCH_HEIGHT)
	b.add_theme_font_size_override("font_size",max(b.get_theme_font_size("font_size"),26))

func _polish_tabs(root: Control) -> void:
	for name in ["RankingDailyP0","RankingWeeklyP0","RankingEventP0","SocialInboxP0","SocialAchievementsP0","SocialFriendsP0"]:
		var button := root.find_child(name,true,false)
		if button and button is Button:
			button.custom_minimum_size.y = max(button.custom_minimum_size.y,76.0)
			button.add_theme_font_size_override("font_size",20)


func _polish_navigation_v154(root:Control)->void:
	for name in ["BtnTap","BtnRad","BtnDorf","DailyButton","JourneyButton","QuestButton","MoreFeaturesButtonP0"]:
		var button:=root.find_child(name,true,false)
		if button and button is Button:
			button.custom_minimum_size.y=max(button.custom_minimum_size.y,86.0)
			button.add_theme_font_size_override("font_size",max(button.get_theme_font_size("font_size"),20))
	for name in ["HubHeroesP0","HubJourneyP0","HubPuzzleP0","HubDefenseP0","HubLaneP0","HubMetaP0","HubProfileP0","HubShopP0","HubLiveOpsP0","HubProgressionP0"]:
		var button:=root.find_child(name,true,false)
		if button and button is Button:
			button.custom_minimum_size.y=max(button.custom_minimum_size.y,112.0)

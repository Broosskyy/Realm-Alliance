extends Node

const CALIBRATION_VERSION := "v1.58-copy-visual-02"
const MIN_BODY_FONT := 18
const MIN_BUTTON_FONT := 20
const PRIMARY_BUTTON_FONT := 24
const TITLE_FONT := 30
const MIN_TOUCH := 78.0
const PRIMARY_TOUCH := 96.0

const TITLE_NODES := [
    "MonsterRewardTitle","WheelRewardTitleP0","LevelUpTextP0","SettingsTitleP0",
    "FeatureHubTitleP0","AccountTitleP0","SocialTitleP0","SupportTitleP0",
    "LiveOpsTitleP0","ShopTitleP0","ProgressionTitleP0","AfkTitleP0",
    "JourneyTitleLabel","PuzzleTitleLabel","VillageTitleP0"
]

const PRIMARY_BUTTONS := [
    "SpinButton","HomeWheelCTA","MonsterRewardContinue","WheelRewardContinueP0",
    "BuildingUpgradeButtonP0","HeroUpgradeButtonP0","AfkClaimP0","DailyClaimButton",
    "RankingClaimP0","DiceRollButton","TreasurePortalButton","TDFightButtonP0",
    "LaneNextBattleP0","VillageProsperityClaimV153"
]

const NAV_BUTTONS := [
    "BtnTap","BtnRad","BtnDorf","DailyButton","JourneyButton","QuestButton","MoreFeaturesButtonP0",
    "HomeButton","SpinNavButton","VillageButton","HeroesGameButton","LaneBattleButton","DefenseGameButton"
]

const LONG_TEXT_LABELS := [
    "FeatureHubSubtitleP0","FeatureHubFooterP0","SupportInfoP0","ShopStatusP0",
    "AfkTextP0","ProgressionTextP0","RankingStatusP0","RankingRewardPreviewP0",
    "QuestSummaryLabel","JourneyNodeDetailP0","NoSpinsText"
]

func apply(root: Control) -> void:
    if root == null:
        return
    _apply_global_readability(root)
    _apply_titles(root)
    _apply_primary_buttons(root)
    _apply_navigation(root)
    _apply_long_text(root)
    _apply_resource_strip(root)
    _apply_close_back_targets(root)

func _apply_global_readability(node: Node) -> void:
    for child in node.get_children():
        if child is Label:
            var label := child as Label
            var current := label.get_theme_font_size("font_size")
            if current < MIN_BODY_FONT:
                label.add_theme_font_size_override("font_size", MIN_BODY_FONT)
            label.add_theme_color_override("font_color", Color("f5f1e8"))
            label.add_theme_constant_override("outline_size", 2)
            label.add_theme_color_override("font_outline_color", Color(0.03, 0.04, 0.07, 0.78))
        elif child is Button:
            var button := child as Button
            button.custom_minimum_size.y = max(button.custom_minimum_size.y, MIN_TOUCH)
            var size := MIN_BUTTON_FONT if button.text.length() <= 24 else 18
            button.add_theme_font_size_override("font_size", max(button.get_theme_font_size("font_size"), size))
            button.add_theme_color_override("font_color", Color("fff9ec"))
            button.add_theme_color_override("font_hover_color", Color.WHITE)
            button.add_theme_constant_override("outline_size", 2)
            button.add_theme_color_override("font_outline_color", Color(0.03, 0.04, 0.07, 0.82))
        _apply_global_readability(child)

func _apply_titles(root: Control) -> void:
    for name in TITLE_NODES:
        var node := root.find_child(name, true, false)
        if node and node is Label:
            var label := node as Label
            label.add_theme_font_size_override("font_size", max(label.get_theme_font_size("font_size"), TITLE_FONT))
            label.add_theme_color_override("font_color", Color("ffe0a3"))
            label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER

func _apply_primary_buttons(root: Control) -> void:
    for name in PRIMARY_BUTTONS:
        var node := root.find_child(name, true, false)
        if node and node is Button:
            var button := node as Button
            button.custom_minimum_size.y = max(button.custom_minimum_size.y, PRIMARY_TOUCH)
            var target_font := PRIMARY_BUTTON_FONT if button.text.length() <= 22 else 20
            button.add_theme_font_size_override("font_size", max(button.get_theme_font_size("font_size"), target_font))

func _apply_navigation(root: Control) -> void:
    for name in NAV_BUTTONS:
        var node := root.find_child(name, true, false)
        if node and node is Button:
            var button := node as Button
            button.custom_minimum_size.y = max(button.custom_minimum_size.y, 86.0)
            button.add_theme_font_size_override("font_size", max(button.get_theme_font_size("font_size"), 20))

func _apply_long_text(root: Control) -> void:
    for name in LONG_TEXT_LABELS:
        var node := root.find_child(name, true, false)
        if node and node is Label:
            var label := node as Label
            label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
            label.add_theme_font_size_override("font_size", max(label.get_theme_font_size("font_size"), 18))

func _apply_resource_strip(root: Control) -> void:
    for name in ["GoldLabel","SpinsLabel","ShieldsLabel","LevelLabel"]:
        var node := root.find_child(name, true, false)
        if node and node is Label:
            var label := node as Label
            label.add_theme_font_size_override("font_size", max(label.get_theme_font_size("font_size"), 24))
            label.add_theme_color_override("font_color", Color.WHITE)

func _apply_close_back_targets(root: Control) -> void:
    for name in ["SettingsCloseP0","AccountCloseP0","SocialCloseP0","SupportCloseP0","LiveOpsCloseP0","ShopCloseP0","ProgressionCloseP0","FeatureHubCloseP0","BuildingUpgradeCloseP0"]:
        var node := root.find_child(name, true, false)
        if node and node is Button:
            var button := node as Button
            button.custom_minimum_size.x = max(button.custom_minimum_size.x, MIN_TOUCH)
            button.custom_minimum_size.y = max(button.custom_minimum_size.y, MIN_TOUCH)
            if button.text == "X":
                button.tooltip_text = "Schließen"

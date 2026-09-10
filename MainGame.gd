extends Control

const ProductionUiBinder = preload("res://ProductionUiBinder.gd")
const ScreenVisualCalibration = preload("res://ScreenVisualCalibration.gd")
const ScreenAssetBinder = preload("res://ScreenAssetBinder.gd")
const ProductionAssetConvergenceV187 = preload("res://ProductionAssetConvergenceV187.gd")
const ProductionAssetConvergenceV188 = preload("res://ProductionAssetConvergenceV188.gd")
const ProductionAssetConvergenceV189 = preload("res://ProductionAssetConvergenceV189.gd")
const ProductionAssetConvergenceV190 = preload("res://ProductionAssetConvergenceV190.gd")
const ProductionAssetConvergenceV191 = preload("res://ProductionAssetConvergenceV191.gd")
const TowerDefenseVisualDirectorV192 = preload("res://TowerDefenseVisualDirectorV192.gd")
const ProductionAssetConvergenceV192 = preload("res://ProductionAssetConvergenceV192.gd")
const ProductionAssetConvergenceV193 = preload("res://ProductionAssetConvergenceV193.gd")
const TapCombatVisualDirectorV193 = preload("res://TapCombatVisualDirectorV193.gd")
const RewardProgressionVisualDirectorV193 = preload("res://RewardProgressionVisualDirectorV193.gd")
const SpinVillageResponsivePolishV194 = preload("res://SpinVillageResponsivePolishV194.gd")
const HomeNavigationRewardPolishV195 = preload("res://HomeNavigationRewardPolishV195.gd")
const ModeGameplayPolishV196 = preload("res://ModeGameplayPolishV196.gd")
const ScreenCompositionService = preload("res://ScreenCompositionService.gd")
const ScreenUiAssemblyService = preload("res://ScreenUiAssemblyService.gd")
const MobileLayoutOwner = preload("res://MobileLayoutOwner.gd")
const RuntimeGuidanceService = preload("res://RuntimeGuidanceService.gd")
const FinalAlphaConvergenceV200 = preload("res://FinalAlphaConvergenceV200.gd")

const SPIN_SYMBOL_PATHS := [
	"res://assets/wheel/segments/W101_gold_small.png",
	"res://assets/wheel/segments/W102_gold_medium.png",
	"res://assets/wheel/segments/W103_gold_large.png",
	"res://assets/wheel/segments/W104_shield.png",
	"res://assets/wheel/segments/W105_attack_fallback.png",
	"res://assets/wheel/segments/W106_puzzle_bonus.png",
	"res://assets/wheel/segments/W107_bonus_spins.png",
	"res://assets/wheel/segments/W108_special.png"
]

@onready var first_session_hint_p0: Label = %FirstSessionHintP0
@onready var boss_proximity_p0: Label = %BossProximityP0
@onready var p0_debug_toggle: Button = %P0DebugToggle
@onready var p0_debug_panel: PanelContainer = %P0DebugPanel
@onready var p0_debug_status: Label = %P0DebugStatus
@onready var debug_fresh: Button = %DebugFresh
@onready var debug_half_boss: Button = %DebugHalfBoss
@onready var debug_boss: Button = %DebugBoss
@onready var debug_wheel: Button = %DebugWheel
@onready var debug_village: Button = %DebugVillage
@onready var debug_return: Button = %DebugReturn
@onready var debug_low_resource: Button = %DebugLowResource
@onready var debug_recovery: Button = %DebugRecovery
@onready var debug_close: Button = %DebugClose
@onready var p02_core_controller: Node = $P02CoreController
@onready var goldmine_ui_timer_p0: Timer = %GoldmineUiTimerP0
@onready var gold_label: Label = %GoldLabel
@onready var spins_label: Label = %SpinsLabel
@onready var shields_label: Label = %ShieldsLabel
@onready var level_label: Label = %LevelLabel

@onready var view_tap: Control = %View_TapHero
@onready var view_rad: Control = %View_CoinMaster
@onready var view_dorf: Control = %View_ClashDorf
@onready var view_heroes: Control = %View_Heroes
@onready var view_attack: Control = %View_LaneAttack
@onready var view_defense: Control = %View_TowerDefense
@onready var view_daily: Control = %View_Daily
@onready var view_quests: Control = %View_Quests

@onready var btn_tap: Button = %Btn_Tap
@onready var btn_rad: Button = %Btn_Rad
@onready var btn_dorf: Button = %Btn_Dorf
@onready var btn_heroes: Button = %Btn_Heroes
@onready var btn_attack: Button = %Btn_Attack
@onready var btn_defense: Button = %Btn_Defense
@onready var journey_button: Button = %JourneyButton
@onready var meta_button: Button = %MetaButton
@onready var puzzle_button: Button = %PuzzleButton
@onready var defense_game_button: Button = %DefenseGameButton
@onready var lane_battle_button: Button = %LaneBattleButton
@onready var heroes_game_button: Button = %HeroesGameButton
@onready var hero_equipment_hint: Label = %HeroEquipmentHint
@onready var hero_weapon_button: Button = %HeroWeaponButton
@onready var hero_charm_button: Button = %HeroCharmButton
@onready var hero_upgrade_button_p0: Button = %HeroUpgradeButtonP0
@onready var hero_mastery_label_p0: Label = %HeroMasteryLabelP0
@onready var hero_mastery_bar_p0: ProgressBar = %HeroMasteryBarP0
@onready var hero_specialization_button_p0: Button = %HeroSpecializationButtonP0
@onready var hero_mastery_claim_p0: Button = %HeroMasteryClaimP0
@onready var view_tower_defense: Control = %View_TowerDefense
@onready var td_status_label: Label = %TDWaveLabel
@onready var td_enemy_label: Label = %TDTimer
@onready var td_lane_label: Label = %TDEnergyLabel
@onready var td_tower_label: Label = %TDTowerStatusP0
@onready var td_build_button: Button = %TDUpgradeButton
@onready var td_fight_button: Button = %TDFightButtonP0
@onready var td_result_label: Label = %TDResult
@onready var td_stage_label_p0: Label = %TDStageLabelP0
@onready var td_mastery_label_p0: Label = %TDMasteryLabelP0
@onready var td_mastery_bar_p0: ProgressBar = %TDMasteryBarP0
@onready var td_tech_button_p0: Button = %TDTechButtonP0
@onready var td_mastery_claim_p0: Button = %TDMasteryClaimP0
@onready var td_restart_button_p0: Button = %TDRestartButtonP0
@onready var view_puzzle: Control = %View_Puzzle
@onready var puzzle_status_label: Label = %PuzzleStatusLabel
@onready var puzzle_hint_label: Label = %PuzzleHintLabel
@onready var puzzle_result_label: Label = %PuzzleResultLabel
@onready var puzzle_stage_label_p0: Label = %PuzzleStageLabelP0
@onready var puzzle_mastery_label_p0: Label = %PuzzleMasteryLabelP0
@onready var puzzle_mastery_bar_p0: ProgressBar = %PuzzleMasteryBarP0
@onready var puzzle_mastery_claim_p0: Button = %PuzzleMasteryClaimP0
@onready var puzzle_cells: Array[Button] = [%PuzzleCell0,%PuzzleCell1,%PuzzleCell2,%PuzzleCell3,%PuzzleCell4,%PuzzleCell5,%PuzzleCell6,%PuzzleCell7,%PuzzleCell8]
@onready var view_meta: Control = %View_Meta
@onready var event_progress_label: Label = %EventProgressLabel
@onready var event_claim_button: Button = %EventClaimButton
@onready var ranking_rows_label: Label = %RankingRowsLabel
@onready var realm_chest_status: Label = %RealmChestStatus
@onready var realm_chest_button: Button = %RealmChestButton
@onready var meta_result_label: Label = %MetaResultLabel
@onready var view_journey: Control = %View_RealmJourney
@onready var journey_progress_label: Label = %JourneyProgressLabel
@onready var journey_nodes_label: Label = %JourneyNodesLabel
@onready var journey_dice_label: Label = %JourneyDiceLabel
@onready var journey_node_detail_p0: Label = %JourneyNodeDetailP0
@onready var journey_mastery_label: Label = %JourneyMasteryLabel
@onready var journey_mastery_bar_p0: ProgressBar = %JourneyMasteryBarP0
@onready var journey_mastery_claim_p0: Button = %JourneyMasteryClaimP0
@onready var journey_cache_p0: Button = %JourneyCacheP0
@onready var dice_roll_button: Button = %DiceRollButton
@onready var dice_result_label: Label = %DiceResultLabel
@onready var treasure_portal_status: Label = %TreasurePortalStatus
@onready var treasure_portal_button: Button = %TreasurePortalButton

@onready var monster_button: TextureButton = %MonsterButton
@onready var home_wheel_cta: Button = %HomeWheelCTA
@onready var monster_hp: ProgressBar = %MonsterHP
@onready var monster_level_label: Label = %MonsterLevelLabel
@onready var region_progress_title: Label = %RegionProgressTitle
@onready var region_progress_bar: ProgressBar = %RegionProgressBar
@onready var region_progress_text: Label = %RegionProgressText
@onready var monster_hp_label: Label = %MonsterHPLabel
@onready var damage_label: Label = %DamageLabel
@onready var reward_label: Label = %RewardLabel

@onready var spin_button: Button = %SpinButton
@onready var wheel_result: Label = %WheelResult
@onready var reel_1: TextureRect = %Reel1
@onready var reel_2: TextureRect = %Reel2
@onready var reel_3: TextureRect = %Reel3
@onready var payline: TextureRect = %Payline
@onready var spin_status_label: Label = %SpinStatusLabel
@onready var no_spins_panel: PanelContainer = %NoSpinsPanel
@onready var no_spins_text: Label = %NoSpinsText
@onready var no_spins_close: Button = %NoSpinsClose
@onready var jackpot_flash: ColorRect = %JackpotFlash
@onready var jackpot_label: Label = %JackpotLabel
@onready var win_line_label: Label = %WinLineLabel
@onready var spin_reel_presenter: SpinReelPresenter = %SpinReelPresenter

var spin_symbol_textures: Array[Texture2D] = []
@onready var wheel_reward_overlay_p0: Control = %WheelRewardOverlayP0
@onready var wheel_reward_title_p0: Label = %WheelRewardTitleP0
@onready var wheel_reward_text_p0: Label = %WheelRewardTextP0
@onready var wheel_reward_continue_p0: Button = %WheelRewardContinueP0
@onready var wheel_reward_icon_p0: TextureRect = %WheelRewardIconP0

@onready var building_townhall: Button = %BuildingTownhall
@onready var building_goldmine: Button = %BuildingGoldmine
@onready var building_forge: Button = %BuildingForge
@onready var building_luck: Button = %BuildingLuck
@onready var goldmine_status_p0: Label = %GoldmineStatusP0
@onready var goldmine_claim_button_p0: Button = %GoldmineClaimButtonP0
@onready var village_growth_label_v153: Label = %VillageGrowthLabelV153
@onready var village_growth_bar_v153: ProgressBar = %VillageGrowthBarV153
@onready var village_forge_action_v153: Button = %VillageForgeActionV153
@onready var village_temple_action_v153: Button = %VillageTempleActionV153
@onready var village_prosperity_claim_v153: Button = %VillageProsperityClaimV153
@onready var kill_milestone_p0: Label = %KillMilestoneP0
@onready var building_upgrade_overlay_p0: TextureRect = %BuildingUpgradeOverlayP0
@onready var building_upgrade_title_p0: Label = %BuildingUpgradeTitleP0
@onready var building_upgrade_effect_p0: Label = %BuildingUpgradeEffectP0
@onready var building_upgrade_cost_p0: Label = %BuildingUpgradeCostP0
@onready var building_upgrade_button_p0: Button = %BuildingUpgradeButtonP0
@onready var building_upgrade_close_p0: Button = %BuildingUpgradeCloseP0
@onready var building_stage_preview: HBoxContainer = %BuildingStagePreview
@onready var building_stage_1: TextureRect = %Stage1
@onready var building_stage_2: TextureRect = %Stage2
@onready var building_stage_3: TextureRect = %Stage3
@onready var building_stage_label: Label = %BuildingStageLabel
@onready var village_ground: TextureRect = %VillageGround
@onready var upgrade_coin_burst_p0: TextureRect = %UpgradeCoinBurstP0
@onready var building_townhall_art: TextureRect = %BuildingTownhallArt
@onready var building_goldmine_art: TextureRect = %BuildingGoldmineArt
@onready var building_forge_art: TextureRect = %BuildingForgeArt
@onready var building_luck_art: TextureRect = %BuildingLuckArt
@onready var settings_button_p0: Button = %SettingsButtonP0
@onready var level_up_overlay_p0: TextureRect = %LevelUpOverlayP0
@onready var level_up_text_p0: Label = %LevelUpTextP0
@onready var level_up_continue_p0: Button = %LevelUpContinueP0
@onready var settings_overlay_p0: TextureRect = %SettingsOverlayP0
@onready var sound_toggle_p0: Button = %SoundToggleP0
@onready var music_toggle_p0: Button = %MusicToggleP0
@onready var haptics_toggle_p0: Button = %HapticsToggleP0
@onready var settings_close_p0: Button = %SettingsCloseP0
@onready var reward_pulse_p0: TextureRect = %RewardPulseP0
@onready var boss_shield_fx_p0: TextureRect = %BossShieldFxP0
@onready var boss_reward_chest_p0: TextureRect = %BossRewardChestP0
@onready var boss_chest_glow_p0: TextureRect = %BossChestGlowP0
@onready var core_transition_p0: TextureRect = %CoreTransitionP0
@onready var reduced_motion_toggle_p0: Button = %ReducedMotionToggleP0
@onready var damage_numbers_toggle_p0: Button = %DamageNumbersToggleP0
@onready var screen_shake_toggle_p0: Button = %ScreenShakeToggleP0
@onready var language_toggle_p0: Button = %LanguageToggleP0
@onready var account_button_p0: Button = %AccountButtonP0
@onready var support_button_p0: Button = %SupportButtonP0
@onready var account_overlay_p0: PanelContainer = %AccountOverlayP0
@onready var account_status_p0: Label = %AccountStatusP0
@onready var account_progress_p0: Label = %AccountProgressP0
@onready var cloud_status_p0: Label = %CloudStatusP0
@onready var link_guest_p0: Button = %LinkGuestP0
@onready var cloud_info_p0: Button = %CloudInfoP0
@onready var account_message_p0: Label = %AccountMessageP0
@onready var account_close_p0: Button = %AccountCloseP0
@onready var support_overlay_p0: PanelContainer = %SupportOverlayP0
@onready var support_status_p0: Label = %SupportStatusP0
@onready var support_help_p0: Button = %SupportHelpP0
@onready var support_privacy_p0: Button = %SupportPrivacyP0
@onready var support_terms_p0: Button = %SupportTermsP0
@onready var support_imprint_p0: Button = %SupportImprintP0
@onready var support_close_p0: Button = %SupportCloseP0
@onready var social_hub_button_p0: Button = %SocialHubButtonP0
@onready var social_overlay_p0: PanelContainer = %SocialOverlayP0
@onready var social_profile_p0: Label = %SocialProfileP0
@onready var social_stats_p0: Label = %SocialStatsP0
@onready var social_inbox_p0: Button = %SocialInboxP0
@onready var social_achievements_p0: Button = %SocialAchievementsP0
@onready var social_friends_p0: Button = %SocialFriendsP0
@onready var social_content_p0: Label = %SocialContentP0
@onready var social_action_p0: Button = %SocialActionP0
@onready var social_close_p0: Button = %SocialCloseP0
@onready var more_features_button_p0: Button = %MoreFeaturesButtonP0
@onready var quick_badge_p0: Label = %QuickBadgeP0
@onready var feature_hub_overlay_p0: PanelContainer = %FeatureHubOverlayP0
@onready var feature_hub_close_p0: Button = %FeatureHubCloseP0
@onready var hub_heroes_p0: Button = %HubHeroesP0
@onready var hub_puzzle_p0: Button = %HubPuzzleP0
@onready var hub_defense_p0: Button = %HubDefenseP0
@onready var hub_lane_p0: Button = %HubLaneP0
@onready var hub_meta_p0: Button = %HubMetaP0
@onready var hub_profile_p0: Button = %HubProfileP0
@onready var hub_shop_p0: Button = %HubShopP0
@onready var hub_liveops_p0: Button = %HubLiveOpsP0
@onready var hub_progression_p0: Button = %HubProgressionP0
@onready var hub_journey_p0: Button = %HubJourneyP0
@onready var feature_hub_status_v154: Label = %FeatureHubStatusV154

@onready var liveops_overlay_p0: PanelContainer = %LiveOpsOverlayP0
@onready var halloween_status_p0: Label = %HalloweenStatusP0
@onready var halloween_progress_p0: Label = %HalloweenProgressP0
@onready var halloween_claim_p0: Button = %HalloweenClaimP0
@onready var halloween_currency_p0: Label = %HalloweenCurrencyP0
@onready var halloween_quests_p0: Label = %HalloweenQuestsP0
@onready var halloween_quest_claim_p0: Button = %HalloweenQuestClaimP0
@onready var halloween_chest_p0: Button = %HalloweenChestP0
@onready var ranking_daily_p0: Button = %RankingDailyP0
@onready var ranking_weekly_p0: Button = %RankingWeeklyP0
@onready var ranking_event_p0: Button = %RankingEventP0
@onready var ranking_status_p0: Label = %RankingStatusP0
@onready var ranking_reward_preview_p0: Label = %RankingRewardPreviewP0
@onready var ranking_claim_p0: Button = %RankingClaimP0
@onready var liveops_close_p0: Button = %LiveOpsCloseP0

@onready var shop_overlay_p0: PanelContainer = %ShopOverlayP0
@onready var shop_catalog_p0: Label = %ShopCatalogP0
@onready var shop_status_p0: Label = %ShopStatusP0
@onready var shop_close_p0: Button = %ShopCloseP0

@onready var progression_overlay_p0: PanelContainer = %ProgressionOverlayP0
@onready var progression_text_p0: Label = %ProgressionTextP0
@onready var progression_close_p0: Button = %ProgressionCloseP0

@onready var afk_overlay_p0: PanelContainer = %AfkOverlayP0
@onready var afk_text_p0: Label = %AfkTextP0
@onready var afk_claim_p0: Button = %AfkClaimP0

@onready var town_hall_button: Button = %TownHallButton
@onready var town_hall_art: TextureRect = %TownHallArt
@onready var gold_mine_art: TextureRect = %GoldMineArt
@onready var forge_art: TextureRect = %ForgeArt
@onready var gold_mine_label: Label = %GoldMineLabel
@onready var forge_label: Label = %ForgeLabel
@onready var reward_burst: TextureRect = %RewardBurst
@onready var monster_progress_label: Label = %MonsterProgressLabel
@onready var monster_reward_overlay: TextureRect = %MonsterRewardOverlay
@onready var monster_reward_title: Label = %MonsterRewardTitle
@onready var monster_reward_text: Label = %MonsterRewardText
@onready var monster_reward_continue: Button = %MonsterRewardContinue
@onready var boss_intro_overlay: Control = %BossIntroOverlay
@onready var boss_intro_label: Label = %BossIntroLabel
@onready var boss_defeat_burst: TextureRect = %BossDefeatBurst
@onready var building_select_glow: TextureRect = %BuildingSelectGlow
@onready var monster_hit_overlay: TextureRect = %MonsterHitOverlay
@onready var lane_timer: Label = %LaneTimer
@onready var lane_enemy_hp: ProgressBar = %EnemyHP
@onready var lane_energy_label: Label = %EnergyLabel
@onready var lane_left_button: Button = %LaneLeftButton
@onready var lane_right_button: Button = %LaneRightButton
@onready var lane_result: Label = %LaneResult
@onready var lane_left_unit: TextureRect = %LaneLeftUnit
@onready var lane_right_unit: TextureRect = %LaneRightUnit
@onready var lane_stage_label_p0: Label = %LaneStageLabelP0
@onready var lane_mastery_label_p0: Label = %LaneMasteryLabelP0
@onready var lane_mastery_bar_p0: ProgressBar = %LaneMasteryBarP0
@onready var lane_tech_button_p0: Button = %LaneTechButtonP0
@onready var lane_mastery_claim_p0: Button = %LaneMasteryClaimP0
@onready var lane_next_battle_p0: Button = %LaneNextBattleP0

@onready var td_timer: Label = %TDTimer
@onready var td_core_hp: ProgressBar = %TDCoreHP
@onready var td_wave_label: Label = %TDWaveLabel
@onready var td_energy_label: Label = %TDEnergyLabel
@onready var td_upgrade_button: Button = %TDUpgradeButton
@onready var td_result: Label = %TDResult
@onready var td_enemy_marker: TextureRect = %TDEnemyMarker

@onready var daily_button: Button = %DailyButton
@onready var quest_button: Button = %QuestButton
@onready var daily_status_label: Label = %DailyStatusLabel
@onready var daily_cycle_label: Label = %DailyCycleLabel
@onready var daily_claim_button: Button = %DailyClaimButton
@onready var quest_list: VBoxContainer = %QuestList
@onready var quest_summary_label: Label = %QuestSummaryLabel
@onready var unlock_banner: TextureRect = %UnlockBanner
@onready var unlock_banner_label: Label = %UnlockBannerLabel
@onready var reward_modal: TextureRect = %RewardModal
@onready var reward_modal_title: Label = %RewardModalTitle
@onready var reward_modal_text: Label = %RewardModalText
@onready var reward_modal_close: Button = %RewardModalClose
@onready var tap_upgrade_button: Button = %TapUpgradeButton

@onready var auto_dps_label: Label = %AutoDPSLabel
@onready var hero_knight: Button = %HeroKnight
@onready var hero_archer: Button = %HeroArcher
@onready var hero_mage: Button = %HeroMage

var damage_tween: Tween
var damage_feedback_index_p0: int = 0
var hp_tween: Tween
var monster_reaction_active: bool = false
var monster_idle_clock: float = 0.0
var wheel_spinning: bool = false
var selected_building_id: String = "townhall"
var last_seen_player_level: int = 1
var monster_state_locked: bool = false
var core_transitioning: bool = false
var boss_cycle_count: int = 0
var core_input_locked: bool = false
var last_kill_milestone_cycle: int = -1
var selected_hero_id: String = "knight"

var first_session_hint_stage: int = 0
var first_session_hint_tween: Tween


func _ready() -> void:
	_load_spin_symbol_textures()
	spin_reel_presenter.configure([reel_1, reel_2, reel_3], spin_symbol_textures, payline, spin_status_label, win_line_label)
	_connect_once(spin_reel_presenter.reel_stopped, _on_spin_reel_stopped)
	p02_core_controller.apply(self)
	CoreAnalytics.log_event("game_start")
	_connect_once(PlayerData.stats_changed, _refresh_all)
	_connect_once(PlayerData.monster_changed, _update_monster_ui)
	_connect_once(PlayerData.progression_changed, _refresh_all)
	_connect_once(MonsterDefeatService.defeat_committed, _on_monster_defeat_committed_v143)
	_connect_once(RemoteGameplayService.spin_result_received, _on_remote_spin_result_v181)
	_connect_once(CombatMomentumSystem.momentum_changed, _on_combat_momentum_changed_v172)
	_connect_once(CoreProgressionSynergySystem.synergy_changed, _refresh_core_synergy_v174)
	_setup_optional_p1_runtime()
	if FeatureFlags.SHOW_LANE_BATTLE:
		lane_battle_button.visible = true
		lane_battle_button.pressed.connect(_open_lane_battle_slice)
		lane_left_button.pressed.connect(func(): _deploy_lane_unit(0))
		lane_right_button.pressed.connect(func(): _deploy_lane_unit(1))
		lane_tech_button_p0.pressed.connect(_upgrade_lane_tech_v150)
		lane_mastery_claim_p0.pressed.connect(_claim_lane_mastery_v150)
		lane_next_battle_p0.pressed.connect(_start_next_lane_battle_v150)
		_connect_once(LaneAttackSystem.battle_updated, _update_lane_ui)
		_connect_once(LaneAttackSystem.battle_finished, _on_lane_finished)
		_connect_once(LaneBattleProgressionSystem.lane_progression_changed, _refresh_lane_progression_v150)
	else:
		lane_battle_button.visible = false
	if FeatureFlags.SHOW_TOWER_DEFENSE:
		defense_game_button.visible = true
		defense_game_button.pressed.connect(func(): _open_core_view(view_tower_defense,"tower_defense_open"))
		td_build_button.pressed.connect(_on_td_build_pressed)
		td_fight_button.pressed.connect(_on_td_fight_pressed)
		td_tech_button_p0.pressed.connect(_on_td_tech_pressed_v149)
		td_mastery_claim_p0.pressed.connect(_claim_td_mastery_p0)
		td_restart_button_p0.pressed.connect(_restart_td_run_v149)
		_connect_once(TowerDefenseSystem.td_changed, _refresh_td_ui)
		_connect_once(TowerDefenseProgressionSystem.td_progression_changed, _refresh_td_ui)
	else:
		defense_game_button.visible = false
	if FeatureFlags.SHOW_PUZZLE:
		puzzle_button.visible = true
		puzzle_button.pressed.connect(func(): _open_core_view(view_puzzle,"puzzle_open"))
		for i in range(puzzle_cells.size()):
			var cell_index := i
			puzzle_cells[i].pressed.connect(func(): _on_puzzle_cell_pressed(cell_index))
		puzzle_mastery_claim_p0.pressed.connect(_claim_puzzle_mastery_p0)
		_connect_once(PuzzleProgressionSystem.puzzle_progression_changed, _refresh_puzzle_ui)
		_connect_once(PuzzleSystem.puzzle_changed, _refresh_puzzle_ui)
	else:
		puzzle_button.visible = false
	if FeatureFlags.SHOW_EVENTS or FeatureFlags.SHOW_RANKINGS or FeatureFlags.SHOW_REALM_CHEST:
		meta_button.visible = true
		meta_button.pressed.connect(func(): _open_core_view(view_meta,"meta_open"))
		event_claim_button.pressed.connect(_on_event_claim_pressed)
		realm_chest_button.pressed.connect(_on_realm_chest_pressed)
		_connect_once(MetaProgressSystem.meta_changed, _refresh_meta_ui)
	else:
		meta_button.visible = false
	if FeatureFlags.SHOW_REALM_JOURNEY:
		journey_button.visible = true
		journey_button.pressed.connect(_open_journey_p0)
		dice_roll_button.pressed.connect(_on_dice_roll_pressed)
		journey_mastery_claim_p0.pressed.connect(_claim_journey_mastery_p0)
		journey_cache_p0.pressed.connect(_open_journey_cache_p0)
		_connect_once(JourneyProgressionSystem.journey_progression_changed, _refresh_journey_ui)
		treasure_portal_button.pressed.connect(_on_treasure_portal_pressed)
		_connect_once(DiceJourneySystem.journey_changed, _refresh_journey_ui)
	else:
		journey_button.visible = false

	btn_tap.pressed.connect(func(): _open_core_view(view_tap,"home_open"))
	btn_rad.pressed.connect(func(): _open_core_view(view_rad,"wheel_open"))
	home_wheel_cta.pressed.connect(func(): _open_core_view(view_rad,"wheel_open"))
	btn_dorf.pressed.connect(func(): _open_core_view(view_dorf,"village_open"))
	monster_reward_continue.pressed.connect(_continue_after_monster_reward)
	wheel_reward_continue_p0.pressed.connect(_close_wheel_reward)
	building_townhall.pressed.connect(func(): _open_building_upgrade("townhall"))
	building_goldmine.pressed.connect(func(): _open_building_upgrade("goldmine"))
	building_forge.pressed.connect(func(): _open_building_upgrade("forge"))
	building_luck.pressed.connect(func(): _open_building_upgrade("lucktemple"))
	goldmine_claim_button_p0.pressed.connect(_claim_goldmine_p0)
	village_forge_action_v153.pressed.connect(_craft_forge_v153)
	village_temple_action_v153.pressed.connect(_claim_temple_blessing_v153)
	village_prosperity_claim_v153.pressed.connect(_claim_village_prosperity_v153)
	_connect_once(VillageProgressionSystem.village_progression_changed, _refresh_p0_village)
	_connect_once(goldmine_ui_timer_p0.timeout, _on_goldmine_ui_timer_p0)
	building_upgrade_button_p0.pressed.connect(_upgrade_selected_building)
	building_upgrade_close_p0.pressed.connect(_close_building_upgrade_p0)
	_connect_once(P0VillageSystem.village_changed, _refresh_p0_village)
	settings_button_p0.pressed.connect(_open_settings_p0)
	level_up_continue_p0.pressed.connect(_close_level_up_p0)
	sound_toggle_p0.pressed.connect(SettingsService.toggle_sound)
	music_toggle_p0.pressed.connect(SettingsService.toggle_music)
	haptics_toggle_p0.pressed.connect(SettingsService.toggle_haptics)
	settings_close_p0.pressed.connect(_close_settings_p0)
	reduced_motion_toggle_p0.pressed.connect(SettingsService.toggle_reduced_motion)
	damage_numbers_toggle_p0.pressed.connect(SettingsService.toggle_damage_numbers)
	screen_shake_toggle_p0.pressed.connect(SettingsService.toggle_screen_shake)
	language_toggle_p0.pressed.connect(SettingsService.cycle_language)
	account_button_p0.pressed.connect(_open_account_p0)
	support_button_p0.pressed.connect(_open_support_p0)
	account_close_p0.pressed.connect(_close_account_p0)
	support_close_p0.pressed.connect(_close_support_p0)
	link_guest_p0.pressed.connect(_account_link_info_p0)
	cloud_info_p0.pressed.connect(_cloud_info_p0)
	support_help_p0.pressed.connect(func(): _support_info_p0("Help Center"))
	support_privacy_p0.pressed.connect(func(): _support_info_p0("Datenschutz"))
	support_terms_p0.pressed.connect(func(): _support_info_p0("Nutzungsbedingungen"))
	support_imprint_p0.pressed.connect(func(): _support_info_p0("Impressum"))
	social_hub_button_p0.pressed.connect(_open_social_p0)
	social_close_p0.pressed.connect(_close_social_p0)
	social_inbox_p0.pressed.connect(_show_social_inbox_p0)
	social_achievements_p0.pressed.connect(_show_social_achievements_p0)
	social_friends_p0.pressed.connect(_show_social_friends_p0)
	social_action_p0.pressed.connect(_social_primary_action_p0)
	_connect_once(SocialHubSystem.social_changed, _refresh_social_header_p0)
	more_features_button_p0.pressed.connect(_open_feature_hub_p0)
	feature_hub_close_p0.pressed.connect(_close_feature_hub_p0)
	hub_heroes_p0.pressed.connect(_hub_open_heroes_p0)
	hub_journey_p0.pressed.connect(_hub_open_journey_v154)
	hub_puzzle_p0.pressed.connect(_hub_open_puzzle_p0)
	hub_defense_p0.pressed.connect(_hub_open_defense_p0)
	hub_lane_p0.pressed.connect(_hub_open_lane_p0)
	hub_meta_p0.pressed.connect(_hub_open_meta_p0)
	hub_profile_p0.pressed.connect(_hub_open_profile_p0)
	hub_shop_p0.pressed.connect(_hub_open_shop_p0)
	hub_liveops_p0.pressed.connect(_hub_open_liveops_p0)
	hub_progression_p0.pressed.connect(_hub_open_progression_p0)
	shop_close_p0.pressed.connect(_close_shop_p0)
	liveops_close_p0.pressed.connect(_close_liveops_p0)
	progression_close_p0.pressed.connect(_close_progression_p0)
	afk_claim_p0.pressed.connect(_claim_afk_reward_p0)
	halloween_claim_p0.pressed.connect(_claim_halloween_p0)
	halloween_quest_claim_p0.pressed.connect(_claim_halloween_quests_p0)
	halloween_chest_p0.pressed.connect(_open_halloween_chest_p0)
	ranking_daily_p0.pressed.connect(func(): _select_ranking_p0("daily"))
	ranking_weekly_p0.pressed.connect(func(): _select_ranking_p0("weekly"))
	ranking_event_p0.pressed.connect(func(): _select_ranking_p0("event"))
	ranking_claim_p0.pressed.connect(_claim_ranking_reward_p0)
	_connect_once(LiveOpsRankingSystem.liveops_changed, _refresh_liveops_p0)
	_connect_once(AfkRewardSystem.afk_changed, _refresh_afk_p0)
	_connect_once(MetaProgressSystem.meta_changed, _refresh_social_header_p0)
	_connect_once(P0VillageSystem.village_changed, _refresh_social_header_p0)
	_connect_once(AccountState.account_changed, _refresh_account_p0)
	_connect_once(SettingsService.settings_changed, _refresh_settings_p0)
	_connect_once(SettingsService.settings_changed, AudioService.sync_settings)

	monster_button.pressed.connect(_on_monster_pressed)
	spin_button.pressed.connect(_on_spin_pressed)
	no_spins_close.pressed.connect(_close_no_spins_state)
	# V1.53: legacy hidden TownHallButton kept for source compatibility, but no active upgrade path.
	tap_upgrade_button.pressed.connect(_on_tap_upgrade_pressed)

	SaveGame.load_game()
	var puzzle_daily_reset := PuzzleSystem.ensure_daily_attempts()
	selected_hero_id = HeroSystem.get_selected_hero_id()
	var afk_prepared := AfkRewardSystem.prepare_from_seconds_away(SaveGame.seconds_away_on_last_load)
	if not AccountState.is_guest() or puzzle_daily_reset or afk_prepared:
		SaveGame.save_game()
	_reset_core_transient_state()
	call_deferred("_apply_mobile_runtime_polish")
	_connect_once(get_viewport().size_changed, _on_viewport_size_changed)
	AudioService.initialize_after_save()
	CoreAcceptanceService.begin_session()
	CoreAcceptanceService.log_contract_status()
	_setup_p0_debug_harness()
	_setup_core_touch_feedback()
	last_seen_player_level = PlayerData.player_level
	_refresh_all()
	if FeatureFlags.SHOW_QUESTS:
		_rebuild_quests()
	if FeatureFlags.SHOW_DAILY:
		_update_daily_ui()
	if FeatureFlags.SHOW_HEROES or FeatureFlags.SHOW_ATTACK or FeatureFlags.SHOW_DEFENSE:
		UnlockService.refresh()
	_switch_view(view_tap)
	_restore_next_pending_presentation_v154()
	_refresh_first_session_flow()
	P0BootDiagnostics.complete_scene_boot(self)

func _apply_mobile_runtime_polish() -> void:
	ResponsiveLayout.apply(self)
	_apply_production_art_v158()
	UiCopyCalibration.apply(self)
	ScreenCompositionService.new().apply(self)
	ScreenAssetBinder.apply(self)
	ProductionAssetConvergenceV187.apply(self)
	ProductionAssetConvergenceV188.apply(self)
	ProductionAssetConvergenceV189.apply(self)
	ProductionAssetConvergenceV193.apply(self)
	ScreenUiAssemblyService.apply(self)
	RuntimeGuidanceService.refresh(self)
	FinalAlphaConvergenceV200.validate_and_reset(self)

func _apply_production_art_v158() -> void:
	# V1.58: verified production-atlas binding + screen calibration. Text and logic remain runtime-owned.
	ProductionUiBinder.apply_backdrop(quest_summary_label, "ui.quest.summary", true, 0.12)
	ProductionUiBinder.apply_backdrop(shop_catalog_p0, "ui.shop.featured", true, 0.12)
	ProductionUiBinder.apply_backdrop(progression_text_p0, "ui.progression.overview", true, 0.12)
	ProductionUiBinder.apply_backdrop(afk_text_p0, "ui.afk.summary", true, 0.12)
	ProductionUiBinder.apply_backdrop(ranking_status_p0, "ui.ranking.header", true, 0.12)
	ProductionUiBinder.apply_backdrop(ranking_reward_preview_p0, "ui.ranking.reward", true, 0.12)
	ProductionUiBinder.apply_backdrop(ranking_daily_p0, "ui.ranking.tab", true, 0.18, true)
	ProductionUiBinder.apply_backdrop(ranking_weekly_p0, "ui.ranking.tab", true, 0.18, true)
	ProductionUiBinder.apply_backdrop(ranking_event_p0, "ui.ranking.tab", true, 0.18, true)
	ProductionUiBinder.apply_backdrop(afk_claim_p0, "ui.afk.claim", true, 0.18, true)
	var spin_machine := find_child("SpinMachineFrame", true, false) as TextureRect
	if spin_machine:
		ProductionUiBinder.apply_texture(spin_machine, "spin.machine.frame", false)
	var payline_tex := AssetRegistry.production_texture_for("spin.payline", true)
	if payline_tex != null:
		payline.texture = payline_tex
	_apply_monster_hp_art_v158()
	_apply_spin_button_art_v156()

func _apply_monster_hp_art_v158() -> void:
	var boss := P0MonsterVisualSystem.is_boss(PlayerData.monster_level)
	var role_id := "ui.monster.hp.boss" if boss else "ui.monster.hp.normal"
	ProductionUiBinder.apply_backdrop(monster_hp, role_id, false, 0.24, true)

func _apply_spin_button_art_v156() -> void:
	var role_id := "spin.control.disabled" if PlayerData.spins <= 0 else "spin.control.ready"
	ProductionUiBinder.apply_backdrop(spin_button, role_id, true, 0.22, true)

func _restore_next_pending_presentation_v154()->void:
	if _core_modal_open() or core_transitioning:
		return
	var kind:=RuntimeFlowService.pending_kind()
	if kind.is_empty():
		return
	CoreAnalytics.log_event("pending_flow_resume",{"kind":kind,"count":RuntimeFlowService.pending_count(),"flow_version":RuntimeFlowService.FLOW_VERSION})
	match kind:
		"spin": _restore_pending_spin_presentation()
		"journey": _restore_pending_journey_presentation()
		"puzzle": _restore_pending_puzzle_completion_v148()
		"tower_defense": _restore_pending_td_run_v149()
		"lane_battle": _restore_pending_lane_battle_v150()
		"village_upgrade": _restore_pending_village_upgrade_v153()
		"afk": _show_afk_if_pending_p0()

func _continue_pending_flow_v154()->void:
	if _core_modal_open() or core_transitioning:
		return
	call_deferred("_restore_next_pending_presentation_v154")

func _setup_optional_p1_runtime() -> void:
	# P0 release-isolation: hidden P1 systems may stay in source, but they must
	# not wire runtime signals or controls unless their feature flag is enabled.
	if FeatureFlags.SHOW_HEROES:
		heroes_game_button.visible = true
		_connect_once(HeroSystem.auto_damage_done, _on_auto_damage)
		_connect_once(HeroSystem.heroes_changed, _update_hero_ui)
		_connect_once(hero_knight.pressed, func(): _select_hero_p0("knight"))
		_connect_once(hero_archer.pressed, func(): _select_hero_p0("archer"))
		_connect_once(hero_mage.pressed, func(): _select_hero_p0("mage"))
		_connect_once(heroes_game_button.pressed, _open_heroes_slice)
		_connect_once(hero_weapon_button.pressed, func(): _upgrade_hero_equipment("weapon"))
		_connect_once(hero_charm_button.pressed, func(): _upgrade_hero_equipment("charm"))
		_connect_once(hero_upgrade_button_p0.pressed, _upgrade_selected_hero_p0)
		_connect_once(hero_specialization_button_p0.pressed, _toggle_hero_specialization_v151)
		_connect_once(hero_mastery_claim_p0.pressed, _claim_hero_mastery_v151)
		_connect_once(HeroProgressionSystem.hero_progression_changed, _update_hero_ui)
	else:
		heroes_game_button.visible = false

	if FeatureFlags.SHOW_ATTACK:
		_connect_once(btn_attack.pressed, _open_attack)
		_connect_once(lane_left_button.pressed, func(): LaneAttackSystem.deploy_hero(0))
		_connect_once(lane_right_button.pressed, func(): LaneAttackSystem.deploy_hero(1))
		_connect_once(LaneAttackSystem.battle_updated, _update_lane_ui)
		_connect_once(LaneAttackSystem.battle_finished, _on_lane_finished)

	if FeatureFlags.SHOW_DEFENSE:
		_connect_once(btn_defense.pressed, _open_defense)
		_connect_once(td_upgrade_button.pressed, _upgrade_defense_towers)
		_connect_once(TowerDefenseSystem.defense_updated, _update_td_ui)
		_connect_once(TowerDefenseSystem.defense_finished, _on_td_finished)

	if FeatureFlags.SHOW_DAILY:
		_connect_once(daily_button.pressed, _open_daily_slice)
		_connect_once(daily_claim_button.pressed, _claim_daily_reward)

	if FeatureFlags.SHOW_QUESTS:
		_connect_once(quest_button.pressed, _open_quests_slice)
		_connect_once(QuestSystem.quests_changed, _rebuild_quests)
		_connect_once(ObjectiveSystem.objectives_changed, _rebuild_quests)

	if FeatureFlags.SHOW_DAILY or FeatureFlags.SHOW_QUESTS:
		_connect_once(reward_modal_close.pressed, func(): reward_modal.visible = false)
		_connect_once(RewardService.reward_ready, _show_reward_modal)

	if FeatureFlags.SHOW_HEROES or FeatureFlags.SHOW_ATTACK or FeatureFlags.SHOW_DEFENSE:
		_connect_once(UnlockService.unlocked, _show_unlock_banner)

func _process(delta: float) -> void:
	monster_idle_clock += delta
	if not view_tap.visible or monster_reaction_active or monster_state_locked or core_input_locked:
		return
	var base_scale := Vector2(1.08,1.08) if P0MonsterVisualSystem.is_boss(PlayerData.monster_level) else Vector2.ONE
	if SettingsService.reduced_motion:
		monster_button.scale = base_scale
		monster_button.rotation = 0.0
		return
	var breath := sin(monster_idle_clock * 2.2)
	var sway := sin(monster_idle_clock * 1.35)
	monster_button.scale = base_scale * (1.0 + breath * 0.008)
	monster_button.rotation = deg_to_rad(sway * 0.45)

func _refresh_all() -> void:
	gold_label.text = "%s" % _compact_number(PlayerData.gold)
	spins_label.text = "%d" % PlayerData.spins
	shields_label.text = "%d/3" % PlayerData.shields
	level_label.text = "STUFE %d" % PlayerData.player_level
	_update_monster_ui()
	_update_monster_progress()
	_update_home_core_cta()
	_update_monster_visual()
	_update_village_ui()
	_refresh_p0_village()
	_refresh_spin_ui()
	_refresh_journey_ui()
	_refresh_meta_ui()
	_refresh_puzzle_ui()
	_refresh_region_progression_ui()
	_refresh_td_ui()
	_update_daily_ui()
	_rebuild_quests()
	_update_tap_upgrade_ui()
	_refresh_core_synergy_v174()

	_check_level_up_p0()
	_refresh_settings_p0()
	_refresh_social_header_p0()
	_refresh_liveops_p0()
	_refresh_progression_p0()
	_refresh_shop_p0()
	_refresh_afk_p0()
	_refresh_quick_action_badge_p0()
	_refresh_first_session_flow()
	RuntimeGuidanceService.refresh(self)

func _refresh_spin_ui() -> void:
	var available := maxi(PlayerData.spins, 0)
	spin_status_label.text = "%d SPINS · 1 JE DREHUNG · 3 WALZEN" % available
	spin_button.text = "KEINE SPINS" if available <= 0 else "DREHEN · 1 SPIN"
	if not wheel_spinning and not core_input_locked:
		spin_button.disabled = available <= 0
	_apply_spin_button_art_v156()
	win_line_label.text = "GEWINNLINIE · MITTLERE REIHE"
	var jackpot_amount := 600
	for segment in WheelSystem.segments:
		if str(segment.get("id","")) == "jackpot":
			jackpot_amount = int(segment.get("amount",600))
			break
	jackpot_label.text = "JACKPOT · +%d GOLD" % jackpot_amount

func _refresh_region_progression_ui() -> void:
	if region_progress_title == null or region_progress_bar == null or region_progress_text == null:
		return
	var next := RegionProgressionSystem.progress_to_next_region()
	region_progress_title.text = "REGION · GRÜNHAIN"
	if bool(next.get("complete",false)):
		region_progress_bar.value = 100.0
		region_progress_text.text = "REGIONS-FORTSCHRITT · AKTUELLER STAND ERREICHT"
		return
	region_progress_bar.value = float(next.get("progress",0.0)) * 100.0
	var remaining := int(next.get("levels_remaining",0))
	var target := int(next.get("unlock_level",20))
	if remaining <= 0:
		region_progress_text.text = "%s FREIGESCHALTET · CONTENT FOLGT" % str(next.get("name","NÄCHSTE REGION")).to_upper()
	else:
		region_progress_text.text = "%s · NOCH %d SPIELERSTUFEN · FREISCHALTUNG STUFE %d" % [
			str(next.get("name","NÄCHSTE REGION")).to_upper(), remaining, target
		]

func _refresh_td_ui() -> void:
	if not FeatureFlags.SHOW_TOWER_DEFENSE:
		return
	var total_waves := int(TowerDefenseSystem.config.get("waves",3))
	td_status_label.text = "WELLE %d / %d" % [TowerDefenseSystem.wave,total_waves]
	td_enemy_label.text = "FEIND · LEBEN %d" % TowerDefenseSystem.enemy_hp
	td_stage_label_p0.text = TowerDefenseProgressionSystem.stage_text()
	td_mastery_label_p0.text = TowerDefenseProgressionSystem.mastery_text()
	td_mastery_bar_p0.value = TowerDefenseProgressionSystem.mastery_ratio() * 100.0
	td_tower_label.text = "TÜRME · %d / %d · TECH · STUFE %d · +%d SCHADEN" % [
		TowerDefenseSystem.towers,
		int(TowerDefenseSystem.config.get("max_towers",2)),
		TowerDefenseProgressionSystem.tower_tech_level,
		TowerDefenseProgressionSystem.tower_damage_bonus()
	]
	td_lane_label.text = "ENERGIE · %d · TURM-KOSTEN %d" % [
		TowerDefenseSystem.energy,
		int(TowerDefenseSystem.config.get("tower_cost",2))
	]
	td_build_button.disabled = not TowerDefenseSystem.can_build() or core_input_locked
	td_build_button.text = "TURM BAUEN · %d ENERGIE" % int(TowerDefenseSystem.config.get("tower_cost",2))
	td_tech_button_p0.disabled = not TowerDefenseProgressionSystem.can_upgrade_tower_tech() or core_input_locked
	td_tech_button_p0.text = TowerDefenseProgressionSystem.tech_text()
	td_mastery_claim_p0.disabled = not TowerDefenseProgressionSystem.can_claim_mastery_reward() or core_input_locked
	td_mastery_claim_p0.text = "FORTSCHRITTS-BELOHNUNG ABHOLEN" if TowerDefenseProgressionSystem.can_claim_mastery_reward() else "FORTSCHRITTS-BELOHNUNG"
	td_fight_button.visible = not TowerDefenseSystem.run_completed
	td_restart_button_p0.visible = TowerDefenseSystem.run_completed
	td_fight_button.disabled = TowerDefenseSystem.towers <= 0 or TowerDefenseSystem.run_completed or core_input_locked
	td_fight_button.text = "WELLE %d VERTEIDIGEN" % TowerDefenseSystem.wave
	TowerDefenseVisualDirectorV192.refresh(self)
	if TowerDefenseSystem.run_completed:
		td_result_label.text = "STUFE GESCHAFFT · NÄCHSTE VERTEIDIGUNGS-STUFE BEREIT"

func _on_td_build_pressed() -> void:
	if core_input_locked or _core_modal_open(): return
	var result := TowerDefenseSystem.build_tower()
	if bool(result.get("ok",false)):
		td_result_label.text = "TURM GEBAUT · ENERGIE %d" % TowerDefenseSystem.energy
		CoreAnalytics.log_event("td_tower_built", {"towers":TowerDefenseSystem.towers})
		HapticsService.medium()
	else:
		td_result_label.text = str(result.get("message","Nicht möglich"))
	_refresh_all()

func _on_td_fight_pressed() -> void:
	if core_input_locked or _core_modal_open(): return
	core_input_locked=true
	var result := TowerDefenseSystem.defend_tick()
	if bool(result.get("completed",false)) or bool(result.get("wave_cleared",false)):
		LiveOpsRankingSystem.register_td_wave()
	if bool(result.get("completed",false)):
		ObjectiveSystem.register_action("td_win",1)
		td_result_label.text = "VERTEIDIGUNG · STUFE %d GESCHAFFT · +%d GOLD · +%d SPIN" % [
			int(result.get("stage",0)),
			int(result.get("gold",0)),
			int(result.get("spins",0))
		]
		CoreAnalytics.log_event("td_run_complete", {
			"run_id":str(result.get("run_id","")),
			"stage":int(result.get("stage",0)),
			"mastery_xp":int(result.get("mastery_xp",0)),
			"config_version":str(result.get("config_version","v1.49-td-v2-05"))
		})
		TowerDefenseSystem.acknowledge_pending_run_result()
		AudioService.play_sfx("coin")
		HapticsService.success()
	elif bool(result.get("wave_cleared",false)):
		td_result_label.text = "WELLE GESCHAFFT · NÄCHSTE WELLE %d · FORTSCHRITT %d" % [
			TowerDefenseSystem.wave,
			TowerDefenseProgressionSystem.mastery_level
		]
		CoreAnalytics.log_event("td_wave_clear", {
			"wave":TowerDefenseSystem.wave,
			"stage":TowerDefenseProgressionSystem.campaign_stage
		})
		HapticsService.medium()
	elif bool(result.get("ok",false)):
		td_result_label.text = "TREFFER · %d SCHADEN · FEIND · LEBEN %d" % [
			int(result.get("damage",0)),
			TowerDefenseSystem.enemy_hp
		]
		var td_roles := ["archer","mage","cannon","nature"]
		var td_role: String = td_roles[posmod(TowerDefenseProgressionSystem.tower_tech_level - 1, td_roles.size())]
		var tower_anchor := find_child("TowerA",true,false) as Control
		if TowerDefenseSystem.towers >= 2 and posmod(TowerDefenseSystem.wave,2) == 0:
			td_role = td_roles[posmod(TowerDefenseProgressionSystem.tower_tech_level + TowerDefenseSystem.wave - 1, td_roles.size())]
			tower_anchor = find_child("TowerB",true,false) as Control
		TowerDefenseVisualDirectorV192.attack(self,0 if tower_anchor == find_child("TowerA",true,false) else 1,td_role)
		GameplayVfxService.play_projectile(self, tower_anchor if tower_anchor != null else td_fight_button, td_enemy_marker, "td_%s_projectile" % td_role, "td_%s_impact" % td_role, SettingsService.reduced_motion, 0.23)
		TowerDefenseVisualDirectorV192.enemy_hit(self)
		HapticsService.light()
	else:
		td_result_label.text = str(result.get("message","Nicht möglich"))
	core_input_locked=false
	_refresh_all()

func _on_td_tech_pressed_v149() -> void:
	if core_input_locked or _core_modal_open():
		return
	var result:=TowerDefenseProgressionSystem.upgrade_tower_tech()
	if bool(result.get("ok",false)):
		td_result_label.text = "TURM-TECHNIK · STUFE %d · +%d SCHADEN" % [
			int(result.get("level",1)),int(result.get("damage_bonus",0))
		]
		AudioService.play_sfx("coin")
		HapticsService.success()
	else:
		td_result_label.text = str(result.get("message","Upgrade nicht möglich"))
	_refresh_all()

func _claim_td_mastery_p0() -> void:
	if core_input_locked or _core_modal_open():
		return
	var result:=TowerDefenseProgressionSystem.claim_mastery_reward()
	if bool(result.get("ok",false)):
		var reward:Dictionary=result.get("reward",{})
		var bits:Array[String]=[]
		if int(reward.get("gold",0))>0: bits.append("+%d GOLD" % int(reward.get("gold",0)))
		if int(reward.get("spins",0))>0: bits.append("+%d SPINS" % int(reward.get("spins",0)))
		if int(reward.get("realm_keys",0))>0: bits.append("+%d REALM-SCHLÜSSEL" % int(reward.get("realm_keys",0)))
		td_result_label.text = "VERTEIDIGUNGS-FORTSCHRITT · " + " · ".join(bits)
		AudioService.play_sfx("coin")
		HapticsService.success()
	else:
		td_result_label.text = str(result.get("message","Keine Belohnung bereit"))
	_refresh_all()

func _restart_td_run_v149() -> void:
	if core_input_locked or _core_modal_open():
		return
	TowerDefenseSystem.restart_run()
	td_result_label.text = "VERTEIDIGUNG · STUFE %d · %s BEREIT" % [
		TowerDefenseProgressionSystem.campaign_stage,
		TowerDefenseProgressionSystem.stage_label()
	]
	_refresh_all()

func _restore_pending_td_run_v149() -> void:
	if SpinPresentationState.has_pending_result() or DiceJourneySystem.has_pending_result() or PuzzleSystem.has_pending_completion():
		return
	if not TowerDefenseSystem.has_pending_run_result():
		return
	var result:=TowerDefenseSystem.peek_pending_run_result()
	_switch_view(view_tower_defense)
	td_result_label.text = "VERTEIDIGUNG · STUFE %d GESCHAFFT · +%d GOLD · +%d SPIN" % [
		int(result.get("stage",0)),
		int(result.get("gold",0)),
		int(result.get("spins",0))
	]
	TowerDefenseSystem.acknowledge_pending_run_result()
	CoreAnalytics.log_event("td_run_restored",{"run_id":str(result.get("run_id",""))})
	_continue_pending_flow_v154()


func _refresh_puzzle_ui() -> void:
	if not FeatureFlags.SHOW_PUZZLE:
		return
	var glyphs := {"leaf":"🍃","crystal":"◆","coin":"●"}
	for i in range(puzzle_cells.size()):
		var name := PuzzleSystem.symbol_name(int(PuzzleSystem.board[i])) if i < PuzzleSystem.board.size() else "leaf"
		puzzle_cells[i].text = str(glyphs.get(name,"●"))
		puzzle_cells[i].disabled = PuzzleSystem.attempts <= 0 or core_input_locked
		puzzle_cells[i].modulate = Color(1.0,0.93,0.62,1.0) if PuzzleSystem.selected_index == i else Color.WHITE
	var puzzle_target := PuzzleProgressionSystem.target_matches()
	puzzle_status_label.text = "MATCHES · %d / %d · VERSUCHE %d" % [
		PuzzleSystem.matches_completed,
		puzzle_target,
		PuzzleSystem.attempts
	]
	puzzle_stage_label_p0.text = PuzzleProgressionSystem.stage_text()
	puzzle_mastery_label_p0.text = PuzzleProgressionSystem.mastery_text()
	puzzle_mastery_bar_p0.value = PuzzleProgressionSystem.mastery_ratio() * 100.0
	puzzle_mastery_claim_p0.disabled = not PuzzleProgressionSystem.can_claim_mastery_reward() or core_input_locked
	puzzle_mastery_claim_p0.text = "FORTSCHRITTS-BELOHNUNG ABHOLEN" if PuzzleProgressionSystem.can_claim_mastery_reward() else "PUZZLE-FORTSCHRITTS-BELOHNUNG"
	if PuzzleSystem.attempts <= 0:
		puzzle_hint_label.text = "Keine Puzzle-Versuche mehr · weitere Quellen folgen später"
	elif PuzzleSystem.selected_index >= 0:
		puzzle_hint_label.text = "FELD %d GEWÄHLT · jetzt ein benachbartes Feld antippen" % (PuzzleSystem.selected_index + 1)
	else:
		puzzle_hint_label.text = "Zwei benachbarte Felder wählen · bilde einen 3er-Match"

func _on_puzzle_cell_pressed(index: int) -> void:
	if core_input_locked or _core_modal_open():
		return
	var result := PuzzleSystem.tap_cell(index)
	if bool(result.get("match",false)):
		LiveOpsRankingSystem.register_puzzle_match(1)
	if bool(result.get("completed",false)):
		ObjectiveSystem.register_action("puzzle_complete",1)
		puzzle_result_label.text = "PUZZLE GESCHAFFT · +%d GOLD · +%d SPIN" % [int(result.get("gold",0)),int(result.get("spins",0))]
		CoreAnalytics.log_event("puzzle_complete", {
			"completion_id":str(result.get("completion_id","")),
			"stage":int(result.get("stage",0)),
			"matches":int(result.get("matches",0)),
			"config_version":str(result.get("config_version","v1.48-puzzle-v2-04"))
		})
		PuzzleSystem.acknowledge_pending_completion()
		AudioService.play_sfx("coin")
		HapticsService.success()
	elif bool(result.get("match",false)):
		puzzle_result_label.text = "3ER-MATCH · %d / %d · FORTSCHRITT %d" % [PuzzleSystem.matches_completed,PuzzleProgressionSystem.target_matches(),PuzzleProgressionSystem.mastery_level]
		CoreAnalytics.log_event("puzzle_match", {"matches":PuzzleSystem.matches_completed})
		HapticsService.medium()
	elif not bool(result.get("ok",false)):
		puzzle_result_label.text = str(result.get("message","Kein Match"))
		HapticsService.light()
	ModeGameplayPolishV196.puzzle_feedback(self, index, bool(result.get("match",false)), bool(result.get("completed",false)), SettingsService.reduced_motion)
	_refresh_all()

func _claim_puzzle_mastery_p0() -> void:
	if core_input_locked or _core_modal_open():
		return
	var result := PuzzleProgressionSystem.claim_mastery_reward()
	if bool(result.get("ok",false)):
		var reward: Dictionary = result.get("reward",{})
		var bits: Array[String] = []
		if int(reward.get("gold",0))>0: bits.append("+%d GOLD" % int(reward.get("gold",0)))
		if int(reward.get("spins",0))>0: bits.append("+%d SPINS" % int(reward.get("spins",0)))
		if int(reward.get("realm_keys",0))>0: bits.append("+%d REALM-SCHLÜSSEL" % int(reward.get("realm_keys",0)))
		puzzle_result_label.text = "PUZZLE-FORTSCHRITT · " + " · ".join(bits)
		AudioService.play_sfx("coin")
		HapticsService.success()
	else:
		puzzle_result_label.text = str(result.get("message","Keine Belohnung bereit"))
	_refresh_all()

func _restore_pending_puzzle_completion_v148() -> void:
	if SpinPresentationState.has_pending_result() or DiceJourneySystem.has_pending_result():
		return
	if not PuzzleSystem.has_pending_completion():
		return
	var result:=PuzzleSystem.peek_pending_completion()
	_switch_view(view_puzzle)
	puzzle_result_label.text = "PUZZLE STUFE %d GESCHAFFT · +%d GOLD · +%d SPINS" % [
		int(result.get("stage",0)),
		int(result.get("gold",0)),
		int(result.get("spins",0))
	]
	PuzzleSystem.acknowledge_pending_completion()
	CoreAnalytics.log_event("puzzle_completion_restored",{
		"completion_id":str(result.get("completion_id",""))
	})
	_continue_pending_flow_v154()

func _refresh_meta_ui() -> void:
	if not (FeatureFlags.SHOW_EVENTS or FeatureFlags.SHOW_RANKINGS or FeatureFlags.SHOW_REALM_CHEST):
		return
	event_progress_label.text = "BOSSE · %d / %d" % [MetaProgressSystem.event_boss_progress,MetaProgressSystem.event_target()]
	if MetaProgressSystem.event_claimed:
		event_claim_button.text = "EVENT ABGESCHLOSSEN"
		event_claim_button.disabled = true
	else:
		event_claim_button.text = "EVENT-BELOHNUNG"
		event_claim_button.disabled = not MetaProgressSystem.can_claim_event() or core_input_locked
	var lines: Array[String] = []
	for row in MetaProgressSystem.ranking_rows():
		lines.append("%d. %s · %d" % [int(row.get("rank",0)),str(row.get("name","")),int(row.get("score",0))])
	ranking_rows_label.text = "\n".join(lines) if not lines.is_empty() else "ONLINE-RANGLISTE · NOCH NICHT VERBUNDEN\nKeine simulierten Spieler."
	realm_chest_status.text = "SCHLÜSSEL · %d / %d · TRUHEN %d" % [
		MetaProgressSystem.realm_keys,
		MetaProgressSystem.required_keys(),
		MetaProgressSystem.realm_chests_opened
	]
	realm_chest_button.disabled = not MetaProgressSystem.can_open_chest() or core_input_locked
	ScreenUiAssemblyService.refresh_reward_session_state(
		self,
		MetaProgressSystem.can_claim_event(),
		MetaProgressSystem.event_claimed,
		MetaProgressSystem.can_open_chest(),
		meta_result_label.text
	)

func _on_event_claim_pressed() -> void:
	if core_input_locked or _core_modal_open():
		return
	core_input_locked = true
	var result := MetaProgressSystem.claim_event()
	if bool(result.get("ok",false)):
		meta_result_label.text = "EVENT · +%d GOLD · +%d SPINS" % [int(result.get("gold",0)),int(result.get("spins",0))]
		CoreAnalytics.log_event("event_reward_claimed", {"event_id":"greenvale_hunt"})
		AudioService.play_sfx("coin")
		HapticsService.success()
	else:
		meta_result_label.text = str(result.get("message","Noch nicht bereit"))
	core_input_locked = false
	_refresh_all()

func _on_realm_chest_pressed() -> void:
	if core_input_locked or _core_modal_open():
		return
	core_input_locked = true
	var result := MetaProgressSystem.open_realm_chest()
	if bool(result.get("ok",false)):
		meta_result_label.text = "REALM-TRUHE · +%d GOLD · +%d SPINS" % [int(result.get("gold",0)),int(result.get("spins",0))]
		CoreAnalytics.log_event("realm_chest_open", {"opened":int(result.get("opened",0))})
		AudioService.play_sfx("coin")
		HapticsService.success()
	else:
		meta_result_label.text = str(result.get("message","Truhe nicht bereit"))
	core_input_locked = false
	_refresh_all()

func _refresh_journey_ui() -> void:
	if not FeatureFlags.SHOW_REALM_JOURNEY:
		return
	var nodes := DiceJourneySystem.board_nodes()
	var current := DiceJourneySystem.position
	journey_progress_label.text = "FELD %d / %d · RUNDE %d" % [current + 1, nodes, DiceJourneySystem.laps_completed]
	var marks: Array[String] = []
	for i in range(nodes):
		marks.append("●" if i == current else "○")
	journey_nodes_label.text = " ".join(marks)
	journey_dice_label.text = "WÜRFEL · %d / %d" % [DiceJourneySystem.dice, DiceJourneySystem.max_dice()]
	journey_node_detail_p0.text = JourneyProgressionSystem.current_node_text()
	journey_mastery_label.text = JourneyProgressionSystem.mastery_text()
	journey_mastery_bar_p0.value = JourneyProgressionSystem.progress_ratio() * 100.0
	journey_mastery_claim_p0.disabled = not JourneyProgressionSystem.can_claim_mastery_reward() or core_input_locked
	journey_mastery_claim_p0.text = "FORTSCHRITTS-BELOHNUNG ABHOLEN" if JourneyProgressionSystem.can_claim_mastery_reward() else "FORTSCHRITTS-BELOHNUNG"
	journey_cache_p0.text = JourneyProgressionSystem.cache_text()
	journey_cache_p0.disabled = not JourneyProgressionSystem.can_open_cache() or core_input_locked
	dice_roll_button.disabled = DiceJourneySystem.dice <= 0 or core_input_locked
	dice_roll_button.text = "KEINE WÜRFEL" if DiceJourneySystem.dice <= 0 else "WÜRFELN"
	var charges := DiceJourneySystem.portal_charges
	treasure_portal_status.text = "PORTAL BEREIT · %d LADUNG" % charges if charges > 0 else "Schließe eine Runde ab"
	treasure_portal_button.disabled = charges <= 0 or core_input_locked

func _open_journey_p0() -> void:
	if core_input_locked or _core_modal_open():
		return
	_switch_view(view_journey)
	CoreAnalytics.log_event("journey_open")
	if DiceJourneySystem.has_pending_result():
		_restore_pending_journey_presentation()
	else:
		_refresh_journey_ui()

func _on_dice_roll_pressed() -> void:
	if core_input_locked or _core_modal_open():
		return
	core_input_locked = true
	dice_roll_button.disabled = true
	var result := DiceJourneySystem.roll()
	if not bool(result.get("ok",false)):
		dice_result_label.text = str(result.get("message","Nicht möglich"))
		core_input_locked = false
		_refresh_journey_ui()
		return
	var roll := int(result.get("roll",0))
	var reward: Dictionary = result.get("reward",{})
	var reward_text := ""
	match str(reward.get("type","")):
		"gold": reward_text = " · +%d GOLD" % int(reward.get("amount",0))
		"spin": reward_text = " · +%d SPIN" % int(reward.get("amount",0))
	dice_result_label.text = "WÜRFEL · %d → FELD %d%s" % [roll,int(result.get("node",1)),reward_text]
	dice_result_label.text += " · FORTSCHRITT %d" % JourneyProgressionSystem.mastery_level
	if bool(result.get("crossed_lap",false)):
		dice_result_label.text += " · PORTAL GELADEN"
		if FeatureFlags.SHOW_REALM_CHEST:
			MetaProgressSystem.register_journey_lap()
		LiveOpsRankingSystem.register_journey_lap()
		ObjectiveSystem.register_action("journey_lap",1)
	CoreAnalytics.log_event("dice_result", {
		"roll_id":str(result.get("roll_id","")),
		"roll_seed":int(result.get("roll_seed",0)),
		"config_version":str(result.get("config_version",DiceJourneySystem.CONFIG_VERSION)),
		"roll":roll,
		"node":int(result.get("node",1)),
		"crossed_lap":bool(result.get("crossed_lap",false)),
		"reward_id":str(reward.get("reward_id","")),
		"reward_type":str(reward.get("type","")),
		"reward_value":int(reward.get("amount",0))
	})
	if not SettingsService.reduced_motion:
		var tween := create_tween()
		journey_nodes_label.scale = Vector2(0.96,0.96)
		tween.tween_property(journey_nodes_label,"scale",Vector2.ONE,0.16).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		await tween.finished
	HapticsService.medium()
	DiceJourneySystem.acknowledge_pending_result()
	core_input_locked = false
	_refresh_all()

func _claim_journey_mastery_p0() -> void:
	if core_input_locked or _core_modal_open():
		return
	var result := JourneyProgressionSystem.claim_mastery_reward()
	if bool(result.get("ok",false)):
		var reward: Dictionary = result.get("reward",{})
		var bits: Array[String] = []
		if int(reward.get("dice",0)) > 0: bits.append("+%d WÜRFEL" % int(reward.get("dice",0)))
		if int(reward.get("gold",0)) > 0: bits.append("+%d GOLD" % int(reward.get("gold",0)))
		if int(reward.get("spins",0)) > 0: bits.append("+%d SPINS" % int(reward.get("spins",0)))
		if int(reward.get("realm_keys",0)) > 0: bits.append("+%d REALM-SCHLÜSSEL" % int(reward.get("realm_keys",0)))
		dice_result_label.text = "REISE-FORTSCHRITT · " + " · ".join(bits)
		AudioService.play_sfx("coin")
		HapticsService.success()
	else:
		dice_result_label.text = str(result.get("message","Keine Belohnung bereit"))
	_refresh_all()

func _open_journey_cache_p0() -> void:
	if core_input_locked or _core_modal_open():
		return
	var result := JourneyProgressionSystem.open_cache()
	if bool(result.get("ok",false)):
		dice_result_label.text = "REISE-BONUS · +%d GOLD · +%d SPIN" % [int(result.get("gold",0)),int(result.get("spins",0))]
		AudioService.play_sfx("coin")
		HapticsService.success()
	else:
		dice_result_label.text = str(result.get("message","Cache nicht bereit"))
	_refresh_all()

func _on_treasure_portal_pressed() -> void:
	if core_input_locked or _core_modal_open():
		return
	core_input_locked = true
	var result := DiceJourneySystem.open_treasure_portal()
	if not bool(result.get("ok",false)):
		dice_result_label.text = str(result.get("message","Portal nicht bereit"))
		core_input_locked = false
		_refresh_journey_ui()
		return
	var gold := int(result.get("gold",0))
	var spins := int(result.get("spins",0))
	dice_result_label.text = "SCHATZPORTAL · +%d GOLD · +%d SPIN" % [gold,spins]
	CoreAnalytics.log_event("treasure_portal_open", {"gold":gold,"spins":spins})
	AudioService.play_sfx("coin")
	HapticsService.success()
	core_input_locked = false
	_refresh_all()

func _restore_pending_journey_presentation() -> void:
	if SpinPresentationState.has_pending_result() or not DiceJourneySystem.has_pending_result():
		return
	var result := DiceJourneySystem.peek_pending_result()
	var reward: Dictionary = result.get("reward",{})
	var reward_text := ""
	match str(reward.get("type","")):
		"gold": reward_text = " · +%d GOLD" % int(reward.get("amount",0))
		"spin": reward_text = " · +%d SPIN" % int(reward.get("amount",0))
	_switch_view(view_journey)
	dice_result_label.text = "WIEDERHERGESTELLT · WÜRFEL %d → FELD %d%s" % [
		int(result.get("roll",0)),
		int(result.get("node",1)),
		reward_text
	]
	CoreAnalytics.log_event("journey_presentation_resumed", {
		"roll_id":str(result.get("roll_id","")),
		"roll_seed":int(result.get("roll_seed",0)),
		"config_version":str(result.get("config_version",DiceJourneySystem.CONFIG_VERSION))
	})
	DiceJourneySystem.acknowledge_pending_result()
	_refresh_journey_ui()
	_continue_pending_flow_v154()

func _monster_title_text_p0(level: int) -> String:
	var boss := P0MonsterVisualSystem.is_boss(level)
	return "%s · STUFE %d · %s · %s" % [
		"BOSS" if boss else "MONSTER",
		level,
		P0MonsterVisualSystem.display_name(level),
		EncounterFeelSystem.encounter_tag(level)
	]

func _update_monster_ui() -> void:
	var boss := P0MonsterVisualSystem.is_boss(PlayerData.monster_level)
	var prefix := "BOSS" if boss else "MONSTER"
	monster_level_label.text = _monster_title_text_p0(PlayerData.monster_level)
	_apply_monster_hp_art_v158()
	monster_hp.max_value = PlayerData.monster_max_hp
	monster_hp_label.text = "LEBEN %d / %d" % [PlayerData.current_monster_hp, PlayerData.monster_max_hp]
	var until_boss := 10 - (PlayerData.monster_level % 10)
	if boss:
		boss_proximity_p0.text = "BOSS · %s" % P0MonsterVisualSystem.display_name(PlayerData.monster_level).to_upper()
	elif until_boss <= 3:
		boss_proximity_p0.text = "BOSS IN %d" % until_boss
	else:
		boss_proximity_p0.text = ""

	ScreenUiAssemblyService.refresh_home_loop_state(
		self,
		boss,
		until_boss,
		PlayerData.current_monster_hp,
		PlayerData.monster_max_hp
	)

	if hp_tween and hp_tween.is_valid():
		hp_tween.kill()
	if SettingsService.reduced_motion:
		monster_hp.value = PlayerData.current_monster_hp
		return

	hp_tween = create_tween()
	hp_tween.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	hp_tween.tween_property(monster_hp, "value", float(PlayerData.current_monster_hp), 0.11)

func _update_monster_visual() -> void:
	if monster_state_locked:
		return
	var texture := P0MonsterVisualSystem.texture_for(PlayerData.monster_level,"idle")
	if texture:
		monster_button.texture_normal = texture
	monster_level_label.text = _monster_title_text_p0(PlayerData.monster_level)
	boss_shield_fx_p0.visible = false
	if P0MonsterVisualSystem.is_boss(PlayerData.monster_level):
		monster_button.scale = Vector2(1.08,1.08)
	else:
		monster_button.scale = Vector2.ONE

func _update_village_ui() -> void:
	building_select_glow.visible = view_dorf.visible
	var cost := GameConfig.village_upgrade_cost(PlayerData.village_level)
	var town_asset := "townhall_lv1"
	if PlayerData.village_level >= 5:
		town_asset = "townhall_lv3"
	elif PlayerData.village_level >= 3:
		town_asset = "townhall_lv2"
	var town_texture := AssetRegistry.texture_for(town_asset)
	if town_texture:
		town_hall_art.texture = town_texture
	town_hall_button.text = "RATHAUS · STUFE %d\nVerbessern · %s Gold" % [
		PlayerData.village_level,
		_compact_number(cost)
	]
	var mine_open := PlayerData.village_level >= 3
	var forge_open := PlayerData.village_level >= 5
	gold_mine_art.modulate = Color.WHITE if mine_open else Color(0.45,0.45,0.48,0.75)
	forge_art.modulate = Color.WHITE if forge_open else Color(0.45,0.45,0.48,0.75)
	gold_mine_label.text = "GOLDMINE · BEREIT" if mine_open else "GOLDMINE · Ab Dorf-Lv. 3"
	forge_label.text = "SCHMIEDE · BEREIT" if forge_open else "SCHMIEDE · Ab Dorf-Lv. 5"

func _update_tap_upgrade_ui() -> void:
	var cost := GameConfig.tap_upgrade_cost(PlayerData.tap_level)
	var effective_damage := CombatMomentumSystem.effective_tap_damage(PlayerData.tap_damage)
	var realm_bonus := int(round(CoreProgressionSynergySystem.tap_bonus_ratio() * 100.0))
	var flow_suffix := " · EFFEKTIV %d" % effective_damage if effective_damage != PlayerData.tap_damage else ""
	var realm_suffix := " · REALM +%d%%" % realm_bonus if realm_bonus > 0 else ""
	tap_upgrade_button.text = "TAP-SCHADEN %d%s%s\nVerbessern +%d · %s Gold" % [
		PlayerData.tap_damage,
		realm_suffix,
		flow_suffix,
		GameConfig.TAP_DAMAGE_GAIN,
		_compact_number(cost)
	]

func _switch_view(target_view: Control) -> void:
	for v in [view_tap, view_rad, view_dorf, view_journey, view_meta, view_puzzle, view_tower_defense, view_heroes, view_attack, view_defense, view_daily, view_quests]:
		v.visible = false
	target_view.visible = true
	btn_tap.disabled = target_view == view_tap
	btn_rad.disabled = target_view == view_rad
	btn_dorf.disabled = target_view == view_dorf
	btn_heroes.disabled = target_view == view_heroes
	btn_attack.disabled = target_view == view_attack
	btn_defense.disabled = target_view == view_defense
	if target_view == view_dorf:
		_refresh_p0_village()
	ScreenUiAssemblyService.set_primary_nav_state(self, target_view)

func _on_monster_pressed() -> void:
	if core_input_locked or _core_modal_open() or monster_state_locked:
		return

	var encounter_id := P0MonsterVisualSystem.production_asset_id(PlayerData.monster_level)
	CoreAnalytics.log_event("first_tap", {"encounter_id":encounter_id})
	_acknowledge_first_tap_hint()
	AudioService.play_sfx("tap")
	HapticsService.light()
	CombatMomentumSystem.register_tap()
	var damage := CombatMomentumSystem.effective_tap_damage(PlayerData.tap_damage)
	var killed := PlayerData.damage_monster(damage)
	if FeatureFlags.SHOW_QUESTS:
		QuestSystem.add_progress("tap_10", 1)
	_show_hit_overlay()
	TapCombatVisualDirectorV193.hit(self, monster_button, damage, PlayerData.tap_damage, SettingsService.reduced_motion)
	_show_damage(damage)
	_punch_monster()
	_show_monster_state("hit",0.12)

	if killed:
		monster_state_locked = true
		core_input_locked = true
		var result := MonsterDefeatService.commit_defeat("tap")
		if not bool(result.get("ok",false)):
			monster_state_locked = false
			core_input_locked = false
			return
		if bool(result.get("pending",false)):
			reward_label.text = "KAMPFERGEBNIS WIRD BESTÄTIGT …"
			return
		await _present_monster_defeat_v143(result)

func _on_monster_defeat_committed_v143(result: Dictionary) -> void:
	HeroProgressionSystem.register_monster_defeat(result)
	ObjectiveSystem.register_action("monster_defeat",1,{"encounter_id":str(result.get("encounter_id",P0MonsterVisualSystem.production_asset_id(int(result.get("defeated_level",1)))))})
	if bool(result.get("boss",false)):
		ObjectiveSystem.register_action("boss_defeat",1)
		var village_link := VillageProgressionSystem.grant_external_xp(
			"boss_defeat",
			CoreProgressionSynergySystem.boss_village_xp()
		)
		result["village_progression"] = village_link
	# Tap presents synchronously after commit; the signal path is for Auto-DPS
	# and future damage sources so presentation cannot double-run.
	if str(result.get("source","")) == "tap" and not bool(result.get("remote",false)):
		return
	if not view_tap.visible:
		_refresh_all()
		return
	monster_state_locked = true
	core_input_locked = true
	call_deferred("_present_auto_defeat_v143",result.duplicate(true))

func _present_auto_defeat_v143(result: Dictionary) -> void:
	await _present_monster_defeat_v143(result)

func _present_monster_defeat_v143(result: Dictionary) -> void:
	var defeated_level := int(result.get("defeated_level",1))
	var boss_defeated := bool(result.get("boss",false))
	var reward_gold := int(result.get("reward_gold",0))
	var source := str(result.get("source","unknown"))

	if boss_defeated:
		boss_cycle_count += 1
		CoreAnalytics.log_event("boss_defeat", {
			"defeat_id":str(result.get("defeat_id","")),
			"source":source,
			"monster_level":defeated_level,
			"cycle":boss_cycle_count
		})
		AudioService.play_sfx("boss_defeat")
		HapticsService.success()

	_try_kill_milestone_p0(defeated_level)
	await _show_monster_defeat_state_for_level(defeated_level,boss_defeated)
	TapCombatVisualDirectorV193.defeat(self, monster_button, boss_defeated, SettingsService.reduced_motion)
	_show_reward_pulse()

	if boss_defeated:
		_show_boss_defeat(reward_gold)
	else:
		_show_monster_reward(reward_gold)

	CoreAnalytics.log_event("monster_defeat_presented", {
		"defeat_id":str(result.get("defeat_id","")),
		"source":source,
		"boss":boss_defeated
	})

func _show_damage(amount: int) -> void:
	if not SettingsService.damage_numbers_enabled:
		return
	if damage_tween and damage_tween.is_valid():
		damage_tween.kill()

	damage_label.text = "-%d" % amount
	damage_label.modulate.a = 1.0
	var near_finish := PlayerData.current_monster_hp > 0 and PlayerData.current_monster_hp <= maxi(amount * 2, 1)
	damage_label.scale = Vector2(1.12,1.12) if near_finish and not SettingsService.reduced_motion else Vector2.ONE
	damage_feedback_index_p0 = (damage_feedback_index_p0 + 1) % 4
	var x_offsets := [-28.0, 18.0, -10.0, 30.0]
	var y_offsets := [0.0, -8.0, 6.0, -4.0]
	damage_label.position = Vector2(445.0 + x_offsets[damage_feedback_index_p0], 535.0 + y_offsets[damage_feedback_index_p0])
	damage_label.pivot_offset = damage_label.size * 0.5

	if SettingsService.reduced_motion:
		damage_tween = create_tween()
		damage_tween.tween_interval(0.18)
		damage_tween.tween_property(damage_label,"modulate:a",0.0,0.12)
		return

	damage_label.scale = Vector2(0.82,0.82)
	damage_tween = create_tween().set_parallel(true)
	damage_tween.tween_property(damage_label,"position:y",damage_label.position.y - 105.0,0.32)
	damage_tween.tween_property(damage_label,"modulate:a",0.0,0.32)
	damage_tween.tween_property(damage_label,"scale",Vector2(1.08,1.08),0.13)

func _punch_monster() -> void:
	var base_scale := Vector2(1.08,1.08) if P0MonsterVisualSystem.is_boss(PlayerData.monster_level) else Vector2.ONE
	if SettingsService.reduced_motion:
		monster_button.scale = base_scale
		monster_button.rotation = 0.0
		return

	monster_reaction_active = true
	monster_button.pivot_offset = monster_button.size * 0.5
	var direction := -1.0 if randf() < 0.5 else 1.0

	var hit := create_tween().set_parallel(true)
	hit.set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	var role_scale := EncounterFeelSystem.hit_punch_scale(PlayerData.monster_level)
	var squash_x := role_scale.x
	var squash_y := maxf(role_scale.y - 0.04, 0.86)
	hit.tween_property(monster_button,"scale",Vector2(base_scale.x * squash_x, base_scale.y * squash_y),0.045)
	hit.tween_property(monster_button,"rotation",deg_to_rad(2.4 * direction),0.045)
	await hit.finished

	var recover := create_tween().set_parallel(true)
	recover.set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	recover.tween_property(monster_button,"scale",base_scale,0.09)
	recover.tween_property(monster_button,"rotation",0.0,0.09)
	await recover.finished
	monster_reaction_active = false

func _load_spin_symbol_textures() -> void:
	spin_symbol_textures.clear()
	var production_roles := [
		"spin.symbol.gold",
		"spin.symbol.crystals",
		"spin.symbol.xp",
		"spin.symbol.energy",
		"spin.symbol.chest",
		"spin.symbol.materials",
		"spin.symbol.token",
		"spin.symbol.rare"
	]
	for role_id in production_roles:
		var production_tex := AssetRegistry.production_texture_for(role_id, true)
		if production_tex != null:
			spin_symbol_textures.append(production_tex)
	if spin_symbol_textures.size() == production_roles.size():
		return
	spin_symbol_textures.clear()
	for path in SPIN_SYMBOL_PATHS:
		var tex := load(path) as Texture2D
		if tex != null:
			spin_symbol_textures.append(tex)

func _refresh_reel_symbols(stops: Array) -> void:
	spin_reel_presenter.show_stops(stops)

func _randomize_reel_symbols() -> void:
	spin_reel_presenter.randomize_symbols()

func _on_spin_pressed() -> void:
	if wheel_spinning or core_input_locked or wheel_reward_overlay_p0.visible:
		return

	wheel_spinning = true
	core_input_locked = true
	spin_button.disabled = true

	var result := WheelSystem.spin()
	if not bool(result.get("ok", false)):
		wheel_result.text = str(result.get("message", ""))
		CoreAnalytics.log_event("spin_empty", {"spins": PlayerData.spins, "presentation":"three_reel_machine", "config_version":WheelSystem.CONFIG_VERSION})
		wheel_spinning = false
		core_input_locked = false
		spin_button.disabled = PlayerData.spins <= 0
		if PlayerData.spins <= 0:
			_show_no_spins_state()
		return

	if bool(result.get("pending",false)):
		wheel_result.text = "SPIN WIRD BESTÄTIGT …"
		spin_status_label.text = "ONLINE · ERGEBNIS WIRD BESTÄTIGT"
		win_line_label.text = "GEWINNLINIE · WARTE AUF SERVER"
		return

	CoreAnalytics.log_event("spin_request", {"spins_after_cost": PlayerData.spins, "presentation": "three_reel_machine", "config_version":WheelSystem.CONFIG_VERSION})
	LiveOpsRankingSystem.register_spin()
	ObjectiveSystem.register_action("spin",1)
	if FeatureFlags.SHOW_QUESTS:
		QuestSystem.add_progress("spin_3", 1)
	CoreAnalytics.log_event("spin_result", {
		"result_id":str(result.get("result_id","")),
		"reward_id":str(result.get("reward_id","")),
		"reward_type":str(result.get("reward_type","")),
		"reward_value":int(result.get("reward_value",0)),
		"segment_id":str(result.get("segment_id","")),
		"reel_stops":result.get("reel_stops",[]),
		"reel_stop_ids":result.get("reel_stop_ids",[]),
		"visual_seed":int(result.get("visual_seed",0)),
		"payline_match":bool(result.get("payline_match",false)),
		"authority_request_id":str(result.get("authority_request_id","")),
		"authority_revision":int(result.get("authority_revision",0)),
		"config_version":str(result.get("config_version",WheelSystem.CONFIG_VERSION))
	})
	AudioService.play_sfx("wheel_spin")
	HapticsService.light()
	wheel_result.text = "WALZEN LAUFEN ..."
	spin_status_label.text = "SPIN LÄUFT · WALZEN STOPPEN NACHEINANDER"
	win_line_label.text = "GEWINNLINIE · BEREIT"
	SpinVillageResponsivePolishV194.spin_begin(self, SettingsService.reduced_motion)
	GameplayVfxService.play_overlay(self, reel_2, "spin_motion", SettingsService.reduced_motion, 1.35, 0.55)
	var stops: Array = result.get("reel_stops", [0,0,0])
	await spin_reel_presenter.play_to(stops, SettingsService.reduced_motion, int(result.get("visual_seed",1)))
	HapticsService.medium()
	wheel_result.text = str(result.get("message", ""))
	GameplayVfxService.play_overlay(self, payline, "spin_win", SettingsService.reduced_motion, 1.22, 0.34)
	SpinVillageResponsivePolishV194.spin_result(self, str(result.get("type","")) == "special", SettingsService.reduced_motion)
	if str(result.get("type","")) == "special":
		GameplayVfxService.play_overlay(self, reel_2, "spin_jackpot", SettingsService.reduced_motion, 1.65, 0.58)
		await _show_jackpot_feedback()
	_show_wheel_reward(result)
	wheel_spinning = false
	_refresh_spin_ui()
	spin_button.disabled = PlayerData.spins <= 0

func _on_remote_spin_result_v181(result: Dictionary) -> void:
	if not bool(result.get("ok",false)):
		wheel_result.text = "SPIN konnte nicht bestätigt werden"
		wheel_spinning = false
		core_input_locked = false
		_refresh_spin_ui()
		return
	CoreAnalytics.log_event("spin_remote_confirmed", {
		"result_id":str(result.get("result_id","")),
		"authority_request_id":str(result.get("authority_request_id","")),
		"authority_revision":int(result.get("authority_revision",0))
	})
	LiveOpsRankingSystem.register_spin()
	ObjectiveSystem.register_action("spin",1)
	if FeatureFlags.SHOW_QUESTS:
		QuestSystem.add_progress("spin_3",1)
	AudioService.play_sfx("wheel_spin")
	HapticsService.light()
	wheel_result.text = "WALZEN LAUFEN ..."
	spin_status_label.text = "ONLINE BESTÄTIGT · WALZEN LAUFEN"
	win_line_label.text = "GEWINNLINIE · BEREIT"
	GameplayVfxService.play_overlay(self, reel_2, "spin_motion", SettingsService.reduced_motion, 1.35, 0.55)
	var stops: Array = result.get("reel_stops",[0,0,0])
	await spin_reel_presenter.play_to(stops,SettingsService.reduced_motion,int(result.get("visual_seed",1)))
	HapticsService.medium()
	wheel_result.text = str(result.get("message",""))
	GameplayVfxService.play_overlay(self, payline, "spin_win", SettingsService.reduced_motion, 1.22, 0.34)
	if str(result.get("type","")) == "special":
		GameplayVfxService.play_overlay(self, reel_2, "spin_jackpot", SettingsService.reduced_motion, 1.65, 0.58)
		await _show_jackpot_feedback()
	_show_wheel_reward(result)
	wheel_spinning = false
	core_input_locked = false
	_refresh_spin_ui()
	spin_button.disabled = PlayerData.spins <= 0

func _on_spin_reel_stopped(index: int) -> void:
	SpinVillageResponsivePolishV194.spin_stop(self, index, SettingsService.reduced_motion)
	var reel_anchor: Control = reel_1 if index == 0 else (reel_2 if index == 1 else reel_3)
	GameplayVfxService.play_overlay(self, reel_anchor, "spin_stop", SettingsService.reduced_motion, 0.86, 0.22)
	AudioService.play_sfx("wheel_stop")
	HapticsService.light()
	if index == 2:
		HapticsService.medium()

func _restore_pending_spin_presentation() -> void:
	if not SpinPresentationState.has_pending_result():
		return
	var result := SpinPresentationState.peek_pending_result()
	var stops: Array = result.get("reel_stops", [0,0,0])
	_switch_view(view_rad)
	spin_reel_presenter.show_stops(stops)
	wheel_result.text = str(result.get("message","Belohnung"))
	spin_status_label.text = "LETZTER SPIN WIEDERHERGESTELLT"
	win_line_label.text = "GEWINNLINIE · REWARD BESTÄTIGT"
	CoreAnalytics.log_event("spin_presentation_resumed", {
				"result_id":str(result.get("result_id","")),
		"reward_id":str(result.get("reward_id","")),
		"segment_id":str(result.get("segment_id","")),
		"reel_stop_ids":result.get("reel_stop_ids",[]),
		"config_version":str(result.get("config_version",WheelSystem.CONFIG_VERSION))
	})
	_show_wheel_reward(result)

func _pulse_payline(strong: bool = false) -> void:
	if SettingsService.reduced_motion:
		return
	payline.modulate = Color(1.0,1.0,1.0,1.0)
	var tween := create_tween()
	var target := Color(1.0,0.88,0.45,1.0) if strong else Color(1.0,0.95,0.72,1.0)
	tween.tween_property(payline,"modulate",target,0.07)
	tween.tween_property(payline,"modulate",Color.WHITE,0.11)

func _show_no_spins_state() -> void:
	if wheel_spinning:
		return
	core_input_locked = true
	no_spins_text.text = "Keine Spins verfügbar. Kehre zu HOME zurück, besiege Gegner oder Bosse und sammle neue Spins."
	no_spins_panel.visible = true
	no_spins_panel.modulate.a = 1.0 if SettingsService.reduced_motion else 0.0
	if not SettingsService.reduced_motion:
		var tween := create_tween()
		tween.tween_property(no_spins_panel,"modulate:a",1.0,0.14)
	HapticsService.light()

func _close_no_spins_state() -> void:
	no_spins_panel.visible = false
	core_input_locked = false
	win_line_label.text = "GEWINNLINIE · MITTLERE REIHE"
	_refresh_all()

func _show_jackpot_feedback() -> void:
	jackpot_flash.visible = true
	if SettingsService.reduced_motion:
		jackpot_flash.color.a = 0.12
		await get_tree().create_timer(0.10).timeout
		jackpot_flash.visible = false
		return
	jackpot_flash.color.a = 0.0
	var tween := create_tween()
	tween.tween_property(jackpot_flash,"color:a",0.24,0.08)
	tween.tween_property(jackpot_flash,"color:a",0.0,0.20)
	await tween.finished
	jackpot_flash.visible = false
	HapticsService.success()

func _try_daily_reward() -> void:
	if DailyRewards.can_claim():
		var reward := DailyRewards.claim()
		if not reward.is_empty():
			var parts: Array[String] = []
			if reward.has("gold"): parts.append("+%d Gold" % int(reward.gold))
			if reward.has("spins"): parts.append("+%d Spins" % int(reward.spins))
			if reward.has("gems"): parts.append("+%d Gems" % int(reward.gems))
			reward_label.text = "Daily: " + " · ".join(parts)

func _on_town_hall_pressed() -> void:
	if not PlayerData.upgrade_village():
		print("Nicht genug Gold.")
		return
	CoreAnalytics.log_event("building_upgrade",{"building_id":selected_building_id,"level":P0VillageSystem.get_level(selected_building_id)})
	AudioService.play_sfx("upgrade")
	HapticsService.success()
	reward_label.text = "Dorf auf Lv. %d verbessert!" % PlayerData.village_level
	if PlayerData.village_level == 3:
		reward_label.text += " · Goldmine freigeschaltet!"
	elif PlayerData.village_level == 5:
		reward_label.text += " · Schmiede freigeschaltet!"
	_show_reward_burst()
	if FeatureFlags.SHOW_QUESTS:
		QuestSystem.add_progress("upgrade_1", 1)
		ObjectiveSystem.register_action("village_upgrade",1)
	SaveGame.save_game()

func _on_tap_upgrade_pressed() -> void:
	if not PlayerData.increase_tap_damage():
		print("Nicht genug Gold.")
		return
	reward_label.text = "Tap-Schaden: %d" % PlayerData.tap_damage
	if FeatureFlags.SHOW_QUESTS:
		QuestSystem.add_progress("upgrade_1", 1) # tap_upgrade_quest_marker
	SaveGame.save_game()

func _compact_number(value: int) -> String:
	if value >= 1_000_000:
		return "%.1fM" % (value / 1_000_000.0)
	if value >= 1_000:
		return "%.1fK" % (value / 1_000.0)
	return str(value)


func _refresh_core_synergy_v174() -> void:
	var label := find_child("CoreSynergyLabelV174", true, false) as Label
	if label:
		label.text = CoreProgressionSynergySystem.summary_text()
		label.visible = CoreProgressionSynergySystem.tap_bonus_ratio() > 0.0
	_update_tap_upgrade_ui()

func _on_combat_momentum_changed_v172(tier: int, multiplier: float) -> void:
	var label := find_child("TapMomentumLabelV172", true, false) as Label
	if label == null:
		return
	if tier <= 1:
		label.text = ""
		label.visible = false
		return
	label.visible = true
	var bonus_percent := int(round((multiplier - 1.0) * 100.0))
	label.text = "ANGRIFFSFLUSS · x%d · +%d%% TAP" % [tier, bonus_percent]
	if not SettingsService.reduced_motion:
		label.scale = Vector2(1.06,1.06)
		var tween := create_tween()
		tween.tween_property(label, "scale", Vector2.ONE, 0.10)
	_update_tap_upgrade_ui()
func _show_hero_assist_feedback_v172(amount: int) -> void:
	var label := find_child("HeroAssistLabelV172", true, false) as Label
	if label == null:
		return
	var hero_id := HeroSystem.get_selected_hero_id()
	var card := HeroSystem.get_card_data(hero_id)
	var hero_name := str(card.get("name", hero_id)).to_upper()
	var role_label := EncounterFeelSystem.hero_role_label(hero_id)
	label.text = "%s · %s · AUTO +%d" % [hero_name, role_label, amount]
	label.modulate.a = 0.82
	label.scale = Vector2.ONE * EncounterFeelSystem.hero_assist_scale(hero_id)
	if SettingsService.reduced_motion:
		return
	var tween := create_tween()
	tween.tween_property(label, "scale", Vector2.ONE, 0.10)
	tween.parallel().tween_property(label, "modulate:a", 0.0, 0.42).set_delay(0.12)

func _reset_combat_flow_v172() -> void:
	CombatMomentumSystem.reset()
	var assist := find_child("HeroAssistLabelV172", true, false) as Label
	if assist:
		assist.modulate.a = 0.0

func _update_hero_ui() -> void:
	var active_hero_id := HeroSystem.get_selected_hero_id()
	var active_card := HeroSystem.get_card_data(active_hero_id)
	var active_name := str(active_card.get("name", active_hero_id)).to_upper()
	auto_dps_label.text = "AUTO-DPS · %d / s · %s · %s" % [
		HeroSystem.get_total_auto_dps(),
		active_name,
		EncounterFeelSystem.hero_role_label(active_hero_id)
	]
	_refresh_hero_equipment_ui()
	_refresh_hero_progression_v151()
	_set_hero_button(hero_knight, "knight")
	_set_hero_button(hero_archer, "archer")
	_set_hero_button(hero_mage, "mage")

func _set_hero_button(button: Button, hero_id: String) -> void:
	var data := HeroSystem.get_card_data(hero_id)
	if data.is_empty():
		button.visible = false
		return
	button.visible = true
	if not bool(data.unlocked):
		button.disabled = true
		button.text = "🔒 %s\nAb Account-Lv. %d" % [data.name, int(data.unlock_level)]
		return
	button.disabled = false
	var selected := hero_id == selected_hero_id
	button.text = "%s%s\nLv. %d · Stärke %d\nW%d · T%d\n%s" % [
		"✓ " if selected else "",
		data.name,
		int(data.level),
		int(data.power),
		int(data.weapon_tier),
		int(data.charm_tier),
		"AUSGEWÄHLT" if selected else "AUSWÄHLEN"
	]

func _open_heroes_slice() -> void:
	if core_input_locked or _core_modal_open(): return
	_switch_view(view_heroes)
	_update_hero_ui()
	CoreAnalytics.log_event("heroes_open", {"auto_dps":HeroSystem.get_total_auto_dps()})

func _select_hero_p0(hero_id: String) -> void:
	if not HeroSystem.select_hero(hero_id):
		reward_label.text = "Held noch nicht freigeschaltet"
		return
	selected_hero_id = hero_id
	CoreAnalytics.log_event("hero_selected", {"hero_id":hero_id})
	ModeGameplayPolishV196.hero_selected(self, hero_id, SettingsService.reduced_motion)
	_update_hero_ui()

func _upgrade_selected_hero_p0() -> void:
	_upgrade_hero(selected_hero_id)

func _refresh_hero_progression_v151()->void:
	var id:=selected_hero_id
	hero_mastery_label_p0.text=HeroProgressionSystem.mastery_text(id)
	hero_mastery_bar_p0.value=HeroProgressionSystem.mastery_ratio(id)*100.0
	hero_specialization_button_p0.text=HeroProgressionSystem.specialization_text(id)
	hero_specialization_button_p0.disabled=not HeroProgressionSystem.specialization_unlocked(id)
	hero_mastery_claim_p0.disabled=not HeroProgressionSystem.can_claim(id)
	hero_mastery_claim_p0.text="FORTSCHRITTS-BELOHNUNG ABHOLEN" if HeroProgressionSystem.can_claim(id) else "FORTSCHRITTS-BELOHNUNG"

func _toggle_hero_specialization_v151()->void:
	var result:=HeroProgressionSystem.toggle_specialization(selected_hero_id)
	if bool(result.get("ok",false)):
		reward_label.text="%s · %s" % [str(result.get("label","SPEZIALISIERUNG")), "AKTIV" if bool(result.get("enabled",false)) else "PAUSIERT"]
		HapticsService.success()
	else: reward_label.text=str(result.get("message","Noch gesperrt"))
	_update_hero_ui()

func _claim_hero_mastery_v151()->void:
	var result:=HeroProgressionSystem.claim(selected_hero_id)
	if bool(result.get("ok",false)):
		var reward:Dictionary=result.get("reward",{})
		var bits:Array[String]=[]
		if int(reward.get("gold",0))>0:bits.append("+%d GOLD" % int(reward.get("gold",0)))
		if int(reward.get("spins",0))>0:bits.append("+%d SPINS" % int(reward.get("spins",0)))
		if int(reward.get("realm_keys",0))>0:bits.append("+%d REALM-SCHLÜSSEL" % int(reward.get("realm_keys",0)))
		reward_label.text="HELDEN-FORTSCHRITT · "+" · ".join(bits)
		HapticsService.success()
	else: reward_label.text=str(result.get("message","Keine Belohnung bereit"))
	_refresh_all()

func _refresh_hero_equipment_ui() -> void:
	var data := HeroSystem.get_card_data(selected_hero_id)
	if data.is_empty(): return
	hero_equipment_hint.text = "AUSRÜSTUNG · %s · +%d STÄRKE" % [str(data.name).to_upper(),int(data.equipment_power)]
	var weapon_cost := HeroSystem.equipment_upgrade_cost(selected_hero_id,"weapon")
	var charm_cost := HeroSystem.equipment_upgrade_cost(selected_hero_id,"charm")
	hero_weapon_button.text = "WAFFE · T%d\n%s" % [int(data.weapon_tier), "MAX" if weapon_cost <= 0 else "%s GOLD" % _compact_number(weapon_cost)]
	hero_charm_button.text = "TALISMAN · T%d\n%s" % [int(data.charm_tier), "MAX" if charm_cost <= 0 else "%s GOLD" % _compact_number(charm_cost)]
	hero_weapon_button.disabled = not bool(data.unlocked) or weapon_cost <= 0
	hero_charm_button.disabled = not bool(data.unlocked) or charm_cost <= 0
	var upgrade_cost := int(data.upgrade_cost)
	var at_cap := int(data.level) >= GameConfig.HERO_LEVEL_CAP
	hero_upgrade_button_p0.disabled = not bool(data.unlocked) or at_cap or PlayerData.gold < upgrade_cost
	hero_upgrade_button_p0.text = "HELD · MAX." if at_cap else "HELD VERBESSERN · %s GOLD" % _compact_number(upgrade_cost)

func _upgrade_hero_equipment(slot: String) -> void:
	var upgraded := HeroSystem.upgrade_equipment(selected_hero_id,slot)
	if upgraded:
		CoreAnalytics.log_event("hero_equipment_upgrade", {"hero_id":selected_hero_id,"slot":slot})
		HapticsService.success()
	else:
		reward_label.text = "Ausrüstung aktuell nicht verbesserbar"
	ModeGameplayPolishV196.hero_upgrade_feedback(self, selected_hero_id, upgraded, SettingsService.reduced_motion)
	_update_hero_ui()

func _upgrade_hero(hero_id: String) -> void:
	var upgraded := HeroSystem.upgrade(hero_id)
	if upgraded:
		var data := HeroSystem.get_card_data(hero_id)
		reward_label.text = "%s jetzt Lv. %d!" % [data.name, int(data.level)]
	else:
		var data := HeroSystem.get_card_data(hero_id)
		if not bool(data.get("unlocked", false)):
			reward_label.text = "Held noch nicht freigeschaltet"
		else:
			reward_label.text = "Nicht genug Gold"
	ModeGameplayPolishV196.hero_upgrade_feedback(self, hero_id, upgraded, SettingsService.reduced_motion)
	_update_hero_ui()


func _show_reward_burst() -> void:
	reward_burst.visible = true
	HomeNavigationRewardPolishV195.reward_punch(self, SettingsService.reduced_motion)
	reward_burst.modulate = Color(1,1,1,0)
	reward_burst.scale = Vector2(0.65,0.65)
	reward_burst.pivot_offset = reward_burst.size * 0.5
	var tween := create_tween().set_parallel(true)
	tween.tween_property(reward_burst, "modulate:a", 1.0, 0.12)
	tween.tween_property(reward_burst, "scale", Vector2(1.08,1.08), 0.24)
	await tween.finished
	var out := create_tween().set_parallel(true)
	out.tween_property(reward_burst, "modulate:a", 0.0, 0.28)
	out.tween_property(reward_burst, "scale", Vector2(1.25,1.25), 0.28)
	await out.finished
	reward_burst.visible = false

func _on_auto_damage(amount: int) -> void:
	# Auto-DPS remains visible but quieter than active tapping.
	if view_tap.visible:
		monster_hp.value = PlayerData.current_monster_hp
		monster_hp_label.text = "LEBEN %d / %d" % [PlayerData.current_monster_hp, PlayerData.monster_max_hp]
		_show_hero_assist_feedback_v172(amount)


func _show_hit_overlay() -> void:
	monster_hit_overlay.visible = true
	monster_hit_overlay.modulate = Color(1,1,1,0.92)
	monster_hit_overlay.scale = Vector2(0.90,0.90)
	monster_hit_overlay.pivot_offset = monster_hit_overlay.size * 0.5
	var tween := create_tween().set_parallel(true)
	tween.tween_property(monster_hit_overlay, "modulate:a", 0.0, 0.14)
	if not SettingsService.reduced_motion:
		tween.tween_property(monster_hit_overlay, "scale", Vector2(1.06,1.06), 0.14)
	await tween.finished
	monster_hit_overlay.visible = false
	monster_hit_overlay.scale = Vector2.ONE

func _update_attack_nav() -> void:
	var unlocked := PlayerData.player_level >= 7
	btn_attack.visible = unlocked
	if not unlocked:
		return
	btn_attack.text = "ANGRIFF"

func _open_lane_battle_slice() -> void:
	if core_input_locked or _core_modal_open():
		return
	_switch_view(view_attack)
	lane_result.text = ""
	if LaneAttackSystem.active:
		_update_lane_ui(LaneAttackSystem.get_state())
		CoreAnalytics.log_event("lane_battle_resume", {"time_left":LaneAttackSystem.time_left})
	elif LaneAttackSystem.has_pending_battle_result():
		_present_pending_lane_result_v150()
	else:
		LaneAttackSystem.start_battle()
		CoreAnalytics.log_event("lane_battle_start", {"region":"greenvale","stage":LaneBattleProgressionSystem.campaign_stage})
	_refresh_lane_progression_v150()

func _deploy_lane_unit(lane_index: int) -> void:
	if core_input_locked or _core_modal_open():
		return
	if LaneAttackSystem.deploy_unit(lane_index):
		CoreAnalytics.log_event("lane_unit_deployed", {"lane":lane_index})
		HapticsService.medium()
		ModeGameplayPolishV196.lane_deploy_feedback(self, lane_index, SettingsService.reduced_motion)
	else:
		lane_result.text = "Nicht genug Energie"
		HapticsService.light()

func _open_attack() -> void:
	if PlayerData.player_level < 7:
		reward_label.text = "Angriff ab Account-Lv. 7"
		return
	_switch_view(view_attack)
	lane_result.text = ""
	LaneAttackSystem.start_battle()

func _update_lane_ui(state: Dictionary) -> void:
	lane_timer.text = "%d s" % int(ceil(float(state.get("time_left", 0.0))))
	lane_enemy_hp.max_value = float(LaneAttackSystem.config.get("enemy_max_hp",100)) + LaneBattleProgressionSystem.enemy_hp_bonus()
	lane_enemy_hp.value = float(state.get("enemy_hp", 0.0))
	lane_energy_label.text = "ENERGIE %.0f/%.0f · EINHEIT %.1f KRAFT" % [float(state.get("energy", 0.0)),LaneAttackSystem.energy_max(),float(LaneAttackSystem.config.get("base_unit_power",3.2))+LaneBattleProgressionSystem.unit_power_bonus()]
	_refresh_lane_progression_v150()
	var enough := float(state.get("energy", 0.0)) >= LaneAttackSystem.unit_cost()
	lane_left_button.disabled = not enough
	lane_right_button.disabled = not enough
	var unit_cost := int(ceil(LaneAttackSystem.unit_cost()))
	var ready_text := "BEREIT" if enough else "ENERGIE FEHLT"
	lane_left_button.text = "LINKS\nHELD · %d · %s" % [unit_cost, ready_text]
	lane_right_button.text = "RECHTS\nHELD · %d · %s" % [unit_cost, ready_text]

	var push: Array = state.get("lane_push", [0.0,0.0])
	if push.size() >= 2:
		lane_left_unit.position.y = lerp(1000.0, 300.0, clamp(float(push[0]),0.0,1.0))
		lane_right_unit.position.y = lerp(1000.0, 300.0, clamp(float(push[1]),0.0,1.0))
	ModeGameplayPolishV196.lane_layout(self, state)

func _on_lane_finished(won: bool, reward: Dictionary) -> void:
	if won:
		lane_result.text = "SIEG · STUFE %d · +%d GOLD · +%d XP" % [int(reward.get("stage",0)),int(reward.get("gold",0)),int(reward.get("xp",0))]
		CoreAnalytics.log_event("lane_battle_complete", {"battle_id":str(reward.get("battle_id","")),"won":true,"stage":int(reward.get("stage",0))})
		LiveOpsRankingSystem.register_lane_win()
		ObjectiveSystem.register_action("lane_win",1)
		AudioService.play_sfx("coin")
		HapticsService.success()
	else:
		lane_result.text = "NIEDERLAGE · STUFE %d · ERNEUT VERSUCHEN" % int(reward.get("stage",0))
		CoreAnalytics.log_event("lane_battle_complete", {"battle_id":str(reward.get("battle_id","")),"won":false,"stage":int(reward.get("stage",0))})
		HapticsService.light()
	lane_next_battle_p0.visible=true
	lane_left_button.disabled=true
	lane_right_button.disabled=true
	LaneAttackSystem.acknowledge_pending_battle_result()
	ModeGameplayPolishV196.lane_result_feedback(self, won, SettingsService.reduced_motion)
	_refresh_lane_progression_v150()

func _refresh_lane_progression_v150() -> void:
	lane_stage_label_p0.text=LaneBattleProgressionSystem.stage_text()
	lane_mastery_label_p0.text=LaneBattleProgressionSystem.mastery_text()
	lane_mastery_bar_p0.value=LaneBattleProgressionSystem.mastery_ratio()*100.0
	lane_tech_button_p0.disabled=not LaneBattleProgressionSystem.can_upgrade_unit_tech() or LaneAttackSystem.active
	lane_tech_button_p0.text=LaneBattleProgressionSystem.tech_text()
	lane_mastery_claim_p0.disabled=not LaneBattleProgressionSystem.can_claim_mastery_reward() or LaneAttackSystem.active
	lane_mastery_claim_p0.text="FORTSCHRITTS-BELOHNUNG ABHOLEN" if LaneBattleProgressionSystem.can_claim_mastery_reward() else "FORTSCHRITTS-BELOHNUNG"
	lane_next_battle_p0.visible=not LaneAttackSystem.active and not lane_result.text.is_empty()

func _upgrade_lane_tech_v150()->void:
	if core_input_locked or _core_modal_open() or LaneAttackSystem.active: return
	var result:=LaneBattleProgressionSystem.upgrade_unit_tech()
	lane_result.text="EINHEITEN-TECH · STUFE %d · +%.1f KRAFT" % [int(result.get("level",LaneBattleProgressionSystem.unit_tech_level)),float(result.get("power_bonus",LaneBattleProgressionSystem.unit_power_bonus()))] if bool(result.get("ok",false)) else str(result.get("message","Upgrade nicht möglich"))
	if bool(result.get("ok",false)): HapticsService.success()
	_refresh_all()

func _claim_lane_mastery_v150()->void:
	if core_input_locked or _core_modal_open() or LaneAttackSystem.active: return
	var result:=LaneBattleProgressionSystem.claim_mastery_reward()
	if bool(result.get("ok",false)):
		var reward:Dictionary=result.get("reward",{})
		var bits:Array[String]=[]
		if int(reward.get("gold",0))>0: bits.append("+%d GOLD" % int(reward.get("gold",0)))
		if int(reward.get("spins",0))>0: bits.append("+%d SPINS" % int(reward.get("spins",0)))
		if int(reward.get("realm_keys",0))>0: bits.append("+%d REALM-SCHLÜSSEL" % int(reward.get("realm_keys",0)))
		lane_result.text="ANGRIFF-FORTSCHRITT · "+" · ".join(bits)
		HapticsService.success()
	else: lane_result.text=str(result.get("message","Keine Belohnung bereit"))
	_refresh_all()

func _start_next_lane_battle_v150()->void:
	if core_input_locked or _core_modal_open() or LaneAttackSystem.active: return
	lane_result.text=""
	lane_next_battle_p0.visible=false
	LaneAttackSystem.start_battle()
	CoreAnalytics.log_event("lane_battle_start",{"region":"greenvale","stage":LaneBattleProgressionSystem.campaign_stage})

func _present_pending_lane_result_v150()->void:
	if not LaneAttackSystem.has_pending_battle_result(): return
	var result:=LaneAttackSystem.peek_pending_battle_result()
	lane_result.text=("SIEG" if bool(result.get("won",false)) else "NIEDERLAGE")+" · STUFE %d · +%d GOLD · +%d XP" % [int(result.get("stage",0)),int(result.get("gold",0)),int(result.get("xp",0))]
	lane_next_battle_p0.visible=true
	LaneAttackSystem.acknowledge_pending_battle_result()
	CoreAnalytics.log_event("lane_battle_restored",{"battle_id":str(result.get("battle_id",""))})
	_continue_pending_flow_v154()

func _restore_pending_lane_battle_v150()->void:
	if SpinPresentationState.has_pending_result() or DiceJourneySystem.has_pending_result() or PuzzleSystem.has_pending_completion() or TowerDefenseSystem.has_pending_run_result(): return
	if not LaneAttackSystem.has_pending_battle_result(): return
	_switch_view(view_attack)
	_present_pending_lane_result_v150()


func _update_defense_nav() -> void:
	var unlocked := PlayerData.player_level >= GameConfig.DEFENSE_UNLOCK_ACCOUNT_LEVEL
	btn_defense.visible = unlocked
	if unlocked:
		btn_defense.text = "VERTEIDIGUNG"

func _open_defense() -> void:
	if PlayerData.player_level < GameConfig.DEFENSE_UNLOCK_ACCOUNT_LEVEL:
		reward_label.text = "VERTEIDIGUNG AB SPIELERSTUFE %d" % GameConfig.DEFENSE_UNLOCK_ACCOUNT_LEVEL
		return
	_switch_view(view_defense)
	td_result.text = ""
	TowerDefenseSystem.start_defense()

func _upgrade_defense_towers() -> void:
	if not TowerDefenseSystem.upgrade_towers():
		td_result.text = "Noch nicht genug Energie"
	else:
		td_result.text = "Türme verstärkt!"

func _update_td_ui(state: Dictionary) -> void:
	td_timer.text = "%d s" % int(ceil(float(state.get("time_left",0.0))))
	td_core_hp.value = float(state.get("core_hp",0.0))
	td_wave_label.text = "WELLE %d · %d GEGNER" % [
		int(state.get("wave",0)),
		int(state.get("enemies_alive",0))
	]
	td_energy_label.text = "ENERGIE %.0f/10 · TURM %.1f" % [
		float(state.get("energy",0.0)),
		float(state.get("tower_power",0.0))
	]
	td_upgrade_button.disabled = float(state.get("energy",0.0)) < TowerDefenseSystem.TOWER_UPGRADE_COST

	# Simple production-ready movement placeholder:
	# marker follows the fixed route notion without requiring player precision.
	var elapsed := GameConfig.DEFENSE_TARGET_DURATION - float(state.get("time_left",0.0))
	var phase := fmod(max(0.0,elapsed), 10.0) / 10.0
	td_enemy_marker.position.x = lerp(65.0, 760.0, phase)
	td_enemy_marker.position.y = 170.0 + sin(phase * PI) * 460.0

func _on_td_finished(won: bool, reward: Dictionary) -> void:
	if won:
		td_result.text = "DORF VERTEIDIGT! +%d Gold" % int(reward.get("gold",0))
		RewardService.mixed("Dorf verteidigt", int(reward.get("gold",0)), 0, 0, int(reward.get("xp",0)))
	else:
		td_result.text = "Dorf gefallen · erneut versuchen"
	await get_tree().create_timer(1.2).timeout
	_switch_view(view_tap)


func _open_daily_slice() -> void:
	if core_input_locked or _core_modal_open():
		return
	_switch_view(view_daily)
	_update_daily_ui()
	CoreAnalytics.log_event("daily_open", {
		"can_claim":DailyRewards.can_claim_today(),
		"day_index":DailyRewards.current_day_index()
	})

func _open_quests_slice() -> void:
	if core_input_locked or _core_modal_open():
		return
	_switch_view(view_quests)
	_rebuild_quests()
	CoreAnalytics.log_event("quests_open", {
		"claimed":QuestSystem.completed_count(),
		"total":QuestSystem.total_count()
	})

func _format_daily_reward(reward: Dictionary) -> String:
	var parts: Array[String] = []
	if int(reward.get("gold",0)) > 0:
		parts.append("%d GOLD" % int(reward.get("gold",0)))
	if int(reward.get("spins",0)) > 0:
		parts.append("%d SPINS" % int(reward.get("spins",0)))
	if int(reward.get("gems",0)) > 0:
		parts.append("%d GEMS" % int(reward.get("gems",0)))
	return " · ".join(parts) if not parts.is_empty() else "BELOHNUNG"

func _update_daily_ui() -> void:
	if not FeatureFlags.SHOW_DAILY:
		return
	var can_claim := DailyRewards.can_claim_today()
	var reward := DailyRewards.current_reward()
	var day_number := DailyRewards.current_day_index() + 1
	daily_claim_button.disabled = not can_claim or core_input_locked
	daily_claim_button.text = "TAG %d ABHOLEN" % day_number if can_claim else "HEUTE ABGEHOLT ✓"
	daily_status_label.text = "BEREIT · %s" % _format_daily_reward(reward) if can_claim else "Heute bereits abgeholt · morgen geht es weiter"
	daily_button.text = "TAGESBONUS !" if can_claim else "TAGESBONUS ✓"
	var cycle_parts: Array[String] = []
	for i in range(DailyRewards.rewards.size()):
		var prefix := "▶" if i == DailyRewards.current_day_index() else "•"
		cycle_parts.append("%s%d" % [prefix,i + 1])
	daily_cycle_label.text = "7-TAGE-ZYKLUS · " + "  ".join(cycle_parts)

func _claim_daily_reward() -> void:
	if core_input_locked or _core_modal_open():
		return
	core_input_locked = true
	var result := DailyRewards.claim_today()
	if bool(result.get("ok",false)):
		CoreAnalytics.log_event("daily_claim", {
			"day_index":int(result.get("day_index",0)),
			"gold":int(result.get("gold",0)),
			"spins":int(result.get("spins",0)),
			"gems":int(result.get("gems",0))
		})
		RewardService.present({
			"title":"Tagesbonus",
			"gold":int(result.get("gold",0)),
			"gems":int(result.get("gems",0)),
			"spins":int(result.get("spins",0))
		})
		AudioService.play_sfx("coin")
		HapticsService.success()
	else:
		daily_status_label.text = str(result.get("message","Heute bereits abgeholt"))
	core_input_locked = false
	_update_daily_ui()
	_refresh_all()

func _reward_text_v152(reward:Dictionary)->String:
	var bits:Array[String]=[]
	if int(reward.get("gold",0))>0:bits.append("%d GOLD" % int(reward.get("gold",0)))
	if int(reward.get("spins",0))>0:bits.append("%d SPINS" % int(reward.get("spins",0)))
	if int(reward.get("realm_keys",0))>0:bits.append("%d SCHLÜSSEL" % int(reward.get("realm_keys",0)))
	return " · ".join(bits)

func _add_objective_header_v152(title:String)->void:
	var label:=Label.new();label.text=title;label.add_theme_font_size_override("font_size",22)
	label.custom_minimum_size=Vector2(0,56)
	var category := "achievements" if title == "ERFOLGE" else ("weekly" if title == "WÖCHENTLICH" else ("daily" if title == "TÄGLICH" else "collection"))
	ScreenUiAssemblyService.style_objective_header(label, category)
	quest_list.add_child(label)

func _add_objective_row_v152(category:String,row:Dictionary)->void:
	var panel := PanelContainer.new()
	panel.custom_minimum_size = Vector2(0, 104)
	var role_id := "ui.quest.row.default"
	if bool(row.claimed):
		role_id = "ui.quest.row.completed"
	elif bool(row.ready) or int(row.value) > 0:
		role_id = "ui.quest.row.active"
	ProductionUiBinder.apply_backdrop(panel, role_id, true, 0.12, true)
	var box:=HBoxContainer.new();box.custom_minimum_size=Vector2(0,92);box.add_theme_constant_override("separation",12)
	panel.add_child(box)
	var state_icon:=TextureRect.new();state_icon.custom_minimum_size=Vector2(62,62);state_icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;state_icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	state_icon.texture=SemanticAssetRegistry.texture_for_role(ScreenUiAssemblyService.objective_icon_role(row),false)
	box.add_child(state_icon)
	var label:=Label.new();label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	label.text="%s · %d / %d\n%s" % [str(row.title),int(row.value),int(row.target),_reward_text_v152(row.reward)]
	label.add_theme_font_size_override("font_size",20);box.add_child(label)
	var button:=Button.new();button.custom_minimum_size=Vector2(190,78)
	button.text="ABHOLEN" if bool(row.ready) else ("ERLEDIGT ✓" if bool(row.claimed) else "LÄUFT")
	button.disabled=not bool(row.ready) or core_input_locked
	ScreenUiAssemblyService.configure_objective_action(button,row)
	button.pressed.connect(func(cat=category,oid=str(row.id)):
		var result:=ObjectiveSystem.claim(cat,oid)
		if bool(result.get("ok",false)):
			CoreAnalytics.log_event("objective_claim",{"category":cat,"objective_id":oid})
			HapticsService.success()
		_rebuild_quests()
		_refresh_all()
	)
	box.add_child(button);quest_list.add_child(panel)

func _rebuild_quests() -> void:
	if not FeatureFlags.SHOW_QUESTS:return
	for child in quest_list.get_children():child.queue_free()
	quest_summary_label.text=ObjectiveSystem.summary()
	for category in ["daily","weekly","achievements"]:
		_add_objective_header_v152({"daily":"TÄGLICH","weekly":"WÖCHENTLICH","achievements":"ERFOLGE"}[category])
		for row in ObjectiveSystem.rows(category):_add_objective_row_v152(category,row)
	_add_objective_header_v152("SAMMLUNG")
	var collection:=ObjectiveSystem.collection_state()
	var panel:=PanelContainer.new();panel.custom_minimum_size=Vector2(0,104)
	var collection_role := "ui.quest.row.completed" if bool(collection.claimed) else ("ui.quest.row.active" if bool(collection.ready) else "ui.quest.row.default")
	ProductionUiBinder.apply_backdrop(panel, collection_role, true, 0.12, true)
	var box:=HBoxContainer.new();box.custom_minimum_size=Vector2(0,92);box.add_theme_constant_override("separation",12);panel.add_child(box)
	var state_icon:=TextureRect.new();state_icon.custom_minimum_size=Vector2(62,62);state_icon.expand_mode=TextureRect.EXPAND_IGNORE_SIZE;state_icon.stretch_mode=TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	state_icon.texture=SemanticAssetRegistry.texture_for_role(ScreenUiAssemblyService.objective_icon_role(collection),false)
	box.add_child(state_icon)
	var label:=Label.new();label.size_flags_horizontal=Control.SIZE_EXPAND_FILL
	label.text="%s · %d / %d\n%s" % [str(collection.title),int(collection.value),int(collection.target),_reward_text_v152(collection.reward)]
	label.add_theme_font_size_override("font_size",20);box.add_child(label)
	var button:=Button.new();button.custom_minimum_size=Vector2(190,78)
	button.text="ABHOLEN" if bool(collection.ready) else ("VOLLSTÄNDIG ✓" if bool(collection.claimed) else "ENTDECKEN")
	button.disabled=not bool(collection.ready) or core_input_locked
	ScreenUiAssemblyService.configure_objective_action(button,collection)
	button.pressed.connect(func():
		var result:=ObjectiveSystem.claim_collection()
		if bool(result.get("ok",false)):HapticsService.success()
		_rebuild_quests();_refresh_all()
	)
	box.add_child(button);quest_list.add_child(panel)

func _show_unlock_banner(_id: String, title: String) -> void:
	unlock_banner_label.text = "NEU: %s" % title.to_upper()
	unlock_banner.visible = true
	unlock_banner.modulate = Color(1,1,1,0)
	var tween := create_tween()
	tween.tween_property(unlock_banner,"modulate:a",1.0,0.18)
	tween.tween_interval(1.5)
	tween.tween_property(unlock_banner,"modulate:a",0.0,0.22)
	await tween.finished
	unlock_banner.visible = false

func _show_reward_modal(payload: Dictionary) -> void:
	reward_modal_title.text = str(payload.get("title","Belohnung")).to_upper()
	var lines: Array[String] = []
	if int(payload.get("gold",0)) > 0:
		lines.append("+%d Gold" % int(payload.get("gold",0)))
	if int(payload.get("gems",0)) > 0:
		lines.append("+%d Gems" % int(payload.get("gems",0)))
	if int(payload.get("spins",0)) > 0:
		lines.append("+%d Spins" % int(payload.get("spins",0)))
	if int(payload.get("xp",0)) > 0:
		lines.append("+%d XP" % int(payload.get("xp",0)))
	reward_modal_text.text = "\n".join(lines)
	ScreenUiAssemblyService.prepare_reward_modal(self, payload)
	reward_modal.visible = true


func _update_home_core_cta() -> void:
	if PlayerData.spins > 0:
		home_wheel_cta.disabled = false
		home_wheel_cta.text = "REALM SPIN · %d" % PlayerData.spins
	else:
		home_wheel_cta.disabled = true
		home_wheel_cta.text = "KEINE SPINS"

func _update_monster_progress() -> void:
	var within_cycle := ((PlayerData.monster_level - 1) % 10) + 1
	if P0MonsterVisualSystem.is_boss(PlayerData.monster_level):
		monster_progress_label.text = "BOSS · 10 / 10"
	else:
		monster_progress_label.text = "%d / 10 BIS BOSS" % within_cycle

func _show_monster_reward(gold_amount: int) -> void:
	_reset_combat_flow_v172()
	boss_reward_chest_p0.visible = false
	boss_chest_glow_p0.visible = false
	monster_reward_title.text = "GESCHAFFT!"
	monster_reward_text.text = "+%d Gold\n+%d XP" % [gold_amount, GameConfig.PLAYER_XP_PER_MONSTER]
	monster_reward_continue.text = "ZUM BOSS" if P0MonsterVisualSystem.is_boss(PlayerData.monster_level) else "NÄCHSTES MONSTER"
	ScreenUiAssemblyService.prepare_boss_reward(self, false)
	RewardProgressionVisualDirectorV193.reward(self, monster_reward_overlay, "gold", SettingsService.reduced_motion)
	core_input_locked = true
	monster_reward_overlay.visible = true
	monster_reward_overlay.modulate = Color(1,1,1,0)
	monster_reward_overlay.scale = Vector2(0.88,0.88) if not SettingsService.reduced_motion else Vector2.ONE
	monster_reward_overlay.pivot_offset = monster_reward_overlay.size * 0.5
	var tween := create_tween().set_parallel(true)
	tween.tween_property(monster_reward_overlay,"modulate:a",1.0,0.14)
	if not SettingsService.reduced_motion:
		tween.tween_property(monster_reward_overlay,"scale",Vector2.ONE,0.20).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _continue_after_monster_reward() -> void:
	if not monster_reward_overlay.visible or monster_reward_continue.disabled:
		return
	monster_reward_continue.disabled = true
	monster_reward_overlay.visible = false
	monster_state_locked = false

	# Next encounter was already committed during the kill transaction.
	_update_monster_visual()
	_update_monster_ui()
	_update_monster_progress()
	if P0MonsterVisualSystem.is_boss(PlayerData.monster_level):
		await _show_boss_intro()
	core_input_locked = false
	monster_reward_continue.disabled = false

func _show_boss_intro() -> void:
	_reset_combat_flow_v172()
	CoreAnalytics.log_event("boss_start",{"monster_level":PlayerData.monster_level})
	AudioService.play_sfx("boss_intro")
	HapticsService.medium()
	boss_intro_label.text = "%s\nBOSS-KAMPF · EXTRA-BELOHNUNG" % MonsterCatalog.display_name_for_level(PlayerData.monster_level).to_upper()
	boss_intro_overlay.visible = true
	boss_intro_overlay.modulate = Color(1,1,1,0)
	var tween := create_tween()
	tween.tween_property(boss_intro_overlay,"modulate:a",1.0,0.16)
	tween.tween_interval(1.05)
	tween.tween_property(boss_intro_overlay,"modulate:a",0.0,0.20)
	await tween.finished
	boss_intro_overlay.visible = false
	await _show_boss_shield_state()

func _show_boss_defeat(gold_amount: int) -> void:
	_reset_combat_flow_v172()
	boss_defeat_burst.visible = true
	boss_defeat_burst.modulate = Color(1,1,1,0)
	boss_defeat_burst.scale = Vector2(0.7,0.7)
	boss_defeat_burst.pivot_offset = boss_defeat_burst.size * 0.5
	var tween := create_tween().set_parallel(true)
	tween.tween_property(boss_defeat_burst,"modulate:a",1.0,0.16)
	tween.tween_property(boss_defeat_burst,"scale",Vector2(1.12,1.12),0.30)
	await tween.finished
	monster_reward_title.text = "BOSS BESIEGT!"
	monster_reward_text.text = "+%d Gold\\n+%d XP\\n+2 Spins" % [gold_amount, GameConfig.PLAYER_XP_PER_MONSTER]
	monster_reward_continue.text = "WEITER ZUR JAGD"
	ScreenUiAssemblyService.prepare_boss_reward(self, true)
	boss_reward_chest_p0.visible = true
	RewardProgressionVisualDirectorV193.chest_sequence(self, boss_reward_chest_p0, SettingsService.reduced_motion)
	RewardProgressionVisualDirectorV193.reward(self, monster_reward_overlay, "special", SettingsService.reduced_motion)
	boss_chest_glow_p0.visible = true
	core_input_locked = true
	monster_reward_overlay.visible = true
	var out := create_tween()
	out.tween_property(boss_defeat_burst,"modulate:a",0.0,0.28)
	await out.finished
	boss_defeat_burst.visible = false


func _show_wheel_reward(result: Dictionary) -> void:
	var kind := str(result.get("type",""))
	var segment_index := clampi(
		int(result.get("visual_symbol_index",result.get("segment_index",0))),
		0,
		maxi(spin_symbol_textures.size()-1,0)
	)
	wheel_reward_title_p0.text = "JACKPOT!" if kind == "special" else "GEWONNEN!"
	wheel_reward_text_p0.text = str(result.get("message","Belohnung"))
	if not spin_symbol_textures.is_empty():
		wheel_reward_icon_p0.texture = spin_symbol_textures[segment_index]
	wheel_reward_icon_p0.modulate = Color.WHITE
	core_input_locked = true
	wheel_reward_overlay_p0.visible = true
	wheel_reward_overlay_p0.modulate = Color(1,1,1,0)
	wheel_reward_overlay_p0.scale = Vector2.ONE if SettingsService.reduced_motion else Vector2(0.90,0.90)
	wheel_reward_overlay_p0.pivot_offset = wheel_reward_overlay_p0.size * 0.5
	var tween := create_tween().set_parallel(true)
	tween.tween_property(wheel_reward_overlay_p0,"modulate:a",1.0,0.14)
	if not SettingsService.reduced_motion:
		tween.tween_property(wheel_reward_overlay_p0,"scale",Vector2.ONE,0.20).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)

func _close_wheel_reward() -> void:
	if not wheel_reward_overlay_p0.visible:
		return
	wheel_reward_overlay_p0.visible = false
	SpinPresentationState.acknowledge_pending_result()
	SaveGame.save_game()
	core_input_locked = false
	_continue_pending_flow_v154()
	win_line_label.text = "GEWINNLINIE · MITTLERE REIHE"
	spin_button.disabled = PlayerData.spins <= 0
	_refresh_all()

func _refresh_p0_village() -> void:
	_update_building_button(building_townhall,"townhall")
	_update_building_button(building_goldmine,"goldmine")
	_update_building_button(building_forge,"forge")
	_update_building_button(building_luck,"lucktemple")
	_update_building_art(building_townhall_art,"townhall")
	_update_building_art(building_goldmine_art,"goldmine")
	_update_building_art(building_forge_art,"forge")
	_update_building_art(building_luck_art,"lucktemple")

	# Old placeholder village controls remain technically compatible but are hidden in P0.
	town_hall_art.visible = false
	gold_mine_art.visible = false
	forge_art.visible = false
	gold_mine_label.visible = false
	forge_label.visible = false
	town_hall_button.visible = false
	building_select_glow.visible = false
	village_growth_label_v153.text = VillageProgressionSystem.prosperity_text()
	village_growth_bar_v153.value = VillageProgressionSystem.prosperity_ratio() * 100.0
	village_forge_action_v153.text = VillageProgressionSystem.forge_text()
	village_forge_action_v153.disabled = not VillageProgressionSystem.can_forge_craft() or core_input_locked
	village_temple_action_v153.text = VillageProgressionSystem.temple_text()
	village_temple_action_v153.disabled = not VillageProgressionSystem.temple_available() or core_input_locked
	village_prosperity_claim_v153.disabled = not VillageProgressionSystem.can_claim_prosperity() or core_input_locked
	village_prosperity_claim_v153.text = "DORF-BELOHNUNG ABHOLEN" if VillageProgressionSystem.can_claim_prosperity() else "DORF-WACHSTUM-BELOHNUNG"
	_refresh_goldmine_claim_p0()
	ScreenUiAssemblyService.refresh_village_loop_state(
		self,
		P0VillageSystem.pending_goldmine_gold(),
		VillageProgressionSystem.can_forge_craft(),
		VillageProgressionSystem.temple_available(),
		VillageProgressionSystem.can_claim_prosperity()
	)
	SpinVillageResponsivePolishV194.village_refresh(self, SettingsService.reduced_motion)

func _update_building_button(button: Button, building_id: String) -> void:
	var level := P0VillageSystem.get_level(building_id)
	var name := P0VillageSystem.get_building_name(building_id)
	var display_text := ""
	if P0VillageSystem.is_max(building_id):
		display_text = "%s · STUFE %d · MAX." % [name.to_upper(),level]
		button.modulate = Color(0.90,0.94,0.90,1.0)
		ScreenCompositionService.new().set_building_label(button, display_text)
		return
	var validation:=P0VillageSystem.can_upgrade(building_id)
	var cost:=P0VillageSystem.get_cost(building_id)
	if bool(validation.get("ok",false)):
		display_text = "%s · STUFE %d\nBEREIT · %d GOLD" % [name.to_upper(),level,cost]
		button.modulate = Color.WHITE
	elif str(validation.get("message","")).begins_with("Rathaus"):
		display_text = "%s · STUFE %d\nGESPERRT · RATHAUS %d" % [name.to_upper(),level,level+1]
		button.modulate = Color(0.62,0.67,0.70,1.0)
	else:
		var missing := maxi(cost - PlayerData.gold,0)
		display_text = "%s · STUFE %d\nNOCH %d GOLD" % [name.to_upper(),level,missing]
		button.modulate = Color(0.72,0.76,0.78,1.0)
	ScreenCompositionService.new().set_building_label(button, display_text)


func _open_building_upgrade(building_id: String) -> void:
	if core_input_locked or _core_modal_open():
		return
	core_input_locked = true
	selected_building_id = building_id
	var level := P0VillageSystem.get_level(building_id)
	var name := P0VillageSystem.get_building_name(building_id)
	var effect := P0VillageSystem.get_effect(building_id)
	_refresh_building_stage_preview(building_id)
	building_upgrade_title_p0.text = "%s · STUFE %d" % [name.to_upper(),level]
	building_upgrade_effect_p0.text = effect
	if P0VillageSystem.is_max(building_id):
		building_upgrade_cost_p0.text = "MAXIMALE STUFE"
		building_upgrade_button_p0.text = "MAX."
		building_upgrade_button_p0.disabled = true
	else:
		var cost := P0VillageSystem.get_cost(building_id)
		var validation:=P0VillageSystem.can_upgrade(building_id)
		building_upgrade_cost_p0.text = "%d GOLD · VERFÜGBAR %d" % [cost,PlayerData.gold]
		if not bool(validation.get("ok",false)):
			building_upgrade_button_p0.text = str(validation.get("message","NICHT MÖGLICH")).to_upper()
			building_upgrade_button_p0.disabled = true
		else:
			building_upgrade_button_p0.text = "VERBESSERN · %d GOLD" % cost
			building_upgrade_button_p0.disabled = false
	building_upgrade_overlay_p0.visible = true

func _upgrade_selected_building() -> void:
	if not building_upgrade_overlay_p0.visible:
		return
	building_upgrade_button_p0.disabled = true
	var previous_level := P0VillageSystem.get_level(selected_building_id)
	var result := P0VillageSystem.upgrade(selected_building_id)
	if not bool(result.get("ok",false)):
		building_upgrade_effect_p0.text = str(result.get("message","Nicht möglich"))
		building_upgrade_button_p0.disabled = P0VillageSystem.is_max(selected_building_id) or PlayerData.gold < P0VillageSystem.get_cost(selected_building_id)
		return

	CoreAnalytics.log_event("building_upgrade", {
		"upgrade_id":str(result.get("upgrade_id","")),
		"building_id":selected_building_id,
		"from_level":int(result.get("from_level",previous_level)),
		"to_level":int(result.get("to_level",P0VillageSystem.get_level(selected_building_id))),
		"config_version":str(result.get("config_version","v1.53-village-v2-06"))
	})
	AudioService.play_sfx("upgrade")
	HapticsService.success()
	building_upgrade_overlay_p0.visible = false
	await _show_upgrade_celebration()
	_refresh_p0_village()
	await _show_building_upgrade_feedback(selected_building_id, previous_level, P0VillageSystem.get_level(selected_building_id))
	if FeatureFlags.SHOW_QUESTS:
		QuestSystem.add_progress("upgrade_1", 1)
	ObjectiveSystem.register_action("village_upgrade",1)
	P0VillageSystem.acknowledge_pending_upgrade_result()
	core_input_locked = false
	_refresh_p0_village()

func _refresh_building_stage_preview(building_id: String) -> void:
	var targets := [building_stage_1, building_stage_2, building_stage_3]
	var current := P0VillageSystem.get_level(building_id)
	for i in range(3):
		var texture := P0VillageVisualSystem.texture_for_level(building_id, i + 1)
		if texture:
			targets[i].texture = texture
			var stage_tint := P0VillageVisualSystem.visual_tint_for_level(i + 1)
			targets[i].modulate = stage_tint if i + 1 <= current else Color(0.40,0.44,0.48,0.68)
			var base_stage_scale := P0VillageVisualSystem.visual_scale_for_level(i + 1)
			targets[i].scale = Vector2.ONE * (base_stage_scale * (1.05 if i + 1 == current else 1.0))
	building_stage_label.text = "AKTUELL · STUFE %d / 3" % current

func _show_building_upgrade_feedback(building_id: String, old_level: int, new_level: int) -> void:
	var target: Control = null
	match building_id:
		"townhall": target = building_townhall
		"goldmine": target = building_goldmine
		"forge": target = building_forge
		"lucktemple": target = building_luck
	if target == null:
		return
	var base_scale := target.scale
	if SettingsService.reduced_motion:
		target.modulate = Color(1.0,0.96,0.72,1.0)
		await get_tree().create_timer(0.12).timeout
		target.modulate = Color.WHITE
	else:
		var tween := create_tween()
		tween.tween_property(target,"scale",base_scale * 1.06,0.10).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
		tween.tween_property(target,"scale",base_scale,0.14)
		target.modulate = Color(1.0,0.94,0.65,1.0)
		await tween.finished
		target.modulate = Color.WHITE
	CoreAnalytics.log_event("building_upgrade_feedback", {
		"building_id":building_id,
		"from_level":old_level,
		"to_level":new_level
	})

func _show_upgrade_celebration() -> void:
	upgrade_coin_burst_p0.visible = true
	upgrade_coin_burst_p0.modulate = Color(1,1,1,0)
	upgrade_coin_burst_p0.scale = Vector2(0.7,0.7)
	upgrade_coin_burst_p0.pivot_offset = upgrade_coin_burst_p0.size * 0.5
	var tween := create_tween().set_parallel(true)
	tween.tween_property(upgrade_coin_burst_p0,"modulate:a",1.0,0.12)
	tween.tween_property(upgrade_coin_burst_p0,"scale",Vector2(1.15,1.15),0.26)
	await tween.finished
	var out := create_tween()
	out.tween_property(upgrade_coin_burst_p0,"modulate:a",0.0,0.26)
	await out.finished
	upgrade_coin_burst_p0.visible = false


func _show_monster_state(state: String, duration: float) -> void:
	var texture := P0MonsterVisualSystem.texture_for(PlayerData.monster_level,state)
	if texture:
		monster_button.texture_normal = texture
	await get_tree().create_timer(duration).timeout
	if not monster_state_locked:
		var idle := P0MonsterVisualSystem.texture_for(PlayerData.monster_level,"idle")
		if idle:
			monster_button.texture_normal = idle

func _show_monster_defeat_state_for_level(defeated_level: int, is_boss: bool) -> void:
	var texture := P0MonsterVisualSystem.texture_for(defeated_level,"defeat")
	if texture:
		monster_button.texture_normal = texture
	var encounter_id := P0MonsterVisualSystem.production_asset_id(defeated_level)
	CoreAnalytics.log_event("monster_defeat_visual", {
		"encounter_id":encounter_id,
		"state":"defeat"
	})
	if SettingsService.reduced_motion:
		await get_tree().create_timer(0.10).timeout
	elif is_boss:
		await get_tree().create_timer(0.46).timeout
	else:
		await get_tree().create_timer(0.24).timeout

func _show_reward_pulse() -> void:
	reward_pulse_p0.visible = true
	if SettingsService.reduced_motion:
		reward_pulse_p0.modulate = Color(1,1,1,0.85)
		reward_pulse_p0.scale = Vector2.ONE
		await get_tree().create_timer(0.10).timeout
		reward_pulse_p0.visible = false
		kill_milestone_p0.visible = false
		return
	reward_pulse_p0.modulate = Color(1,1,1,0)
	reward_pulse_p0.scale = Vector2(0.65,0.65)
	reward_pulse_p0.pivot_offset = reward_pulse_p0.size * 0.5
	var tween := create_tween().set_parallel(true)
	tween.tween_property(reward_pulse_p0,"modulate:a",1.0,0.08)
	tween.tween_property(reward_pulse_p0,"scale",Vector2(1.15,1.15),0.18)
	await tween.finished
	var out := create_tween()
	out.tween_property(reward_pulse_p0,"modulate:a",0.0,0.15)
	await out.finished
	reward_pulse_p0.visible = false
	kill_milestone_p0.visible = false

func _show_boss_shield_state() -> void:
	if not P0MonsterVisualSystem.is_boss(PlayerData.monster_level):
		return
	var texture := P0MonsterVisualSystem.texture_for(PlayerData.monster_level,"shield")
	if texture:
		monster_button.texture_normal = texture
	boss_shield_fx_p0.visible = true
	CoreAnalytics.log_event("boss_shield_visual", {
		"encounter_id":P0MonsterVisualSystem.production_asset_id(PlayerData.monster_level)
	})
	await get_tree().create_timer(0.22 if SettingsService.reduced_motion else 0.55).timeout
	boss_shield_fx_p0.visible = false
	if not monster_state_locked:
		var idle := P0MonsterVisualSystem.texture_for(PlayerData.monster_level,"idle")
		if idle:
			monster_button.texture_normal = idle

func _update_building_art(target: TextureRect, building_id: String) -> void:
	var texture := P0VillageVisualSystem.texture_for(building_id)
	if texture:
		target.texture = texture
	var level := P0VillageSystem.get_level(building_id)
	target.pivot_offset = target.size * 0.5
	target.scale = Vector2.ONE * P0VillageVisualSystem.visual_scale_for_level(level)
	target.modulate = P0VillageVisualSystem.visual_tint_for_level(level)

func _check_level_up_p0() -> void:
	if PlayerData.player_level > last_seen_player_level:
		last_seen_player_level = PlayerData.player_level
		level_up_text_p0.text = "SPIELERSTUFE %d" % PlayerData.player_level
		if PlayerData.player_level == 20 and RegionProgressionSystem.is_unlocked("frostmark"):
			level_up_text_p0.text += "\nFROSTMARK FREIGESCHALTET · CONTENT FOLGT"
			CoreAnalytics.log_event("region_unlocked", {"region_id":"frostmark","account_level":20})
		core_input_locked = true
		level_up_overlay_p0.visible = true
		RewardProgressionVisualDirectorV193.level_up(self, level_up_overlay_p0, SettingsService.reduced_motion, PlayerData.player_level == 20)
		_show_reward_burst()

func _open_settings_p0() -> void:
	_refresh_settings_p0()
	core_input_locked = true
	settings_overlay_p0.visible = true

func _refresh_settings_p0() -> void:
	sound_toggle_p0.text = "SOUND · %s" % ("AN" if SettingsService.sound_enabled else "AUS")
	music_toggle_p0.text = "MUSIK · %s" % ("AN" if SettingsService.music_enabled else "AUS")
	haptics_toggle_p0.text = "HAPTIK · %s" % ("AN" if SettingsService.haptics_enabled else "AUS")
	reduced_motion_toggle_p0.text = "BEWEGUNG REDUZIEREN · %s" % ("AN" if SettingsService.reduced_motion else "AUS")
	damage_numbers_toggle_p0.text = "SCHADENSZAHLEN · %s" % ("AN" if SettingsService.damage_numbers_enabled else "AUS")
	screen_shake_toggle_p0.text = "BILDSCHIRM-WACKELN · %s" % ("AN" if SettingsService.screen_shake_enabled else "AUS")
	language_toggle_p0.text = "SPRACHE · %s" % SettingsService.language_code.to_upper()
	_refresh_account_p0()

func _refresh_account_p0() -> void:
	if AccountState.is_guest():
		account_status_p0.text = "GASTKONTO · LOKALER SPIELSTAND"
		link_guest_p0.disabled = false
		link_guest_p0.text = "GASTSPIELSTAND MIT KONTO VERKNÜPFEN"
	else:
		account_status_p0.text = "%s · LOKALES PROFIL" % AccountState.display_name
		link_guest_p0.disabled = true
		link_guest_p0.text = "PROFIL BEREITS ANGELEGT"
	account_progress_p0.text = "SPIELERSTUFE %d · REGION GRÜNHAIN" % PlayerData.player_level
	match AccountState.cloud_status:
		"local_only":
			cloud_status_p0.text = "ONLINE-SICHERUNG · LOKALES PROFIL · NOCH NICHT VERBUNDEN"
		"backend_required":
			cloud_status_p0.text = "ONLINE-SICHERUNG · KONTO ERFORDERLICH"
		_:
			cloud_status_p0.text = "ONLINE-SICHERUNG · NICHT VERBUNDEN"

func _open_account_p0() -> void:
	_refresh_account_p0()
	settings_overlay_p0.visible = false
	account_overlay_p0.visible = false
	support_overlay_p0.visible = false
	social_overlay_p0.visible = false
	feature_hub_overlay_p0.visible = false
	account_overlay_p0.visible = true
	core_input_locked = true
	CoreAnalytics.log_event("account_open", {"mode":AccountState.mode,"cloud_status":AccountState.cloud_status})

func _close_account_p0() -> void:
	account_overlay_p0.visible = false
	core_input_locked = false

func _account_link_info_p0() -> void:
	AccountState.mark_cloud_pending()
	account_message_p0.text = "Gast → Account ist vorbereitet. Für eine sichere Verknüpfung fehlt noch der serverseitige Account-/Cloud-Service."
	_refresh_account_p0()
	CoreAnalytics.log_event("guest_link_intent")

func _cloud_info_p0() -> void:
	account_message_p0.text = "Der lokale Spielstand bleibt spielbar. Cloud-Synchronisierung und Konfliktauflösung werden erst mit dem echten Account-Backend aktiviert."
	CoreAnalytics.log_event("cloud_status_open")

func _open_support_p0() -> void:
	settings_overlay_p0.visible = false
	support_overlay_p0.visible = true
	core_input_locked = true
	support_status_p0.text = "Offizielle Support-/Rechts-URLs werden für Release konfiguriert."
	CoreAnalytics.log_event("support_open")

func _close_support_p0() -> void:
	support_overlay_p0.visible = false
	core_input_locked = false

func _support_info_p0(section: String) -> void:
	support_status_p0.text = "%s · Inhalt/URL ist als Release-Slot vorbereitet." % section
	CoreAnalytics.log_event("support_section_open", {"section":section})

func _refresh_quick_action_badge_p0() -> void:
	var attention := RuntimeFlowService.attention_count()
	quick_badge_p0.visible = attention > 0
	quick_badge_p0.text = str(attention) if attention < 10 else "9+"


func _open_feature_hub_p0() -> void:
	if core_transitioning or core_input_locked or _core_modal_open():
		return
	feature_hub_overlay_p0.visible = true
	core_input_locked = true
	hub_heroes_p0.visible = FeatureFlags.SHOW_HEROES
	hub_journey_p0.visible = FeatureFlags.SHOW_REALM_JOURNEY
	hub_puzzle_p0.visible = FeatureFlags.SHOW_PUZZLE
	hub_defense_p0.visible = FeatureFlags.SHOW_TOWER_DEFENSE
	hub_lane_p0.visible = FeatureFlags.SHOW_LANE_BATTLE
	hub_meta_p0.visible = FeatureFlags.SHOW_EVENTS or FeatureFlags.SHOW_RANKINGS or FeatureFlags.SHOW_REALM_CHEST
	hub_profile_p0.visible = true
	feature_hub_status_v154.text = RuntimeFlowService.feature_hub_status()
	RuntimeGuidanceService.refresh(self)
	ModeGameplayPolishV196.mode_hub_open(self, SettingsService.reduced_motion)
	CoreAnalytics.log_event("feature_hub_open",{"attention":RuntimeFlowService.attention_count(),"pending":RuntimeFlowService.pending_kind()})

func _close_feature_hub_p0() -> void:
	feature_hub_overlay_p0.visible = false
	core_input_locked = false

func _hub_prepare_navigation_p0() -> void:
	feature_hub_overlay_p0.visible = false
	core_input_locked = false

func _hub_open_journey_v154()->void:
	_hub_prepare_navigation_p0()
	_open_journey_p0()

func _hub_open_heroes_p0() -> void:
	_hub_prepare_navigation_p0()
	_open_heroes_slice()

func _hub_open_puzzle_p0() -> void:
	_hub_prepare_navigation_p0()
	_open_core_view(view_puzzle,"puzzle_open")

func _hub_open_defense_p0() -> void:
	_hub_prepare_navigation_p0()
	_open_core_view(view_tower_defense,"tower_defense_open")

func _hub_open_lane_p0() -> void:
	_hub_prepare_navigation_p0()
	_open_lane_battle_slice()

func _hub_open_meta_p0() -> void:
	_hub_prepare_navigation_p0()
	_open_core_view(view_meta,"meta_open")

func _hub_open_profile_p0() -> void:
	_hub_prepare_navigation_p0()
	social_overlay_p0.visible = true
	core_input_locked = true
	_refresh_social_header_p0()
	_show_social_inbox_p0()
	CoreAnalytics.log_event("social_hub_open", {"source":"feature_hub","unread":SocialHubSystem.unread_count()})

func _hub_open_shop_p0() -> void:
	_hub_prepare_navigation_p0()
	shop_overlay_p0.visible = true
	core_input_locked = true
	_refresh_shop_p0()
	CoreAnalytics.log_event("shop_open",{"source":"feature_hub"})

func _close_shop_p0() -> void:
	shop_overlay_p0.visible = false
	core_input_locked = false

func _refresh_shop_p0() -> void:
	if shop_catalog_p0 == null:
		return
	var lines: Array[String] = []
	for product_id in PurchaseService.get_products().keys():
		var product: Dictionary = PurchaseService.get_products()[product_id]
		var seasonal := " · SAISONAL" if bool(product.get("seasonal",false)) else ""
		var payload: Dictionary = product.get("payload",{})
		var reward_bits: Array[String] = []
		if payload.has("gold"): reward_bits.append("%d GOLD" % int(payload.get("gold",0)))
		if payload.has("spins"): reward_bits.append("%d SPINS" % int(payload.get("spins",0)))
		if payload.has("gems"): reward_bits.append("%d JUWELEN" % int(payload.get("gems",0)))
		if payload.has("cosmetic"): reward_bits.append("KOSMETIK")
		if payload.has("no_ads"): reward_bits.append("WERBEFREI")
		lines.append("%s%s\n%s" % [
			str(product.get("display_name",product_id)).to_upper(),
			seasonal,
			" · ".join(reward_bits)
		])
	shop_catalog_p0.text = "\n\n".join(lines)
	shop_status_p0.text = "SHOP-VORSCHAU · KÄUFE SIND IN DIESER TESTVERSION NOCH NICHT AKTIV"
	ScreenUiAssemblyService.refresh_shop_state(self, PurchaseService.get_products())

func _hub_open_liveops_p0() -> void:
	_hub_prepare_navigation_p0()
	liveops_overlay_p0.visible = true
	core_input_locked = true
	_refresh_liveops_p0()
	CoreAnalytics.log_event("liveops_open")

func _close_liveops_p0() -> void:
	liveops_overlay_p0.visible = false
	core_input_locked = false

func _select_ranking_p0(board_type: String) -> void:
	LiveOpsRankingSystem.select_board(board_type)
	_refresh_liveops_p0()
	CoreAnalytics.log_event("ranking_tab_open",{"board":board_type})

func _refresh_liveops_p0() -> void:
	if liveops_overlay_p0 == null:
		return
	var event_name := str(LiveOpsRankingSystem.config.get("halloween_2026",{}).get("display_name","HALLOWEEN"))
	halloween_status_p0.text = "%s\n%s" % [event_name,LiveOpsRankingSystem.halloween_status_text()]
	halloween_progress_p0.text = LiveOpsRankingSystem.halloween_progress_text()
	halloween_currency_p0.text = "KÜRBISMARKEN · %d" % LiveOpsRankingSystem.halloween_tokens
	halloween_quests_p0.text = "EVENT-QUESTS\n" + LiveOpsRankingSystem.halloween_quests_text()
	var any_quest_ready := false
	for quest_row in LiveOpsRankingSystem.halloween_quest_rows():
		if bool(quest_row.get("ready",false)):
			any_quest_ready = true
			break
	halloween_quest_claim_p0.disabled = not any_quest_ready or LiveOpsRankingSystem.halloween_state() != "active"
	halloween_chest_p0.disabled = not LiveOpsRankingSystem.can_open_halloween_chest()
	halloween_chest_p0.text = LiveOpsRankingSystem.halloween_chest_status_text()
	halloween_claim_p0.disabled = not LiveOpsRankingSystem.can_claim_halloween_reward()
	halloween_claim_p0.text = "HALLOWEEN-BELOHNUNG ABHOLEN" if not halloween_claim_p0.disabled else "HALLOWEEN-BELOHNUNG"
	ranking_status_p0.text = LiveOpsRankingSystem.ranking_status_text()
	var selected_board := LiveOpsRankingSystem.selected_board
	ranking_daily_p0.text = "● TÄGLICH" if selected_board == "daily" else "TÄGLICH"
	ranking_weekly_p0.text = "● WÖCHENTLICH" if selected_board == "weekly" else "WÖCHENTLICH"
	ranking_event_p0.text = "● EVENT" if selected_board == "event" else "EVENT"
	ranking_reward_preview_p0.text = "BELOHNUNGS-VORSCHAU · %s\n%s" % [selected_board.to_upper(),LiveOpsRankingSystem.ranking_reward_preview()]
	ranking_claim_p0.disabled = not LiveOpsRankingSystem.can_claim_ranking_reward()
	ranking_claim_p0.text = "RANGLISTEN-BELOHNUNG ABHOLEN" if not ranking_claim_p0.disabled else "NOCH NICHT VERFÜGBAR"

func _claim_halloween_p0() -> void:
	var result := LiveOpsRankingSystem.claim_halloween_reward()
	if bool(result.get("ok",false)):
		meta_result_label.text = "HALLOWEEN · +%d GOLD · +%d SPINS" % [int(result.get("gold",0)),int(result.get("spins",0))]
		AudioService.play_sfx("coin")
		HapticsService.success()
	else:
		meta_result_label.text = str(result.get("message","Nicht verfügbar"))
	_refresh_all()

func _claim_halloween_quests_p0() -> void:
	var result := LiveOpsRankingSystem.claim_ready_halloween_quests()
	meta_result_label.text = "EVENT-QUESTS · +%d KÜRBISMARKEN" % int(result.get("tokens",0)) if bool(result.get("ok",false)) else str(result.get("message","Noch nichts bereit"))
	if bool(result.get("ok",false)):
		AudioService.play_sfx("coin")
		HapticsService.success()
	_refresh_liveops_p0()

func _open_halloween_chest_p0() -> void:
	var result := LiveOpsRankingSystem.open_halloween_chest()
	if bool(result.get("ok",false)):
		meta_result_label.text = "HALLOWEEN-TRUHE · +%d GOLD · +%d SPINS" % [int(result.get("gold",0)),int(result.get("spins",0))]
		AudioService.play_sfx("coin")
		HapticsService.success()
	else:
		meta_result_label.text = str(result.get("message","Event-Truhe nicht bereit"))
	_refresh_all()

func _claim_ranking_reward_p0() -> void:
	var result := LiveOpsRankingSystem.claim_ranking_reward()
	meta_result_label.text = str(result.get("message","Server-Verbindung erforderlich"))
	_refresh_liveops_p0()

func _hub_open_progression_p0() -> void:
	_hub_prepare_navigation_p0()
	progression_overlay_p0.visible = true
	core_input_locked = true
	_refresh_progression_p0()
	CoreAnalytics.log_event("progression_hub_open")

func _close_progression_p0() -> void:
	progression_overlay_p0.visible = false
	core_input_locked = false

func _refresh_progression_p0() -> void:
	if progression_text_p0 == null:
		return
	progression_text_p0.text = ProgressionOverviewSystem.summary_text()
	ScreenUiAssemblyService.refresh_progression_state(self, ProgressionOverviewSystem.tracks())

func _refresh_afk_p0() -> void:
	if afk_text_p0 == null:
		return
	afk_text_p0.text = AfkRewardSystem.preview_text()
	afk_claim_p0.disabled = not AfkRewardSystem.has_pending_reward()
	ScreenUiAssemblyService.refresh_afk_state(self, AfkRewardSystem.pending_reward, PlayerData.player_level)

func _show_afk_if_pending_p0() -> void:
	if SpinPresentationState.has_pending_result() or DiceJourneySystem.has_pending_result() or PuzzleSystem.has_pending_completion() or TowerDefenseSystem.has_pending_run_result() or LaneAttackSystem.has_pending_battle_result() or P0VillageSystem.has_pending_upgrade_result():
		return
	if not AfkRewardSystem.has_pending_reward():
		return
	afk_overlay_p0.visible = true
	core_input_locked = true
	_refresh_afk_p0()
	CoreAnalytics.log_event("afk_reward_presented",{
		"seconds":int(AfkRewardSystem.pending_reward.get("seconds",0)),
		"gold":int(AfkRewardSystem.pending_reward.get("gold",0))
	})

func _claim_afk_reward_p0() -> void:
	var result := AfkRewardSystem.claim()
	if not bool(result.get("ok",false)):
		return
	afk_overlay_p0.visible = false
	core_input_locked = false
	reward_label.text = "OFFLINE · +%d GOLD" % int(result.get("gold",0))
	AudioService.play_sfx("coin")
	HapticsService.success()
	CoreAnalytics.log_event("afk_reward_claimed",{
		"claim_id":str(result.get("claim_id","")),
		"seconds":int(result.get("seconds",0)),
		"gold":int(result.get("gold",0))
	})
	_refresh_all()
	_continue_pending_flow_v154()

var social_view_mode_p0: String = "inbox"

func _refresh_social_header_p0() -> void:
	if social_profile_p0 == null:
		return
	var profile := SocialHubSystem.profile_snapshot()
	social_profile_p0.text = "%s · STUFE %d · %s" % [
		str(profile.get("name","Gastheld")).to_upper(),
		int(profile.get("level",1)),
		str(profile.get("region","Grünhain")).to_upper()
	]
	social_stats_p0.text = "BOSSE %d · RATHAUS %d · TRUHEN %d · ERFOLGE %d/4" % [
		int(profile.get("bosses",0)),
		int(profile.get("village",1)),
		int(profile.get("chests",0)),
		SocialHubSystem.completed_achievement_count()
	]

func _open_social_p0() -> void:
	account_overlay_p0.visible = false
	social_overlay_p0.visible = true
	core_input_locked = true
	_refresh_social_header_p0()
	_show_social_inbox_p0()
	CoreAnalytics.log_event("social_hub_open", {"unread":SocialHubSystem.unread_count()})

func _close_social_p0() -> void:
	social_overlay_p0.visible = false
	core_input_locked = false

func _show_social_inbox_p0() -> void:
	social_view_mode_p0 = "inbox"
	var lines: Array[String] = []
	for message in SocialHubSystem.MESSAGES:
		var message_id := str(message.get("id",""))
		var unread := not SocialHubSystem.read_message_ids.has(message_id)
		lines.append("%s %s\n%s" % [
			"●" if unread else "✓",
			str(message.get("title","")),
			str(message.get("body",""))
		])
	social_content_p0.text = "\n\n".join(lines)
	social_action_p0.visible = true
	social_action_p0.disabled = SocialHubSystem.unread_count() <= 0
	social_action_p0.text = "ALLE ALS GELESEN MARKIEREN · %d OFFEN" % SocialHubSystem.unread_count()

func _show_social_achievements_p0() -> void:
	social_view_mode_p0 = "achievements"
	var lines: Array[String] = []
	for item in SocialHubSystem.achievements():
		var current := int(item.get("current",0))
		var target := maxi(int(item.get("target",1)),1)
		var done := current >= target
		lines.append("%s %s · %d/%d\n%s" % [
			"✓" if done else "○",
			str(item.get("title","")),
			mini(current,target),
			target,
			str(item.get("description",""))
		])
	social_content_p0.text = "\n\n".join(lines)
	social_action_p0.visible = false

func _show_social_friends_p0() -> void:
	social_view_mode_p0 = "friends"
	social_content_p0.text = "FREUNDE & ALLIANZEN\n\nFreundesliste, Einladungen, Online-Status und Allianzen benötigen den späteren serverseitigen Social-Service.\n\nEs werden in V1.36 bewusst keine Fake-Freunde oder simulierten Online-Spieler angezeigt."
	social_action_p0.visible = false
	CoreAnalytics.log_event("friends_backend_placeholder_open")

func _social_primary_action_p0() -> void:
	if social_view_mode_p0 != "inbox":
		return
	SocialHubSystem.mark_all_read()
	_show_social_inbox_p0()
	CoreAnalytics.log_event("inbox_mark_all_read")

func _open_core_view(target_view: Control, analytics_event: String) -> void:
	if core_transitioning or core_input_locked or _core_modal_open():
		return
	if not analytics_event.is_empty():
		CoreAnalytics.log_event(analytics_event)
	core_transitioning = true
	HomeNavigationRewardPolishV195.transition_out(self, target_view, SettingsService.reduced_motion)
	core_transition_p0.visible = true
	core_transition_p0.modulate.a = 0.0
	var fade_in := create_tween()
	fade_in.tween_property(core_transition_p0,"modulate:a",0.82,0.10)
	await fade_in.finished
	_switch_view(target_view)
	HomeNavigationRewardPolishV195.transition_in(self, target_view, SettingsService.reduced_motion)
	var fade_out := create_tween()
	fade_out.tween_property(core_transition_p0,"modulate:a",0.0,0.14)
	await fade_out.finished
	core_transition_p0.visible = false
	core_transitioning = false


func _core_modal_open() -> bool:
	return p0_debug_panel.visible or (
		monster_reward_overlay.visible
		or wheel_reward_overlay_p0.visible
		or no_spins_panel.visible
		or building_upgrade_overlay_p0.visible
		or boss_intro_overlay.visible
		or level_up_overlay_p0.visible
		or settings_overlay_p0.visible
		or account_overlay_p0.visible
		or support_overlay_p0.visible
		or social_overlay_p0.visible
		or feature_hub_overlay_p0.visible
		or liveops_overlay_p0.visible
		or shop_overlay_p0.visible
		or progression_overlay_p0.visible
		or afk_overlay_p0.visible
	)

func _reset_core_transient_state() -> void:
	core_input_locked = false
	core_transitioning = false
	wheel_spinning = false
	monster_state_locked = false
	core_transition_p0.visible = false
	wheel_reward_overlay_p0.visible = false
	monster_reward_overlay.visible = false
	building_upgrade_overlay_p0.visible = false
	boss_intro_overlay.visible = false
	boss_defeat_burst.visible = false
	boss_reward_chest_p0.visible = false
	boss_chest_glow_p0.visible = false
	reward_pulse_p0.visible = false
	kill_milestone_p0.visible = false
	upgrade_coin_burst_p0.visible = false
	spin_button.disabled = false
	monster_reward_continue.disabled = false
	reel_1.position.y = 290.0
	reel_2.position.y = 290.0
	reel_3.position.y = 290.0
	monster_button.rotation = 0.0
	monster_button.scale = Vector2.ONE
	monster_reaction_active = false
	monster_idle_clock = 0.0
	damage_label.modulate.a = 0.0
	monster_hit_overlay.visible = false
	monster_button.modulate = Color.WHITE
	home_wheel_cta.modulate = Color.WHITE
	spin_button.modulate = Color.WHITE
	first_session_hint_stage = 0
	first_session_hint_p0.visible = false
	liveops_overlay_p0.visible = false
	shop_overlay_p0.visible = false
	progression_overlay_p0.visible = false
	afk_overlay_p0.visible = false
	boss_proximity_p0.text = ""

func _notification(what: int) -> void:
	if what == NOTIFICATION_APPLICATION_PAUSED:
		SaveGame.save_game()
	elif what == NOTIFICATION_WM_CLOSE_REQUEST:
		SaveGame.save_game()
	elif what == NOTIFICATION_APPLICATION_FOCUS_OUT:
		SaveGame.save_game()

func _on_viewport_size_changed() -> void:
	_apply_mobile_runtime_polish()


func _close_settings_p0() -> void:
	settings_overlay_p0.visible = false
	core_input_locked = false


func _close_building_upgrade_p0() -> void:
	building_upgrade_overlay_p0.visible = false
	core_input_locked = false


func _close_level_up_p0() -> void:
	level_up_overlay_p0.visible = false
	core_input_locked = false


func _connect_once(signal_ref: Signal, callable: Callable) -> void:
	if not signal_ref.is_connected(callable):
		signal_ref.connect(callable)


func _exit_tree() -> void:
	core_input_locked = false
	core_transitioning = false


func _refresh_goldmine_claim_p0() -> void:
	var pending := P0VillageSystem.pending_goldmine_gold()
	var rate := P0VillageSystem.goldmine_rate_per_minute()
	goldmine_status_p0.text = "GOLDMINE · STUFE %d · %d/MIN · %d GOLD BEREIT" % [P0VillageSystem.get_level("goldmine"), rate, pending]
	goldmine_claim_button_p0.disabled = pending <= 0
	goldmine_claim_button_p0.text = "ABHOLEN" if pending > 0 else "PRODUZIERT"

func _claim_goldmine_p0() -> void:
	if core_input_locked or _core_modal_open():
		return
	var result := P0VillageSystem.claim_goldmine()
	if bool(result.get("ok",false)):
		AudioService.play_sfx("coin")
		HapticsService.light()
		CoreAnalytics.log_event("goldmine_claim", {"amount":int(result.get("amount",0)),"level":P0VillageSystem.get_level("goldmine")})
		ObjectiveSystem.register_action("goldmine_claim",1)
	_refresh_goldmine_claim_p0()
	_refresh_all()

func _craft_forge_v153()->void:
	if core_input_locked or _core_modal_open():return
	var result:=VillageProgressionSystem.craft_forge_upgrade()
	if bool(result.get("ok",false)):
		reward_label.text="SCHMIEDE · +%d TAP-SCHADEN · VEREDLUNG %d" % [int(result.get("tap_damage",0)),int(result.get("craft",0))]
		ObjectiveSystem.register_action("forge_craft",1)
		AudioService.play_sfx("upgrade");HapticsService.success()
	else:
		reward_label.text=str(result.get("message","Schmiede nicht bereit"))
	_refresh_all()

func _claim_temple_blessing_v153()->void:
	if core_input_locked or _core_modal_open():return
	var result:=VillageProgressionSystem.claim_temple_blessing()
	if bool(result.get("ok",false)):
		reward_label.text="GLÜCKSTEMPEL · +%d SPINS" % int(result.get("spins",0))
		ObjectiveSystem.register_action("temple_blessing",1)
		AudioService.play_sfx("coin");HapticsService.success()
	else:
		reward_label.text=str(result.get("message","Segen nicht bereit"))
	_refresh_all()

func _claim_village_prosperity_v153()->void:
	if core_input_locked or _core_modal_open():return
	var result:=VillageProgressionSystem.claim_prosperity()
	if bool(result.get("ok",false)):
		var reward:Dictionary=result.get("reward",{})
		var bits:Array[String]=[]
		if int(reward.get("gold",0))>0:bits.append("+%d GOLD" % int(reward.get("gold",0)))
		if int(reward.get("spins",0))>0:bits.append("+%d SPINS" % int(reward.get("spins",0)))
		if int(reward.get("realm_keys",0))>0:bits.append("+%d REALM-SCHLÜSSEL" % int(reward.get("realm_keys",0)))
		reward_label.text="DORF-WACHSTUM · "+" · ".join(bits)
		HapticsService.success()
	else:reward_label.text=str(result.get("message","Keine Belohnung bereit"))
	_refresh_all()

func _restore_pending_village_upgrade_v153()->void:
	if SpinPresentationState.has_pending_result() or DiceJourneySystem.has_pending_result() or PuzzleSystem.has_pending_completion() or TowerDefenseSystem.has_pending_run_result() or LaneAttackSystem.has_pending_battle_result():
		return
	if not P0VillageSystem.has_pending_upgrade_result():return
	var result:=P0VillageSystem.peek_pending_upgrade_result()
	_switch_view(view_dorf)
	selected_building_id=str(result.get("building_id","townhall"))
	reward_label.text="%s · STUFE %d ERREICHT · %d GOLD" % [str(result.get("name","GEBÄUDE")).to_upper(),int(result.get("to_level",1)),int(result.get("cost",0))]
	P0VillageSystem.acknowledge_pending_upgrade_result()
	CoreAnalytics.log_event("village_upgrade_restored",{"upgrade_id":str(result.get("upgrade_id",""))})
	_refresh_p0_village()
	_continue_pending_flow_v154()

func _try_kill_milestone_p0(defeated_level: int) -> void:
	var within_cycle := ((defeated_level - 1) % 10) + 1
	var cycle := int((defeated_level - 1) / 10)
	if within_cycle != 5 or cycle == last_kill_milestone_cycle:
		return
	last_kill_milestone_cycle = cycle
	CoreAnalytics.log_event("kill_milestone", {"cycle":cycle + 1,"kills":5})
	_show_kill_milestone_p0()

func _show_kill_milestone_p0() -> void:
	kill_milestone_p0.text = "5 / 10 · HALBZEIT ZUM BOSS!"
	kill_milestone_p0.visible = true
	kill_milestone_p0.modulate.a = 1.0
	if SettingsService.reduced_motion:
		var timer := get_tree().create_timer(0.75)
		await timer.timeout
		kill_milestone_p0.visible = false
		return
	var tween := create_tween()
	tween.tween_interval(0.55)
	tween.tween_property(kill_milestone_p0,"modulate:a",0.0,0.22)
	await tween.finished
	kill_milestone_p0.visible = false


func _on_goldmine_ui_timer_p0() -> void:
	if view_dorf.visible and not building_upgrade_overlay_p0.visible:
		_refresh_goldmine_claim_p0()


func _setup_p0_debug_harness() -> void:
	p0_debug_toggle.visible = P0TestHarness.enabled
	p0_debug_panel.visible = false
	if not P0TestHarness.enabled:
		return
	_connect_once(p0_debug_toggle.pressed, _open_p0_debug_panel)
	_connect_once(debug_close.pressed, _close_p0_debug_panel)
	_connect_once(debug_fresh.pressed, func(): _apply_p0_test_profile(P0TestHarness.PROFILE_FRESH))
	_connect_once(debug_half_boss.pressed, func(): _apply_p0_test_profile(P0TestHarness.PROFILE_HALF_BOSS))
	_connect_once(debug_boss.pressed, func(): _apply_p0_test_profile(P0TestHarness.PROFILE_BOSS_READY))
	_connect_once(debug_wheel.pressed, func(): _apply_p0_test_profile(P0TestHarness.PROFILE_WHEEL))
	_connect_once(debug_village.pressed, func(): _apply_p0_test_profile(P0TestHarness.PROFILE_VILLAGE))
	_connect_once(debug_return.pressed, func(): _apply_p0_test_profile(P0TestHarness.PROFILE_RETURN))
	_connect_once(debug_low_resource.pressed, func(): _apply_p0_test_profile(P0TestHarness.PROFILE_LOW_RESOURCE))
	_connect_once(debug_recovery.pressed, _create_p0_recovery_fixture)
	_refresh_p0_debug_status()

func _open_p0_debug_panel() -> void:
	if not P0TestHarness.enabled or _core_modal_open():
		return
	core_input_locked = true
	_refresh_p0_debug_status()
	p0_debug_panel.visible = true

func _close_p0_debug_panel() -> void:
	p0_debug_panel.visible = false
	core_input_locked = false

func _apply_p0_test_profile(profile_id: String) -> void:
	var result := P0TestHarness.apply_profile(profile_id)
	p0_debug_status.text = str(result.get("message", "Profil aktiv: %s" % profile_id))
	_reset_core_transient_state()
	_refresh_all()
	_switch_view(view_tap)
	core_input_locked = true
	p0_debug_panel.visible = true
	_refresh_p0_debug_status()

func _create_p0_recovery_fixture() -> void:
	var result := P0TestHarness.write_corrupt_primary_with_backup_fixture()
	p0_debug_status.text = str(result.get("message", "Recovery Fixture"))
	if bool(result.get("ok", false)):
		p0_debug_status.text += "\nApp jetzt komplett schließen und neu starten."

func _refresh_p0_debug_status() -> void:
	if not P0TestHarness.enabled:
		return
	var s := P0TestHarness.debug_snapshot()
	var boot := P0BootDiagnostics.snapshot()
	var boot_errors: Array = Array(boot.get("errors",[]))
	var boot_state := "PASS" if bool(boot.get("ok",false)) else "FAIL"
	if boot.is_empty():
		boot_state = "WAIT"
	p0_debug_status.text = "Monster %d · %s · HP %d/%d\nGold %d · Spins %d · Schild %d/3\nMine bereit %d · Contract Errors %d · Boot %s (%d)" % [
		int(s.get("monster_level",0)),
		str(s.get("monster_id","")),
		int(s.get("monster_hp",0)),
		int(s.get("monster_max_hp",0)),
		int(s.get("gold",0)),
		int(s.get("spins",0)),
		int(s.get("shields",0)),
		int(s.get("pending_goldmine",0)),
		Array(s.get("contract_errors",[])).size(),
		boot_state,
		boot_errors.size()
	]

func _setup_core_touch_feedback() -> void:
	var controls: Array[BaseButton] = [
		monster_button,
		home_wheel_cta,
		spin_button,
		btn_tap,
		btn_rad,
		btn_dorf,
		monster_reward_continue,
		wheel_reward_continue_p0,
		building_upgrade_button_p0,
		goldmine_claim_button_p0,
		settings_button_p0
	]
	for control in controls:
		_connect_once(control.button_down, func(): _set_touch_feedback(control, true))
		_connect_once(control.button_up, func(): _set_touch_feedback(control, false))

func _set_touch_feedback(control: CanvasItem, pressed: bool) -> void:
	if control == null:
		return
	control.modulate = Color(0.82,0.82,0.82,1.0) if pressed else Color.WHITE


func _refresh_first_session_flow() -> void:
	var encounter := PlayerData.monster_level
	var within_cycle := ((encounter - 1) % 10) + 1
	var is_first_cycle := encounter <= 10

	if is_first_cycle:
		if encounter == 1 and PlayerData.current_monster_hp == PlayerData.monster_max_hp:
			_show_first_session_hint("TIPPE AUF DAS MONSTER")
		elif encounter <= 3 and PlayerData.spins > 0:
			_show_first_session_hint("BESIEGE MONSTER · HOL DIR GOLD")
		elif encounter <= 6:
			_show_first_session_hint("NUTZE GOLD IM DORF · SPIN FÜR BONUS")
		else:
			first_session_hint_p0.visible = false
	else:
		first_session_hint_p0.visible = false

	var remaining := 10 - within_cycle
	if within_cycle == 10:
		boss_proximity_p0.text = "BOSS IST DA!"
	elif within_cycle >= 7:
		boss_proximity_p0.text = "BOSS IN %d" % remaining
	elif within_cycle == 5:
		boss_proximity_p0.text = "HALBZEIT · 5 / 10"
	else:
		boss_proximity_p0.text = ""

	_refresh_core_empty_states()

func _show_first_session_hint(text_value: String) -> void:
	if first_session_hint_stage > 0 and first_session_hint_p0.text == text_value:
		return
	first_session_hint_stage += 1
	first_session_hint_p0.text = text_value
	first_session_hint_p0.visible = true
	first_session_hint_p0.modulate.a = 1.0
	if SettingsService.reduced_motion:
		return
	if first_session_hint_tween and first_session_hint_tween.is_valid():
		first_session_hint_tween.kill()
	first_session_hint_tween = create_tween()
	first_session_hint_tween.tween_property(first_session_hint_p0,"modulate:a",0.72,0.35)
	first_session_hint_tween.tween_property(first_session_hint_p0,"modulate:a",1.0,0.35)

func _acknowledge_first_tap_hint() -> void:
	if PlayerData.monster_level == 1:
		first_session_hint_p0.visible = false

func _refresh_core_empty_states() -> void:
	spin_button.disabled = PlayerData.spins <= 0 or wheel_spinning or core_input_locked
	spin_button.text = "KEINE SPINS" if PlayerData.spins <= 0 else "SPIN · 1"
	spin_status_label.text = "%d SPINS VERFÜGBAR · 3 WALZEN" % PlayerData.spins

	var can_upgrade_any := false
	for building_id in ["townhall","goldmine","forge","lucktemple"]:
		if not P0VillageSystem.is_max(building_id) and PlayerData.gold >= P0VillageSystem.get_cost(building_id):
			can_upgrade_any = true
			break
	btn_dorf.tooltip_text = "Upgrade möglich" if can_upgrade_any else "Dorf"

	goldmine_claim_button_p0.text = "ABHOLEN" if P0VillageSystem.pending_goldmine_gold() > 0 else "PRODUZIERT"

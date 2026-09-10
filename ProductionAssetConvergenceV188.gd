extends RefCounted

const ProductionUiBinder = preload("res://ProductionUiBinder.gd")

static func apply(root: Node) -> Dictionary:
	var applied := 0
	var skipped := 0

	# HOME / TAP: use actual production UI language around existing monster/background.
	applied += _backdrop(root,"MonsterHP","ui.monster.hp.normal",0.12)
	applied += _backdrop(root,"HomeWheelCTA","ui.button.spin.primary",0.18,true)
	applied += _backdrop(root,"TapUpgradeButton","ui.button.primary",0.18,true)
	applied += _backdrop(root,"RewardLabel","ui.panel.small.parchment",0.12)

	# SPIN: preserve three-reel layout but remove generic native framing where production art exists.
	applied += _texture(root,"SpinMachineFrame","spin.machine.frame")
	applied += _texture(root,"Payline","spin.payline")
	applied += _backdrop(root,"SpinStatusPanel","ui.panel.info.dark",0.12,true)
	applied += _backdrop(root,"NoSpinsPanel","ui.panel.info.parchment",0.12,true)
	applied += _backdrop(root,"SpinButton","ui.button.spin.primary",0.18,true)

	# DORF: dedicated V153 art + proper production action surfaces.
	for pair in [
		["BuildingTownhall","ui.village.control.upgrade"],
		["BuildingGoldmine","ui.village.control.collect"],
		["BuildingForge","ui.village.control.build"],
		["BuildingLuck","ui.village.control.ready"],
		["VillageForgeActionV153","village.craft"],
		["VillageTempleActionV153","village.blessing"],
		["VillageProsperityClaimV153","village.reward"],
		["GoldmineClaimButtonP0","ui.village.control.collect"]
	]:
		applied += _backdrop(root,str(pair[0]),str(pair[1]),0.14,true)

	# MODI hub: existing high-confidence icons, no new navigation.
	applied += _button_icon(root,"HubJourneyP0","hub.journey")
	applied += _button_icon(root,"HubProgressionP0","hub.progression")
	applied += _button_icon(root,"HubDefenseP0","ui.icon.defense")
	applied += _button_icon(root,"HubLaneP0","ui.icon.attack")
	applied += _button_icon(root,"HubShopP0","ui.nav.currency")
	applied += _button_icon(root,"HubLiveOpsP0","hub.reward")
	applied += _button_icon(root,"HubMetaP0","ui.nav.ranking")
	applied += _backdrop(root,"FeatureHubOverlayP0","ui.featurehub.panel",0.10,true)
	applied += _backdrop(root,"FeatureHubStatusV154","hub.status",0.10)

	# QUEST / DAILY.
	applied += _backdrop(root,"QuestSummaryLabel","ui.quest.summary",0.10)
	applied += _backdrop(root,"DailyClaimButton","objective.daily",0.12,true)

	# SHOP.
	applied += _backdrop(root,"ShopStatusP0","ui.shop.featured",0.10)
	applied += _backdrop(root,"ShopCatalogP0","shop.card.production",0.10)
	applied += _backdrop(root,"ShopOverlayP0","ui.panel.tall.dark",0.10,true)

	# OFFLINE / AFK.
	applied += _backdrop(root,"AfkOverlayP0","afk.panel.production",0.10,true)
	applied += _backdrop(root,"AfkTextP0","ui.afk.summary",0.10)
	applied += _backdrop(root,"AfkClaimP0","ui.afk.claim",0.12,true)

	# PROGRESSION.
	applied += _backdrop(root,"ProgressionOverlayP0","ui.panel.tall.primary",0.10,true)
	applied += _backdrop(root,"ProgressionTextP0","progression.card.production",0.10)

	# LIVEOPS / RANKING.
	applied += _backdrop(root,"HalloweenStatusP0","liveops.halloween.banner",0.10)
	applied += _backdrop(root,"HalloweenQuestsP0","ui.panel.info.dark",0.10)
	applied += _backdrop(root,"HalloweenQuestClaimP0","ui.button.positive",0.14,true)
	applied += _backdrop(root,"RankingStatusP0","ranking.card.production",0.10)
	applied += _backdrop(root,"RankingRewardPreviewP0","ui.ranking.reward",0.10)
	for name in ["RankingDailyP0","RankingWeeklyP0","RankingEventP0"]:
		applied += _backdrop(root,name,"ui.ranking.tab",0.12,true)

	# HERO / equipment existing production assets.
	applied += _button_icon(root,"HeroWeaponButton","hero.weapon")
	applied += _button_icon(root,"HeroCharmButton","hero.charm")
	applied += _backdrop(root,"HeroSpecializationButtonP0","hero.specialization",0.12,true)
	applied += _backdrop(root,"HeroMasteryClaimP0","hero.reward",0.12,true)

	# REWARD / modal surfaces.
	applied += _backdrop(root,"MonsterRewardContinue","ui.button.reward",0.14,true)
	applied += _backdrop(root,"WheelRewardContinueP0","ui.button.reward",0.14,true)
	applied += _backdrop(root,"RewardModalClose","ui.modal.close",0.10,true)

	# Bottom navigation: exact existing V154 primary nav frame, then preserve four-button composition.
	var bottom := root.find_child("BottomMenu",true,false)
	if bottom is Control:
		if ProductionUiBinder.apply_backdrop(bottom as Control,"nav.primary.frame",false,0.08,false):
			applied += 1
		else:
			skipped += 1
	for pair in [["Btn_Tap","ui.icon.home"],["Btn_Rad","ui.icon.spin"],["Btn_Dorf","ui.icon.village"],["MoreFeaturesButtonP0","ui.icon.menu"]]:
		applied += _button_icon(root,str(pair[0]),str(pair[1]))

	return {"applied":applied,"skipped":skipped}

static func _backdrop(root: Node, node_name: String, role: String, patch := 0.14, clear_native := false) -> int:
	var node := root.find_child(node_name,true,false)
	if node is Control and ProductionUiBinder.apply_backdrop(node as Control,role,false,patch,clear_native):
		return 1
	return 0

static func _texture(root: Node, node_name: String, role: String) -> int:
	var node := root.find_child(node_name,true,false)
	if node is TextureRect and ProductionUiBinder.apply_texture(node as TextureRect,role,false):
		return 1
	return 0

static func _button_icon(root: Node, node_name: String, role: String) -> int:
	var node := root.find_child(node_name,true,false)
	var tex := ProductionAssetRegistry.bound_texture(role,false)
	if node is Button and tex != null:
		var button := node as Button
		button.icon = tex
		button.expand_icon = true
		ProductionUiBinder.set_icon_max_width(button, 64)
		return 1
	return 0

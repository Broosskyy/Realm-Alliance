extends RefCounted

const ProductionUiBinder = preload("res://ProductionUiBinder.gd")

const VERSION := "v1.63-screen-ui-assembly-01"

const OVERLAY_SPECS := {
	"FeatureHubOverlayP0": ["ui.featurehub.panel", "FeatureHubVBox", 18],
	"SettingsOverlayP0": ["ui.settings.panel", "SettingsVBox", 14],
	"AccountOverlayP0": ["ui.account.panel", "AccountVBox", 16],
	"SocialOverlayP0": ["ui.social.panel", "SocialVBox", 16],
	"SupportOverlayP0": ["ui.support.panel", "SupportVBox", 14],
	"LiveOpsOverlayP0": ["ui.liveops.panel", "LiveOpsVBox", 14],
	"ShopOverlayP0": ["ui.panel.tall.dark", "ShopVBox", 16],
	"ProgressionOverlayP0": ["ui.panel.tall.primary", "ProgressionVBox", 16],
	"AfkOverlayP0": ["ui.panel.tall.dark", "AfkVBox", 16],
	"RewardModal": ["ui.reward.panel", "", 12],
	"MonsterRewardOverlay": ["ui.reward.panel", "", 12],
	"BuildingUpgradeOverlayP0": ["ui.upgrade.panel", "", 12],
	"LevelUpOverlayP0": ["ui.reward.panel", "", 12]
}

const FEATURE_HUB_ICONS := {
	"HubHeroesP0": "ui.nav.inventory",
	"HubJourneyP0": "ui.nav.quest",
	"HubPuzzleP0": "ui.quest.icon.main_quest",
	"HubDefenseP0": "ui.icon.defense",
	"HubLaneP0": "ui.icon.attack",
	"HubMetaP0": "ui.nav.ranking",
	"HubProfileP0": "ui.nav.home",
	"HubShopP0": "ui.nav.currency",
	"HubLiveOpsP0": "ui.quest.icon.quest_alert",
	"HubProgressionP0": "ui.progression.level_badge"
}

static func apply(root: Control) -> Dictionary:
	if root == null:
		return {"applied": 0}
	var applied := 0
	applied += _style_overlays(root)
	applied += _style_feature_hub(root)
	applied += _style_quest(root)
	applied += _style_core_secondary_panels(root)
	applied += _assemble_shop(root)
	applied += _assemble_afk(root)
	applied += _assemble_progression(root)
	applied += _assemble_liveops_and_ranking(root)
	applied += _assemble_account_social_support(root)
	applied += _assemble_heroes(root)
	applied += _assemble_lane_battle(root)
	applied += _assemble_tower_defense(root)
	applied += _assemble_journey(root)
	applied += _assemble_puzzle(root)
	applied += _assemble_home_tap(root)
	applied += _assemble_village_core(root)
	applied += _assemble_reward_session_flow(root)
	_style_top_bar(root)
	set_primary_nav_state(root, _active_core_view(root))
	return {"applied": applied}

static func _style_top_bar(root: Control) -> void:
	var top := root.find_child("TopBar", true, false) as HBoxContainer
	if top:
		top.add_theme_constant_override("separation", 12)
	for name in ["GoldPillP0", "SpinPillP0", "ShieldPillP0"]:
		var pill := root.find_child(name, true, false) as Control
		if pill:
			pill.custom_minimum_size.y = maxf(pill.custom_minimum_size.y, 84.0)
	for name in ["GoldLabel", "SpinsLabel", "ShieldsLabel"]:
		var label := root.find_child(name, true, false) as Label
		if label:
			label.add_theme_font_size_override("font_size", maxi(label.get_theme_font_size("font_size"), 27))
	var settings := root.find_child("SettingsButtonP0", true, false) as Button
	if settings:
		settings.custom_minimum_size = Vector2(88, 88)
		ProductionUiBinder.set_icon_max_width(settings, 54)

static func _style_overlays(root: Control) -> int:
	var count := 0
	for node_name in OVERLAY_SPECS.keys():
		var overlay := root.find_child(node_name, true, false) as Control
		if overlay == null:
			continue
		var spec: Array = OVERLAY_SPECS[node_name]
		if ProductionUiBinder.apply_backdrop(overlay, str(spec[0]), false, 0.14, overlay is PanelContainer):
			count += 1
		overlay.custom_minimum_size.x = maxf(overlay.custom_minimum_size.x, 580.0)
		var box_name := str(spec[1])
		if not box_name.is_empty():
			var box := overlay.find_child(box_name, true, false) as VBoxContainer
			if box:
				box.add_theme_constant_override("separation", int(spec[2]))
				_style_scoped_title(box)
				_style_scoped_labels(box)
	return count

static func _style_scoped_title(scope: Node) -> void:
	var title: Label = null
	for candidate in ["Title", "ShopTitleP0", "ProgressionTitleP0", "AfkTitleP0", "SettingsTitleP0", "LiveOpsTitleP0"]:
		var found := scope.find_child(candidate, true, false) as Label
		if found:
			title = found
			break
	if title == null:
		return
	title.custom_minimum_size.y = maxf(title.custom_minimum_size.y, 68.0)
	title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	title.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	title.add_theme_font_size_override("font_size", maxi(title.get_theme_font_size("font_size"), 28))
	ProductionUiBinder.apply_backdrop(title, "ui.panel.banner", false, 0.16)

static func _style_scoped_labels(scope: Node) -> void:
	for child in scope.find_children("*", "Label", true, false):
		var label := child as Label
		if label == null:
			continue
		label.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if label.get_theme_font_size("font_size") < 18:
			label.add_theme_font_size_override("font_size", 18)

static func _style_feature_hub(root: Control) -> int:
	var count := 0
	var overlay := root.find_child("FeatureHubOverlayP0", true, false)
	if overlay == null:
		return count
	var grid := overlay.find_child("FeatureHubGrid", true, false) as GridContainer
	if grid:
		grid.columns = 2
		grid.add_theme_constant_override("h_separation", 14)
		grid.add_theme_constant_override("v_separation", 14)
	for node_name in FEATURE_HUB_ICONS.keys():
		var button := overlay.find_child(node_name, true, false) as Button
		if button == null:
			continue
		button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, 100.0)
		button.add_theme_font_size_override("font_size", maxi(button.get_theme_font_size("font_size"), 19))
		ProductionUiBinder.apply_backdrop(button, "ui.button.secondary", false, 0.18, true)
		var tex := SemanticAssetRegistry.texture_for_role(str(FEATURE_HUB_ICONS[node_name]), true)
		if tex != null:
			button.icon = tex
			button.expand_icon = true
			ProductionUiBinder.set_icon_max_width(button, 46)
		count += 1
	return count

static func _style_quest(root: Control) -> int:
	var count := 0
	var view := root.find_child("View_Quests", true, false)
	if view == null:
		return count
	var title := view.find_child("QuestTitle", true, false) as Label
	if title:
		title.custom_minimum_size.y = maxf(title.custom_minimum_size.y, 72.0)
		title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		title.add_theme_font_size_override("font_size", maxi(title.get_theme_font_size("font_size"), 30))
		if ProductionUiBinder.apply_backdrop(title, "ui.quest.header", false, 0.12):
			count += 1
	var summary := view.find_child("QuestSummaryLabel", true, false) as Label
	if summary:
		summary.custom_minimum_size.y = maxf(summary.custom_minimum_size.y, 92.0)
		summary.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		if ProductionUiBinder.apply_backdrop(summary, "ui.quest.summary", false, 0.14):
			count += 1
	var list := view.find_child("QuestList", true, false) as VBoxContainer
	if list:
		list.add_theme_constant_override("separation", 14)
	return count

static func _style_core_secondary_panels(root: Control) -> int:
	var count := 0
	var panel_roles := {
		"EventPanel": "ui.panel.info.dark",
		"RankingPanel": "ui.panel.info.dark",
		"RealmChestPanel": "ui.panel.info.parchment",
		"TreasurePortalPanel": "ui.panel.info.dark",
		"NoSpinsPanel": "ui.panel.info.dark"
	}
	for node_name in panel_roles.keys():
		var panel := root.find_child(node_name, true, false) as Control
		if panel and ProductionUiBinder.apply_backdrop(panel, str(panel_roles[node_name]), false, 0.14, panel is PanelContainer):
			count += 1
	return count

static func style_objective_header(label: Label, category: String) -> void:
	if label == null:
		return
	label.custom_minimum_size.y = maxf(label.custom_minimum_size.y, 56.0)
	label.horizontal_alignment = HORIZONTAL_ALIGNMENT_LEFT
	label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	label.add_theme_font_size_override("font_size", 21)
	var role := "ui.panel.banner"
	if category == "achievements":
		role = "ui.panel.info.parchment"
	ProductionUiBinder.apply_backdrop(label, role, false, 0.16)

static func objective_icon_role(row: Dictionary) -> String:
	if bool(row.get("claimed", false)):
		return "ui.quest.icon.complete"
	if bool(row.get("ready", false)):
		return "ui.quest.icon.claim"
	if int(row.get("value", 0)) > 0:
		return "ui.quest.icon.in_progress"
	return "ui.quest.icon.main_quest"

static func configure_objective_action(button: Button, row: Dictionary) -> void:
	if button == null:
		return
	var role := "ui.button.secondary"
	if bool(row.get("ready", false)):
		role = "ui.button.positive"
	elif bool(row.get("claimed", false)):
		role = "ui.button.neutral"
	ProductionUiBinder.apply_backdrop(button, role, false, 0.18, true)

static func set_primary_nav_state(root: Control, active_view: Control) -> void:
	var mapping := {
		"Btn_Tap": "View_TapHero",
		"Btn_Rad": "View_CoinMaster",
		"Btn_Dorf": "View_ClashDorf"
	}
	var active_name := active_view.name if active_view != null else ""
	for button_name in mapping.keys():
		var button := root.find_child(button_name, true, false) as Button
		if button == null:
			continue
		var active := active_name == str(mapping[button_name])
		ProductionUiBinder.apply_backdrop(button, "ui.button.primary" if active else "ui.button.secondary", false, 0.18, true)
	var more := root.find_child("MoreFeaturesButtonP0", true, false) as Button
	if more:
		ProductionUiBinder.apply_backdrop(more, "ui.button.secondary", false, 0.18, true)


static func _make_texture(role: String, minimum: Vector2, allow_medium := false) -> TextureRect:
	var rect := TextureRect.new()
	rect.custom_minimum_size = minimum
	rect.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
	rect.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	rect.mouse_filter = Control.MOUSE_FILTER_IGNORE
	rect.texture = SemanticAssetRegistry.texture_for_role(role, allow_medium)
	return rect

static func _assemble_shop(root: Control) -> int:
	var overlay := root.find_child("ShopOverlayP0", true, false)
	if overlay == null:
		return 0
	var box := overlay.find_child("ShopVBox", true, false) as VBoxContainer
	if box == null:
		return 0
	var existing := box.find_child("ShopVisualStripV164", false, false)
	if existing == null:
		var strip := HBoxContainer.new()
		strip.name = "ShopVisualStripV164"
		strip.custom_minimum_size = Vector2(0, 180)
		strip.add_theme_constant_override("separation", 12)
		strip.alignment = BoxContainer.ALIGNMENT_CENTER
		for role in ["ui.shop.item.standard", "ui.shop.item.premium", "ui.shop.item.limited"]:
			var card := _make_texture(role, Vector2(170, 170), role == "ui.shop.item.standard")
			card.name = "ShopCardV168_%d" % strip.get_child_count()
			card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			strip.add_child(card)
		box.add_child(strip)
		var catalog := box.find_child("ShopCatalogP0", false, false)
		if catalog:
			box.move_child(strip, catalog.get_index())
	var status := box.find_child("ShopStatusP0", false, false) as Label
	if status:
		status.custom_minimum_size.y = maxf(status.custom_minimum_size.y, 72.0)
		ProductionUiBinder.apply_backdrop(status, "ui.shop.featured", false, 0.12)
	var catalog_label := box.find_child("ShopCatalogP0", false, false) as Label
	if catalog_label:
		catalog_label.custom_minimum_size.y = 430.0
		ProductionUiBinder.apply_backdrop(catalog_label, "ui.panel.info.dark", false, 0.14)
	var close := box.find_child("ShopCloseP0", false, false) as Button
	if close:
		ProductionUiBinder.apply_backdrop(close, "ui.button.secondary", false, 0.18, true)
	return 4

static func _assemble_afk(root: Control) -> int:
	var overlay := root.find_child("AfkOverlayP0", true, false)
	if overlay == null:
		return 0
	var box := overlay.find_child("AfkVBox", true, false) as VBoxContainer
	if box == null:
		return 0
	var text := box.find_child("AfkTextP0", false, false) as Label
	if text:
		text.custom_minimum_size.y = 180.0
		ProductionUiBinder.apply_backdrop(text, "ui.afk.summary", false, 0.12)
	var existing := box.find_child("AfkRewardVisualRowV164", false, false)
	if existing == null:
		var row := HBoxContainer.new()
		row.name = "AfkRewardVisualRowV164"
		row.custom_minimum_size = Vector2(0, 150)
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 28)
		for role in ["ui.afk.reward.standard", "ui.afk.reward.bonus"]:
			var slot := _make_texture(role, Vector2(210, 145))
			slot.name = "AfkRewardSlotV168_%d" % row.get_child_count()
			slot.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(slot)
		box.add_child(row)
		var claim := box.find_child("AfkClaimP0", false, false)
		if claim:
			box.move_child(row, claim.get_index())
	var claim_button := box.find_child("AfkClaimP0", false, false) as Button
	if claim_button:
		claim_button.custom_minimum_size.y = maxf(claim_button.custom_minimum_size.y, 110.0)
		ProductionUiBinder.apply_backdrop(claim_button, "ui.afk.claim", false, 0.16, true)
	return 3

static func _assemble_progression(root: Control) -> int:
	var overlay := root.find_child("ProgressionOverlayP0", true, false)
	if overlay == null:
		return 0
	var box := overlay.find_child("ProgressionVBox", true, false) as VBoxContainer
	if box == null:
		return 0
	var text := box.find_child("ProgressionTextP0", false, false) as Label
	if text:
		text.custom_minimum_size.y = 450.0
		ProductionUiBinder.apply_backdrop(text, "ui.progression.overview", false, 0.12)
	var existing := box.find_child("ProgressionVisualV164", false, false)
	if existing == null:
		var visual := VBoxContainer.new()
		visual.name = "ProgressionVisualV164"
		visual.custom_minimum_size = Vector2(0, 280)
		visual.add_theme_constant_override("separation", 10)

		var top := HBoxContainer.new()
		top.alignment = BoxContainer.ALIGNMENT_CENTER
		top.add_theme_constant_override("separation", 16)
		top.add_child(_make_texture("ui.progression.level_badge", Vector2(110, 110)))
		var progress := _make_texture("ui.progression.progress_bar", Vector2(470, 90), true)
		progress.name = "ProgressionBarArtV168"
		progress.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		top.add_child(progress)
		visual.add_child(top)

		var nodes := HBoxContainer.new()
		nodes.alignment = BoxContainer.ALIGNMENT_CENTER
		nodes.add_theme_constant_override("separation", 10)
		for role in ["ui.progression.node.standard", "ui.progression.node.locked", "ui.progression.node.available", "ui.progression.node.completed"]:
			var node_tex := _make_texture(role, Vector2(135, 135))
			node_tex.name = "ProgressionNodeV168_%d" % nodes.get_child_count()
			node_tex.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			nodes.add_child(node_tex)
		visual.add_child(nodes)

		box.add_child(visual)
		if text:
			box.move_child(visual, text.get_index() + 1)
	var close := box.find_child("ProgressionCloseP0", false, false) as Button
	if close:
		ProductionUiBinder.apply_backdrop(close, "ui.button.secondary", false, 0.18, true)
	return 4


static func _assign_button_icon(button: Button, role: String, width := 42) -> void:
	if button == null:
		return
	var tex := SemanticAssetRegistry.texture_for_role(role, false)
	if tex == null:
		return
	button.icon = tex
	button.expand_icon = true
	ProductionUiBinder.set_icon_max_width(button, width)

static func _assemble_liveops_and_ranking(root: Control) -> int:
	var overlay := root.find_child("LiveOpsOverlayP0", true, false)
	if overlay == null:
		return 0
	var box := overlay.find_child("LiveOpsVBox", true, false) as VBoxContainer
	if box == null:
		return 0
	var applied := 0

	var event_status := box.find_child("HalloweenStatusP0", false, false) as Label
	if event_status:
		event_status.custom_minimum_size.y = maxf(event_status.custom_minimum_size.y, 62.0)
		ProductionUiBinder.apply_backdrop(event_status, "ui.panel.info.dark", false, 0.14)
		applied += 1

	var event_progress := box.find_child("HalloweenProgressP0", false, false) as Label
	if event_progress:
		ProductionUiBinder.apply_backdrop(event_progress, "ui.panel.banner", false, 0.14)
		applied += 1

	for name in ["HalloweenClaimP0", "HalloweenQuestClaimP0", "HalloweenChestP0"]:
		var button := box.find_child(name, true, false) as Button
		if button:
			ProductionUiBinder.apply_backdrop(button, "ui.button.reward" if name != "HalloweenQuestClaimP0" else "ui.button.positive", false, 0.18, true)
			_assign_button_icon(button, "ui.quest.icon.claim" if name != "HalloweenChestP0" else "ui.nav.currency", 42)
			applied += 1

	var tabs := box.find_child("RankingTabsP0", false, false) as HBoxContainer
	if tabs:
		tabs.add_theme_constant_override("separation", 10)
		for name in ["RankingDailyP0", "RankingWeeklyP0", "RankingEventP0"]:
			var tab := tabs.find_child(name, false, false) as Button
			if tab:
				ProductionUiBinder.apply_backdrop(tab, "ui.ranking.tab", false, 0.15, true)
				tab.custom_minimum_size.y = maxf(tab.custom_minimum_size.y, 72.0)
				applied += 1

	var ranking_status := box.find_child("RankingStatusP0", false, false) as Label
	if ranking_status:
		ranking_status.custom_minimum_size.y = maxf(ranking_status.custom_minimum_size.y, 150.0)
		ProductionUiBinder.apply_backdrop(ranking_status, "ui.ranking.header", false, 0.12)
		applied += 1

	var medals := box.find_child("RankingMedalsV165", false, false)
	if medals == null:
		var medal_row := HBoxContainer.new()
		medal_row.name = "RankingMedalsV165"
		medal_row.custom_minimum_size = Vector2(0, 105)
		medal_row.alignment = BoxContainer.ALIGNMENT_CENTER
		medal_row.add_theme_constant_override("separation", 22)
		for role in ["ui.ranking.badge.first", "ui.ranking.badge.second", "ui.ranking.badge.third"]:
			var badge := _make_texture(role, Vector2(100, 100))
			badge.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			medal_row.add_child(badge)
		box.add_child(medal_row)
		var reward_preview := box.find_child("RankingRewardPreviewP0", false, false)
		if reward_preview:
			box.move_child(medal_row, reward_preview.get_index())
		applied += 1

	var reward_preview_label := box.find_child("RankingRewardPreviewP0", false, false) as Label
	if reward_preview_label:
		ProductionUiBinder.apply_backdrop(reward_preview_label, "ui.ranking.reward", false, 0.14)
		applied += 1

	var ranking_claim := box.find_child("RankingClaimP0", false, false) as Button
	if ranking_claim:
		ProductionUiBinder.apply_backdrop(ranking_claim, "ui.button.reward", false, 0.18, true)
		_assign_button_icon(ranking_claim, "ui.ranking.reward", 44)
		applied += 1

	return applied

static func _assemble_account_social_support(root: Control) -> int:
	var applied := 0
	var account := root.find_child("AccountOverlayP0", true, false)
	if account:
		var box := account.find_child("AccountVBox", true, false) as VBoxContainer
		if box:
			for name in ["AccountStatusP0", "AccountProgressP0", "CloudStatusP0", "AccountMessageP0"]:
				var label := box.find_child(name, false, false) as Label
				if label:
					ProductionUiBinder.apply_backdrop(label, "ui.panel.info.dark", false, 0.13)
					label.custom_minimum_size.y = maxf(label.custom_minimum_size.y, 58.0)
					applied += 1
			var link := box.find_child("LinkGuestP0", false, false) as Button
			if link:
				ProductionUiBinder.apply_backdrop(link, "ui.button.positive", false, 0.18, true)
				_assign_button_icon(link, "ui.utility.confirm", 42)
				applied += 1
			var social := box.find_child("SocialHubButtonP0", false, false) as Button
			if social:
				ProductionUiBinder.apply_backdrop(social, "ui.button.secondary", false, 0.18, true)
				_assign_button_icon(social, "ui.nav.home", 42)
				applied += 1
			var cloud := box.find_child("CloudInfoP0", false, false) as Button
			if cloud:
				ProductionUiBinder.apply_backdrop(cloud, "ui.button.secondary", false, 0.18, true)
				_assign_button_icon(cloud, "ui.utility.info", 42)
				applied += 1

	var social_overlay := root.find_child("SocialOverlayP0", true, false)
	if social_overlay:
		var sbox := social_overlay.find_child("SocialVBox", true, false) as VBoxContainer
		if sbox:
			for name in ["SocialProfileP0", "SocialStatsP0"]:
				var label := sbox.find_child(name, false, false) as Label
				if label:
					ProductionUiBinder.apply_backdrop(label, "ui.panel.info.dark", false, 0.13)
					label.custom_minimum_size.y = maxf(label.custom_minimum_size.y, 56.0)
					applied += 1
			var tabs := sbox.find_child("SocialTabsP0", false, false) as HBoxContainer
			if tabs:
				for name in ["SocialInboxP0", "SocialAchievementsP0", "SocialFriendsP0"]:
					var tab := tabs.find_child(name, false, false) as Button
					if tab:
						ProductionUiBinder.apply_backdrop(tab, "ui.button.secondary", false, 0.15, true)
						_assign_button_icon(tab, "ui.nav.quest" if name == "SocialInboxP0" else ("ui.ranking.badge.first" if name == "SocialAchievementsP0" else "ui.nav.home"), 36)
						applied += 1
			var content := sbox.find_child("SocialContentP0", false, false) as Label
			if content:
				ProductionUiBinder.apply_backdrop(content, "ui.panel.tall.dark", false, 0.13)
				content.custom_minimum_size.y = 500.0
				applied += 1
			var action := sbox.find_child("SocialActionP0", false, false) as Button
			if action:
				ProductionUiBinder.apply_backdrop(action, "ui.button.positive", false, 0.18, true)
				_assign_button_icon(action, "ui.utility.confirm", 40)
				applied += 1

	var support := root.find_child("SupportOverlayP0", true, false)
	if support:
		var bbox := support.find_child("SupportVBox", true, false) as VBoxContainer
		if bbox:
			var intro := bbox.find_child("SupportTextP0", false, false) as Label
			if intro:
				ProductionUiBinder.apply_backdrop(intro, "ui.panel.info.parchment", false, 0.13)
				intro.custom_minimum_size.y = maxf(intro.custom_minimum_size.y, 100.0)
				applied += 1
			var support_roles := {
				"SupportHelpP0": "ui.utility.info",
				"SupportPrivacyP0": "ui.utility.info",
				"SupportTermsP0": "ui.utility.info",
				"SupportImprintP0": "ui.utility.info"
			}
			for name in support_roles.keys():
				var button := bbox.find_child(name, false, false) as Button
				if button:
					ProductionUiBinder.apply_backdrop(button, "ui.button.secondary", false, 0.18, true)
					_assign_button_icon(button, str(support_roles[name]), 40)
					applied += 1
			var status := bbox.find_child("SupportStatusP0", false, false) as Label
			if status:
				ProductionUiBinder.apply_backdrop(status, "ui.panel.info.dark", false, 0.13)
				applied += 1
	return applied

static func _assemble_heroes(root: Control) -> int:
	var view := root.find_child("View_Heroes", true, false)
	if view == null:
		return 0
	var applied := 0

	var title := view.find_child("HeroTitle", true, false) as Label
	if title:
		ProductionUiBinder.apply_backdrop(title, "ui.hero.panel", false, 0.12)
		title.add_theme_font_size_override("font_size", maxi(title.get_theme_font_size("font_size"), 34))
		applied += 1

	var cards := view.find_child("HeroCards", true, false) as HBoxContainer
	if cards:
		cards.add_theme_constant_override("separation", 12)
		for name in ["HeroKnight", "HeroArcher", "HeroMage"]:
			var button := cards.find_child(name, false, false) as Button
			if button:
				button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, 260.0)
				ProductionUiBinder.apply_backdrop(button, "ui.slot.rarity.2", false, 0.12, true)
				applied += 1

	var mastery_label := view.find_child("HeroMasteryLabelP0", true, false) as Label
	if mastery_label:
		ProductionUiBinder.apply_backdrop(mastery_label, "ui.panel.banner", false, 0.13)
		applied += 1

	var spec := view.find_child("HeroSpecializationButtonP0", true, false) as Button
	if spec:
		ProductionUiBinder.apply_backdrop(spec, "ui.button.secondary", false, 0.18, true)
		_assign_button_icon(spec, "ui.utility.info", 40)
		applied += 1

	var reward := view.find_child("HeroMasteryClaimP0", true, false) as Button
	if reward:
		ProductionUiBinder.apply_backdrop(reward, "ui.button.reward", false, 0.18, true)
		_assign_button_icon(reward, "ui.quest.icon.claim", 42)
		applied += 1

	var hint := view.find_child("HeroEquipmentHint", true, false) as Label
	if hint:
		ProductionUiBinder.apply_backdrop(hint, "ui.panel.banner", false, 0.13)
		applied += 1

	var weapon := view.find_child("HeroWeaponButton", true, false) as Button
	if weapon:
		ProductionUiBinder.apply_backdrop(weapon, "ui.button.secondary", false, 0.18, true)
		_assign_button_icon(weapon, "ui.inventory.equipment.sword", 52)
		applied += 1

	var charm := view.find_child("HeroCharmButton", true, false) as Button
	if charm:
		ProductionUiBinder.apply_backdrop(charm, "ui.button.secondary", false, 0.18, true)
		_assign_button_icon(charm, "ui.inventory.equipment.pendant", 52)
		applied += 1

	var upgrade := view.find_child("HeroUpgradeButtonP0", true, false) as Button
	if upgrade:
		ProductionUiBinder.apply_backdrop(upgrade, "ui.button.primary", false, 0.18, true)
		_assign_button_icon(upgrade, "ui.nav.inventory", 44)
		applied += 1

	var equip_strip := view.find_child("HeroEquipmentPreviewV165", false, false)
	if equip_strip == null:
		var strip := HBoxContainer.new()
		strip.name = "HeroEquipmentPreviewV165"
		strip.anchor_left = 0.08
		strip.anchor_right = 0.92
		strip.anchor_top = 1.0
		strip.anchor_bottom = 1.0
		strip.offset_top = -390.0
		strip.offset_bottom = -335.0
		strip.grow_horizontal = Control.GROW_DIRECTION_BOTH
		strip.add_theme_constant_override("separation", 8)
		strip.alignment = BoxContainer.ALIGNMENT_CENTER
		for role in ["ui.inventory.equipment.sword", "ui.inventory.equipment.shield", "ui.inventory.equipment.armor", "ui.inventory.equipment.helmet", "ui.inventory.equipment.ring", "ui.inventory.equipment.pendant"]:
			var icon := _make_texture(role, Vector2(70, 70))
			icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			strip.add_child(icon)
		view.add_child(strip)
		applied += 1
	return applied


static func _assemble_lane_battle(root: Control) -> int:
	var view := root.find_child("View_LaneAttack", true, false)
	if view == null:
		return 0
	var applied := 0
	var hud := view.find_child("LaneHUD", true, false) as VBoxContainer
	if hud:
		hud.add_theme_constant_override("separation", 8)
		var title := hud.find_child("LaneTitle", false, false) as Label
		if title:
			ProductionUiBinder.apply_backdrop(title, "ui.panel.banner", false, 0.13)
			applied += 1
		for name in ["LaneTimer", "EnergyLabel", "LaneStageLabelP0", "LaneMasteryLabelP0"]:
			var label := hud.find_child(name, false, false) as Label
			if label:
				ProductionUiBinder.apply_backdrop(label, "ui.panel.info.dark", false, 0.12)
				label.custom_minimum_size.y = maxf(label.custom_minimum_size.y, 52.0)
				applied += 1

	var action_map := {
		"LaneLeftButton": "ui.combat.attack",
		"LaneRightButton": "ui.combat.heavy_attack",
		"LaneTechButtonP0": "ui.combat.speed",
		"LaneMasteryClaimP0": "ui.quest.icon.claim",
		"LaneNextBattleP0": "ui.combat.target"
	}
	for name in action_map.keys():
		var button := view.find_child(name, true, false) as Button
		if button:
			var role := "ui.button.secondary"
			if name in ["LaneLeftButton", "LaneRightButton", "LaneNextBattleP0"]:
				role = "ui.button.primary"
			elif name == "LaneMasteryClaimP0":
				role = "ui.button.reward"
			ProductionUiBinder.apply_backdrop(button, role, false, 0.18, true)
			_assign_button_icon(button, str(action_map[name]), 46)
			applied += 1

	var strip := view.find_child("LaneCombatActionsV166", false, false)
	if strip == null:
		var row := HBoxContainer.new()
		row.name = "LaneCombatActionsV166"
		row.anchor_left = 0.14
		row.anchor_right = 0.86
		row.anchor_top = 1.0
		row.anchor_bottom = 1.0
		row.offset_top = -430.0
		row.offset_bottom = -360.0
		row.grow_horizontal = Control.GROW_DIRECTION_BOTH
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 12)
		for role in ["ui.combat.attack", "ui.combat.heavy_attack", "ui.combat.speed", "ui.combat.target"]:
			var icon := _make_texture(role, Vector2(72, 72))
			icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(icon)
		view.add_child(row)
		applied += 1
	return applied

static func _assemble_tower_defense(root: Control) -> int:
	var view := root.find_child("View_TowerDefense", true, false)
	if view == null:
		return 0
	var applied := 0
	var hud := view.find_child("TDHUD", true, false) as VBoxContainer
	if hud:
		hud.add_theme_constant_override("separation", 8)
		var title := hud.find_child("TDTitle", false, false) as Label
		if title:
			ProductionUiBinder.apply_backdrop(title, "ui.panel.banner", false, 0.13)
			applied += 1
		for name in ["TDTimer", "TDWaveLabel", "TDStageLabelP0", "TDMasteryLabelP0"]:
			var label := hud.find_child(name, false, false) as Label
			if label:
				ProductionUiBinder.apply_backdrop(label, "ui.panel.info.dark", false, 0.12)
				label.custom_minimum_size.y = maxf(label.custom_minimum_size.y, 50.0)
				applied += 1

	for name in ["TDTowerStatusP0", "TDEnergyLabel"]:
		var label := view.find_child(name, true, false) as Label
		if label:
			ProductionUiBinder.apply_backdrop(label, "ui.panel.info.dark", false, 0.12)
			applied += 1

	var button_roles := {
		"TDUpgradeButton": ["ui.button.primary", "ui.combat.defense"],
		"TDTechButtonP0": ["ui.button.secondary", "ui.combat.speed"],
		"TDMasteryClaimP0": ["ui.button.reward", "ui.quest.icon.claim"],
		"TDFightButtonP0": ["ui.button.primary", "ui.combat.target"]
	}
	for name in button_roles.keys():
		var button := view.find_child(name, true, false) as Button
		if button:
			var spec: Array = button_roles[name]
			ProductionUiBinder.apply_backdrop(button, str(spec[0]), false, 0.18, true)
			_assign_button_icon(button, str(spec[1]), 46)
			applied += 1

	var status_strip := view.find_child("TDStatusPreviewV166", false, false)
	if status_strip == null:
		var row := HBoxContainer.new()
		row.name = "TDStatusPreviewV166"
		row.anchor_left = 0.18
		row.anchor_right = 0.82
		row.anchor_top = 1.0
		row.anchor_bottom = 1.0
		row.offset_top = -600.0
		row.offset_bottom = -545.0
		row.grow_horizontal = Control.GROW_DIRECTION_BOTH
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 8)
		for role in ["ui.status.defense_up", "ui.status.attack_up", "ui.status.freeze", "ui.status.stun"]:
			var icon := _make_texture(role, Vector2(58, 58))
			icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(icon)
		view.add_child(row)
		applied += 1
	return applied

static func _assemble_journey(root: Control) -> int:
	var view := root.find_child("View_RealmJourney", true, false)
	if view == null:
		return 0
	var applied := 0
	var title := view.find_child("JourneyTitle", true, false) as Label
	if title:
		ProductionUiBinder.apply_backdrop(title, "ui.panel.banner", false, 0.13)
		applied += 1
	var subline := view.find_child("JourneySubline", true, false) as Label
	if subline:
		ProductionUiBinder.apply_backdrop(subline, "ui.panel.info.dark", false, 0.12)
		applied += 1
	var board := view.find_child("JourneyBoard", true, false) as Control
	if board:
		ProductionUiBinder.apply_backdrop(board, "ui.panel.tall.primary", false, 0.13, board is PanelContainer)
		applied += 1
	var box := view.find_child("JourneyBoardVBox", true, false) as VBoxContainer
	if box:
		for name in ["JourneyProgressLabel", "JourneyDiceLabel", "JourneyNodeDetailP0", "JourneyMasteryLabel"]:
			var label := box.find_child(name, false, false) as Label
			if label:
				ProductionUiBinder.apply_backdrop(label, "ui.panel.info.dark", false, 0.12)
				applied += 1
		var mastery_claim := box.find_child("JourneyMasteryClaimP0", false, false) as Button
		if mastery_claim:
			ProductionUiBinder.apply_backdrop(mastery_claim, "ui.button.reward", false, 0.18, true)
			_assign_button_icon(mastery_claim, "ui.quest.icon.claim", 42)
			applied += 1
		var cache := box.find_child("JourneyCacheP0", false, false) as Button
		if cache:
			ProductionUiBinder.apply_backdrop(cache, "ui.button.secondary", false, 0.18, true)
			_assign_button_icon(cache, "ui.nav.currency", 42)
			applied += 1

	var roll := view.find_child("DiceRollButton", true, false) as Button
	if roll:
		ProductionUiBinder.apply_backdrop(roll, "ui.button.primary", false, 0.18, true)
		_assign_button_icon(roll, "ui.quest.icon.main_quest", 44)
		applied += 1

	var result := view.find_child("DiceResultLabel", true, false) as Label
	if result:
		ProductionUiBinder.apply_backdrop(result, "ui.reward.panel", false, 0.13)
		applied += 1

	var portal := view.find_child("TreasurePortalPanel", true, false) as Control
	if portal:
		ProductionUiBinder.apply_backdrop(portal, "ui.panel.info.parchment", false, 0.13, portal is PanelContainer)
		applied += 1

	var nodes_strip := view.find_child("JourneyNodeVisualV166", false, false)
	if nodes_strip == null:
		var row := HBoxContainer.new()
		row.name = "JourneyNodeVisualV166"
		row.anchor_left = 0.18
		row.anchor_right = 0.82
		row.anchor_top = 0.53
		row.anchor_bottom = 0.53
		row.offset_top = -60.0
		row.offset_bottom = 60.0
		row.grow_horizontal = Control.GROW_DIRECTION_BOTH
		row.alignment = BoxContainer.ALIGNMENT_CENTER
		row.add_theme_constant_override("separation", 10)
		for role in ["ui.progression.node.completed", "ui.progression.node.available", "ui.progression.node.standard", "ui.progression.node.locked"]:
			var icon := _make_texture(role, Vector2(100, 100))
			icon.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			row.add_child(icon)
		view.add_child(row)
		applied += 1
	return applied

static func _assemble_puzzle(root: Control) -> int:
	var view := root.find_child("View_Puzzle", true, false)
	if view == null:
		return 0
	var applied := 0
	for name in ["PuzzleTitle", "PuzzleStatusLabel", "PuzzleStageLabelP0", "PuzzleMasteryLabelP0", "PuzzleHintLabel"]:
		var label := view.find_child(name, true, false) as Label
		if label:
			ProductionUiBinder.apply_backdrop(label, "ui.panel.banner" if name == "PuzzleTitle" else "ui.panel.info.dark", false, 0.12)
			applied += 1

	var panel := view.find_child("PuzzlePanel", true, false) as Control
	if panel:
		ProductionUiBinder.apply_backdrop(panel, "ui.panel.wood", false, 0.13, panel is PanelContainer)
		applied += 1

	var grid := view.find_child("PuzzleGrid", true, false) as GridContainer
	if grid:
		grid.add_theme_constant_override("h_separation", 14)
		grid.add_theme_constant_override("v_separation", 14)
		for i in range(9):
			var cell := grid.find_child("PuzzleCell%d" % i, false, false) as Button
			if cell:
				cell.custom_minimum_size = Vector2(190, 150)
				ProductionUiBinder.apply_backdrop(cell, "ui.frame.slot.%d" % ((i % 9) + 1), false, 0.10, true)
				applied += 1

	var claim := view.find_child("PuzzleMasteryClaimP0", true, false) as Button
	if claim:
		ProductionUiBinder.apply_backdrop(claim, "ui.button.reward", false, 0.18, true)
		_assign_button_icon(claim, "ui.quest.icon.claim", 42)
		applied += 1

	var result := view.find_child("PuzzleResultLabel", true, false) as Label
	if result:
		ProductionUiBinder.apply_backdrop(result, "ui.reward.panel", false, 0.13)
		applied += 1
	return applied



static func _assemble_home_tap(root: Control) -> int:
	var view := root.find_child("View_TapHero", true, false)
	if view == null:
		return 0
	var applied := 0

	var monster_title := view.find_child("MonsterLevelLabel", false, false) as Label
	if monster_title:
		monster_title.custom_minimum_size.y = maxf(monster_title.custom_minimum_size.y, 64.0)
		ProductionUiBinder.apply_backdrop(monster_title, "ui.panel.banner", false, 0.13)
		applied += 1

	var hp := view.find_child("MonsterHP", false, false) as ProgressBar
	if hp:
		hp.custom_minimum_size.y = maxf(hp.custom_minimum_size.y, 52.0)
		applied += 1

	var hp_label := view.find_child("MonsterHPLabel", false, false) as Label
	if hp_label:
		hp_label.custom_minimum_size.y = maxf(hp_label.custom_minimum_size.y, 48.0)
		applied += 1

	var boss_proximity := view.find_child("BossProximityP0", false, false) as Label
	if boss_proximity:
		ProductionUiBinder.apply_backdrop(boss_proximity, "ui.home.boss_progress", false, 0.12)
		boss_proximity.custom_minimum_size.y = maxf(boss_proximity.custom_minimum_size.y, 58.0)
		applied += 1

	var progress_label := view.find_child("MonsterProgressLabel", false, false) as Label
	if progress_label:
		ProductionUiBinder.apply_backdrop(progress_label, "ui.home.boss_progress", false, 0.12)
		applied += 1

	var wheel_cta := view.find_child("HomeWheelCTA", false, false) as Button
	if wheel_cta:
		ProductionUiBinder.apply_backdrop(wheel_cta, "ui.button.spin.primary", false, 0.18, true)
		_assign_button_icon(wheel_cta, "ui.nav.currency", 46)
		wheel_cta.custom_minimum_size.y = maxf(wheel_cta.custom_minimum_size.y, 108.0)
		applied += 1

	var upgrade := view.find_child("TapUpgradeButton", false, false) as Button
	if upgrade:
		ProductionUiBinder.apply_backdrop(upgrade, "ui.button.primary", false, 0.18, true)
		_assign_button_icon(upgrade, "ui.combat.attack", 46)
		upgrade.custom_minimum_size.y = maxf(upgrade.custom_minimum_size.y, 106.0)
		applied += 1

	var reward_label := view.find_child("RewardLabel", false, false) as Label
	if reward_label:
		ProductionUiBinder.apply_backdrop(reward_label, "ui.panel.small.parchment", false, 0.12)
		applied += 1
	
	var synergy := view.find_child("CoreSynergyLabelV174", false, false) as Label
	if synergy:
		ProductionUiBinder.apply_backdrop(synergy, "ui.panel.info.dark", false, 0.12)
		applied += 1

	var momentum := view.find_child("TapMomentumLabelV172", false, false) as Label
	if momentum:
		ProductionUiBinder.apply_backdrop(momentum, "ui.panel.info.dark", false, 0.12)
		applied += 1

	var assist := view.find_child("HeroAssistLabelV172", false, false) as Label
	if assist:
		ProductionUiBinder.apply_backdrop(assist, "ui.panel.small.parchment", false, 0.12)
		applied += 1

	var reward_overlay := root.find_child("MonsterRewardOverlay", true, false) as Control
	if reward_overlay:
		var title := reward_overlay.find_child("MonsterRewardTitle", true, false) as Label
		if title:
			ProductionUiBinder.apply_backdrop(title, "ui.panel.banner", false, 0.13)
			applied += 1
		var text := reward_overlay.find_child("MonsterRewardText", true, false) as Label
		if text:
			ProductionUiBinder.apply_backdrop(text, "ui.reward.panel", false, 0.13)
			applied += 1
		var cont := reward_overlay.find_child("MonsterRewardContinue", true, false) as Button
		if cont:
			ProductionUiBinder.apply_backdrop(cont, "ui.button.reward", false, 0.18, true)
			_assign_button_icon(cont, "ui.quest.icon.claim", 44)
			applied += 1

	var boss_intro := root.find_child("BossIntroOverlay", true, false) as Control
	if boss_intro:
		var label := boss_intro.find_child("BossIntroLabel", true, false) as Label
		if label:
			ProductionUiBinder.apply_backdrop(label, "ui.panel.banner", false, 0.13)
			applied += 1

	return applied

static func _assemble_village_core(root: Control) -> int:
	var view := root.find_child("View_ClashDorf", true, false)
	if view == null:
		return 0
	var applied := 0

	var title := view.find_child("VillageTitle", false, false) as Label
	if title:
		ProductionUiBinder.apply_backdrop(title, "ui.panel.banner", false, 0.13)
		applied += 1

	for name in ["VillageSubtitleP0", "VillageGrowthLabelV153", "GoldmineStatusP0"]:
		var label := view.find_child(name, true, false) as Label
		if label:
			ProductionUiBinder.apply_backdrop(label, "ui.panel.info.dark", false, 0.12)
			label.custom_minimum_size.y = maxf(label.custom_minimum_size.y, 54.0)
			applied += 1

	var grid := view.find_child("P0BuildingGrid", false, false) as GridContainer
	if grid:
		grid.add_theme_constant_override("h_separation", 18)
		grid.add_theme_constant_override("v_separation", 18)
		var building_specs := {
			"BuildingTownhall": "ui.frame.slot.1",
			"BuildingGoldmine": "ui.frame.slot.2",
			"BuildingForge": "ui.frame.slot.3",
			"BuildingLuck": "ui.frame.slot.4"
		}
		for name in building_specs.keys():
			var button := grid.find_child(name, false, false) as Button
			if button:
				ProductionUiBinder.apply_backdrop(button, str(building_specs[name]), false, 0.10, true)
				button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, 360.0)
				applied += 1

	var function_specs := {
		"VillageForgeActionV153": ["ui.button.secondary", "ui.village.control.upgrade"],
		"VillageTempleActionV153": ["ui.button.secondary", "ui.village.control.ready"],
		"VillageProsperityClaimV153": ["ui.button.reward", "ui.quest.icon.claim"],
		"GoldmineClaimButtonP0": ["ui.button.positive", "ui.village.control.collect"]
	}
	for name in function_specs.keys():
		var button := view.find_child(name, true, false) as Button
		if button:
			var spec: Array = function_specs[name]
			ProductionUiBinder.apply_backdrop(button, str(spec[0]), false, 0.18, true)
			_assign_button_icon(button, str(spec[1]), 44)
			button.custom_minimum_size.y = maxf(button.custom_minimum_size.y, 88.0)
			applied += 1

	return applied

static func refresh_home_loop_state(root: Control, is_boss: bool, until_boss: int, current_hp: int, max_hp: int) -> void:
	var view := root.find_child("View_TapHero", true, false)
	if view == null:
		return
	var hp := view.find_child("MonsterHP", false, false) as ProgressBar
	if hp:
		ProductionUiBinder.apply_backdrop(hp, "ui.monster.hp.boss" if is_boss else "ui.monster.hp.normal", false, 0.16, true)

	var title := view.find_child("MonsterLevelLabel", false, false) as Label
	if title:
		title.tooltip_text = "Boss-Begegnung" if is_boss else "Monster-Begegnung"

	var proximity := view.find_child("BossProximityP0", false, false) as Label
	if proximity:
		proximity.visible = is_boss or until_boss <= 3
		if is_boss:
			proximity.modulate = Color.WHITE
		elif until_boss <= 1:
			proximity.modulate = Color(1.0, 0.88, 0.68, 1.0)
		else:
			proximity.modulate = Color.WHITE

	var reward_label := view.find_child("RewardLabel", false, false) as Label
	if reward_label:
		reward_label.visible = not reward_label.text.strip_edges().is_empty()

static func refresh_village_loop_state(root: Control, goldmine_pending: int, forge_ready: bool, temple_ready: bool, prosperity_ready: bool) -> void:
	var view := root.find_child("View_ClashDorf", true, false)
	if view == null:
		return

	var gold_button := view.find_child("GoldmineClaimButtonP0", true, false) as Button
	if gold_button:
		_assign_button_icon(gold_button, "ui.village.control.collect" if goldmine_pending > 0 else "ui.village.control.timer", 44)
		ProductionUiBinder.apply_backdrop(gold_button, "ui.button.positive" if goldmine_pending > 0 else "ui.button.neutral", false, 0.18, true)

	var forge := view.find_child("VillageForgeActionV153", true, false) as Button
	if forge:
		_assign_button_icon(forge, "ui.village.control.ready" if forge_ready else "ui.village.control.locked", 42)
		ProductionUiBinder.apply_backdrop(forge, "ui.button.positive" if forge_ready else "ui.button.secondary", false, 0.18, true)

	var temple := view.find_child("VillageTempleActionV153", true, false) as Button
	if temple:
		_assign_button_icon(temple, "ui.village.control.ready" if temple_ready else "ui.village.control.locked", 42)
		ProductionUiBinder.apply_backdrop(temple, "ui.button.positive" if temple_ready else "ui.button.secondary", false, 0.18, true)

	var prosperity := view.find_child("VillageProsperityClaimV153", true, false) as Button
	if prosperity:
		_assign_button_icon(prosperity, "ui.quest.icon.claim" if prosperity_ready else "ui.village.control.locked", 44)
		ProductionUiBinder.apply_backdrop(prosperity, "ui.button.reward" if prosperity_ready else "ui.button.neutral", false, 0.18, true)


static func _assemble_reward_session_flow(root: Control) -> int:
	var applied := 0

	var reward_modal := root.find_child("RewardModal", true, false) as Control
	if reward_modal:
		var title := reward_modal.find_child("RewardModalTitle", true, false) as Label
		if title:
			ProductionUiBinder.apply_backdrop(title, "ui.panel.banner", false, 0.13)
			applied += 1
		var text := reward_modal.find_child("RewardModalText", true, false) as Label
		if text:
			ProductionUiBinder.apply_backdrop(text, "ui.reward.panel", false, 0.13)
			applied += 1
		var close := reward_modal.find_child("RewardModalClose", true, false) as Button
		if close:
			ProductionUiBinder.apply_backdrop(close, "ui.button.reward", false, 0.18, true)
			_assign_button_icon(close, "ui.quest.icon.claim", 44)
			applied += 1

	var level_up := root.find_child("LevelUpOverlayP0", true, false) as Control
	if level_up:
		var title := level_up.find_child("LevelUpTitleP0", true, false) as Label
		if title:
			ProductionUiBinder.apply_backdrop(title, "ui.panel.banner", false, 0.13)
			applied += 1
		var text := level_up.find_child("LevelUpTextP0", true, false) as Label
		if text:
			ProductionUiBinder.apply_backdrop(text, "ui.progression.overview", false, 0.12)
			applied += 1
		var cont := level_up.find_child("LevelUpContinueP0", true, false) as Button
		if cont:
			ProductionUiBinder.apply_backdrop(cont, "ui.button.positive", false, 0.18, true)
			_assign_button_icon(cont, "ui.progression.level_badge", 44)
			applied += 1

	var meta := root.find_child("View_Meta", true, false) as Control
	if meta:
		var title := meta.find_child("MetaTitle", false, false) as Label
		if title:
			ProductionUiBinder.apply_backdrop(title, "ui.panel.banner", false, 0.13)
			applied += 1
		var event_panel := meta.find_child("EventPanel", false, false) as Control
		if event_panel:
			ProductionUiBinder.apply_backdrop(event_panel, "ui.panel.tall.primary", false, 0.13, event_panel is PanelContainer)
			applied += 1
		var ranking_panel := meta.find_child("RankingPanel", false, false) as Control
		if ranking_panel:
			ProductionUiBinder.apply_backdrop(ranking_panel, "ui.panel.tall.dark", false, 0.13, ranking_panel is PanelContainer)
			applied += 1
		var chest_panel := meta.find_child("RealmChestPanel", false, false) as Control
		if chest_panel:
			ProductionUiBinder.apply_backdrop(chest_panel, "ui.panel.info.parchment", false, 0.13, chest_panel is PanelContainer)
			applied += 1

		var event_claim := meta.find_child("EventClaimButton", true, false) as Button
		if event_claim:
			ProductionUiBinder.apply_backdrop(event_claim, "ui.button.reward", false, 0.18, true)
			_assign_button_icon(event_claim, "ui.quest.icon.claim", 42)
			applied += 1

		var chest_button := meta.find_child("RealmChestButton", true, false) as Button
		if chest_button:
			ProductionUiBinder.apply_backdrop(chest_button, "ui.button.reward", false, 0.18, true)
			_assign_button_icon(chest_button, "ui.ranking.reward", 44)
			applied += 1

		var result := meta.find_child("MetaResultLabel", true, false) as Label
		if result:
			ProductionUiBinder.apply_backdrop(result, "ui.reward.panel", false, 0.13)
			applied += 1

	return applied

static func refresh_reward_session_state(root: Control, event_ready: bool, event_claimed: bool, chest_ready: bool, result_text: String) -> void:
	var meta := root.find_child("View_Meta", true, false) as Control
	if meta:
		var event_button := meta.find_child("EventClaimButton", true, false) as Button
		if event_button:
			var event_role := "ui.button.neutral"
			var event_icon := "ui.utility.checked_slot"
			if event_ready and not event_claimed:
				event_role = "ui.button.reward"
				event_icon = "ui.quest.icon.claim"
			elif not event_claimed:
				event_role = "ui.button.secondary"
				event_icon = "ui.quest.icon.in_progress"
			ProductionUiBinder.apply_backdrop(event_button, event_role, false, 0.18, true)
			_assign_button_icon(event_button, event_icon, 42)

		var chest_button := meta.find_child("RealmChestButton", true, false) as Button
		if chest_button:
			ProductionUiBinder.apply_backdrop(chest_button, "ui.button.reward" if chest_ready else "ui.button.secondary", false, 0.18, true)
			_assign_button_icon(chest_button, "ui.ranking.reward" if chest_ready else "ui.village.control.locked", 44)

		var result := meta.find_child("MetaResultLabel", true, false) as Label
		if result:
			result.visible = not result_text.strip_edges().is_empty()

static func prepare_reward_modal(root: Control, payload: Dictionary) -> void:
	var modal := root.find_child("RewardModal", true, false) as Control
	if modal == null:
		return
	var reward_count := 0
	for key in ["gold", "gems", "spins", "xp"]:
		if int(payload.get(key, 0)) > 0:
			reward_count += 1
	var text := modal.find_child("RewardModalText", true, false) as Label
	if text:
		ProductionUiBinder.apply_backdrop(text, "ui.reward.panel", false, 0.13)
		text.custom_minimum_size.y = maxf(text.custom_minimum_size.y, 120.0 + float(reward_count) * 34.0)

static func prepare_boss_reward(root: Control, is_boss_reward: bool) -> void:
	var overlay := root.find_child("MonsterRewardOverlay", true, false) as Control
	if overlay == null:
		return
	var title := overlay.find_child("MonsterRewardTitle", true, false) as Label
	var text := overlay.find_child("MonsterRewardText", true, false) as Label
	var cont := overlay.find_child("MonsterRewardContinue", true, false) as Button
	if title:
		ProductionUiBinder.apply_backdrop(title, "ui.panel.banner", false, 0.13)
	if text:
		ProductionUiBinder.apply_backdrop(text, "ui.ranking.reward" if is_boss_reward else "ui.reward.panel", false, 0.13)
	if cont:
		ProductionUiBinder.apply_backdrop(cont, "ui.button.reward", false, 0.18, true)
		_assign_button_icon(cont, "ui.ranking.reward" if is_boss_reward else "ui.quest.icon.claim", 44)

static func refresh_shop_state(root: Control, products: Dictionary) -> void:
	var strip := root.find_child("ShopVisualStripV164", true, false) as HBoxContainer
	if strip == null:
		return
	var product_ids := products.keys()
	product_ids.sort()
	for i in range(strip.get_child_count()):
		var card := strip.get_child(i) as TextureRect
		if card == null:
			continue
		if i >= product_ids.size():
			card.visible = false
			continue
		card.visible = true
		var product: Dictionary = products[product_ids[i]]
		var payload: Dictionary = product.get("payload", {})
		var role := "ui.shop.item.standard"
		var allow_medium := true
		if bool(product.get("seasonal", false)):
			role = "ui.shop.item.limited"
			allow_medium = false
		elif payload.has("gems") or payload.has("cosmetic") or payload.has("no_ads"):
			role = "ui.shop.item.premium"
			allow_medium = false
		card.texture = SemanticAssetRegistry.texture_for_role(role, allow_medium)
		card.tooltip_text = str(product.get("display_name", product_ids[i]))

static func refresh_afk_state(root: Control, pending: Dictionary, player_level: int) -> void:
	var row := root.find_child("AfkRewardVisualRowV164", true, false) as HBoxContainer
	if row == null:
		return
	var has_reward := not pending.is_empty()
	var has_progression_bonus := has_reward and player_level > 1
	for i in range(row.get_child_count()):
		var slot := row.get_child(i) as TextureRect
		if slot == null:
			continue
		if i == 0:
			slot.visible = has_reward
			slot.modulate = Color.WHITE if has_reward else Color(1,1,1,0.35)
		else:
			slot.visible = has_progression_bonus
			slot.modulate = Color.WHITE if has_progression_bonus else Color(1,1,1,0.35)

static func refresh_progression_state(root: Control, tracks: Array) -> void:
	var visual := root.find_child("ProgressionVisualV164", true, false) as VBoxContainer
	if visual == null:
		return
	var nodes: Array[TextureRect] = []
	for child in visual.find_children("ProgressionNodeV168_*", "TextureRect", true, false):
		var tex := child as TextureRect
		if tex:
			nodes.append(tex)
	if nodes.is_empty():
		for child in visual.find_children("*", "TextureRect", true, false):
			var tex := child as TextureRect
			if tex and tex.name != "ProgressionBarArtV168":
				nodes.append(tex)
	if nodes.size() > 4:
		nodes = nodes.slice(nodes.size() - 4, nodes.size())
	for i in range(mini(nodes.size(), 4)):
		var role := "ui.progression.node.locked"
		if i < tracks.size():
			var track: Dictionary = tracks[i]
			var value := float(track.get("value", 0))
			var target := maxf(float(track.get("target", 1)), 1.0)
			var ratio := clampf(value / target, 0.0, 1.0)
			if ratio >= 1.0:
				role = "ui.progression.node.completed"
			elif value > 0.0:
				role = "ui.progression.node.available"
			else:
				role = "ui.progression.node.standard"
			nodes[i].tooltip_text = "%s · %s" % [str(track.get("title","")), str(track.get("text",""))]
		nodes[i].texture = SemanticAssetRegistry.texture_for_role(role, false)

static func refresh_runtime_state(root: Control, products: Dictionary, pending_afk: Dictionary, player_level: int, tracks: Array) -> void:
	refresh_shop_state(root, products)
	refresh_afk_state(root, pending_afk, player_level)
	refresh_progression_state(root, tracks)

static func _active_core_view(root: Control) -> Control:
	for name in ["View_TapHero", "View_CoinMaster", "View_ClashDorf"]:
		var view := root.find_child(name, true, false) as Control
		if view and view.visible:
			return view
	return null

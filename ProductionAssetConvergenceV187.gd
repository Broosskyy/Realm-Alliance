extends RefCounted

const ProductionUiBinder = preload("res://ProductionUiBinder.gd")

static func apply(root: Node) -> Dictionary:
	var applied := 0
	var skipped := 0
	var texture_roles := {
		"LaneMap":"mode.lane.map","LaneLeftUnit":"mode.lane.unit","LaneRightUnit":"mode.lane.enemy",
		"TDMap":"mode.td.map","TowerA":"mode.td.tower","TowerB":"mode.td.tower","TDEnemyMarker":"mode.td.enemy"
	}
	for node_name in texture_roles:
		var node := root.find_child(node_name,true,false)
		var tex := ProductionAssetRegistry.bound_texture(texture_roles[node_name],false)
		if node is TextureRect and tex != null:
			node.texture = tex
			node.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
			node.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED if node_name in ["LaneMap","TDMap"] else TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			applied += 1
		else: skipped += 1
	var backdrop_roles := {
		"JourneyBoard":"mode.journey.board","JourneyCacheP0":"mode.journey.cache","TreasurePortalPanel":"mode.journey.portal",
		"PuzzlePanel":"mode.puzzle.board","LaneStageLabelP0":"mode.lane.stage","LaneMasteryLabelP0":"mode.lane.mastery",
		"TDStageLabelP0":"mode.td.stage","TDMasteryLabelP0":"mode.td.mastery",
		"HeroWeaponButton":"hero.weapon","HeroCharmButton":"hero.charm","HeroSpecializationButtonP0":"hero.specialization","HeroMasteryClaimP0":"hero.reward",
		"QuestTitle":"objective.board","DailyClaimButton":"objective.daily",
		"VillageGrowthLabelV153":"village.growth","VillageForgeActionV153":"village.craft","VillageTempleActionV153":"village.blessing","VillageProsperityClaimV153":"village.reward",
		"FeatureHubStatusV154":"hub.status","HubJourneyP0":"hub.journey","HubProgressionP0":"hub.progression"
	}
	for node_name in backdrop_roles:
		var node := root.find_child(node_name,true,false)
		if node is Control and ProductionUiBinder.apply_backdrop(node,backdrop_roles[node_name],false,0.14,node is Button):
			applied += 1
		else: skipped += 1
	var rune_roles := ["mode.puzzle.leaf","mode.puzzle.crystal","mode.puzzle.coin"]
	for i in range(9):
		var cell := root.find_child("PuzzleCell%d" % i,true,false)
		var tex := ProductionAssetRegistry.bound_texture(rune_roles[i % 3],false)
		if cell is Button and tex != null:
			cell.icon = tex
			cell.expand_icon = true
			applied += 1
	var hero_roles := {"HeroKnight":"hero.knight.mastery","HeroArcher":"hero.archer.mastery","HeroMage":"hero.mage.mastery"}
	for node_name in hero_roles:
		var hero := root.find_child(node_name,true,false)
		var tex := ProductionAssetRegistry.bound_texture(hero_roles[node_name],false)
		if hero is Button and tex != null:
			hero.icon = tex
			hero.expand_icon = true
			applied += 1
	return {"applied":applied,"skipped":skipped}

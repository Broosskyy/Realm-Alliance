extends Node

func tracks() -> Array:
	var journey_nodes := DiceJourneySystem.board_nodes()
	var journey_pos := DiceJourneySystem.position + 1
	var puzzle_target := maxi(int(PuzzleSystem.config.get("target_matches",3)),1)
	return [
		{"id":"account","title":"SPIELER","value":PlayerData.player_level,"target":maxi(PlayerData.player_level+1,2),"text":"STUFE %d" % PlayerData.player_level},
		{"id":"combat","title":"MONSTER","value":PlayerData.monster_level,"target":PlayerData.monster_level+1,"text":"MONSTER · STUFE %d · REALM-KRAFT +%d%%" % [PlayerData.monster_level,int(round(CoreProgressionSynergySystem.tap_bonus_ratio()*100.0))]},
		{"id":"village","title":"DORF","value":VillageProgressionSystem.prosperity_xp,"target":VillageProgressionSystem.xp_for_next(),"text":"WACHSTUM STUFE %d · RATHAUS %d · MINE %d · SCHMIEDE %d/%d · TEMPEL %d" % [VillageProgressionSystem.prosperity_level,P0VillageSystem.get_level("townhall"),P0VillageSystem.get_level("goldmine"),VillageProgressionSystem.forge_crafts,VillageProgressionSystem.forge_craft_cap(),P0VillageSystem.get_level("lucktemple")]},
		{"id":"journey","title":"REISE","value":JourneyProgressionSystem.mastery_xp,"target":JourneyProgressionSystem.xp_for_next_level(),"text":"FELD %d / %d · FORTSCHRITT %d · RUNDEN %d · SPLITTER %d" % [journey_pos,journey_nodes,JourneyProgressionSystem.mastery_level,DiceJourneySystem.laps_completed,JourneyProgressionSystem.relic_shards]},
		{"id":"puzzle","title":"PUZZLE","value":PuzzleProgressionSystem.mastery_xp,"target":PuzzleProgressionSystem.xp_for_next_level(),"text":"STUFE %d / %d · FORTSCHRITT %d · RUNDEN %d" % [PuzzleProgressionSystem.stage,PuzzleProgressionSystem.stage_count(),PuzzleProgressionSystem.mastery_level,PuzzleProgressionSystem.completions]},
		{"id":"defense","title":"VERTEIDIGUNG","value":TowerDefenseProgressionSystem.mastery_xp,"target":TowerDefenseProgressionSystem.xp_for_next_level(),"text":"STUFE %d / %d · FORTSCHRITT %d · TECH %d · RUNDEN %d" % [TowerDefenseProgressionSystem.campaign_stage,TowerDefenseProgressionSystem.campaign_stage_count(),TowerDefenseProgressionSystem.mastery_level,TowerDefenseProgressionSystem.tower_tech_level,TowerDefenseProgressionSystem.completed_runs]},
		{"id":"lane","title":"ANGRIFF","value":LaneBattleProgressionSystem.mastery_xp,"target":LaneBattleProgressionSystem.xp_for_next_level(),"text":"STUFE %d / %d · FORTSCHRITT %d · TECH %d · SIEGE %d" % [LaneBattleProgressionSystem.campaign_stage,LaneBattleProgressionSystem.stage_count(),LaneBattleProgressionSystem.mastery_level,LaneBattleProgressionSystem.unit_tech_level,LaneBattleProgressionSystem.completed_wins]},
		{"id":"heroes","title":"HELDEN","value":int(HeroProgressionSystem.mastery_xp.get(HeroSystem.get_selected_hero_id(),0)),"target":HeroProgressionSystem.xp_for_next(HeroSystem.get_selected_hero_id()),"text":"%s · FORTSCHRITT %d · AUTO-SCHADEN %d" % [str(HeroSystem.get_card_data(HeroSystem.get_selected_hero_id()).get("name",HeroSystem.get_selected_hero_id())).to_upper(),int(HeroProgressionSystem.mastery_level.get(HeroSystem.get_selected_hero_id(),1)),HeroSystem.get_total_auto_dps()]},
		{"id":"meta","title":"BOSSE & TRUHEN","value":MetaProgressSystem.boss_defeats,"target":maxi(MetaProgressSystem.boss_defeats+3,3),"text":"BOSSE %d · TRUHEN %d" % [MetaProgressSystem.boss_defeats,MetaProgressSystem.realm_chests_opened]},
		{"id":"objectives","title":"AUFGABEN & SAMMLUNG","value":int(ObjectiveSystem.collection_state().value),"target":int(ObjectiveSystem.collection_state().target),"text":"BESTIARIUM %d / %d · %s" % [int(ObjectiveSystem.collection_state().value),int(ObjectiveSystem.collection_state().target),ObjectiveSystem.summary()]}
	]

func summary_text() -> String:
	var lines: Array[String] = []
	for track in tracks():
		lines.append("%s · %s" % [str(track.title),str(track.text)])
	return "\n".join(lines)

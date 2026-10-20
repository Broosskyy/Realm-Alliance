extends RefCounted
# Explicit baseline for historical guardian regression suites. New-start behavior
# is verified separately in test_foundation709.gd; production never loads this.
static func guardian() -> Dictionary:
    var state=preload("res://scripts/systems/save_migration.gd").normalize({})
    state.profile.hero_roster={"schema":1,"active":"realmwachter","owned":{"realmwachter":{"xp":0,"source":"legacy_guardian"}}}
    return state

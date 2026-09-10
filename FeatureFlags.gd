extends Node

# Master Concept V1.8 / Source V1.23 visibility contract.
# Systems may exist technically without appearing in the first core build.
const SHOW_DAILY := true
const SHOW_QUESTS := true
const SHOW_HEROES := true
const SHOW_ATTACK := false
const SHOW_DEFENSE := false
const SHOW_GEMS := false

const SHOW_WHEEL := true
const SHOW_VILLAGE := true
const SHOW_SETTINGS := true


# P0 Core closure: hidden P1 systems must not affect P0 balance.
const ENABLE_HERO_AUTODPS := true

# V1.23 reserved product surfaces - intentionally not runtime-visible yet.
const SHOW_DICE := true
const SHOW_PUZZLE := true
const SHOW_REALM_JOURNEY := true
const SHOW_TREASURE_PORTAL := true
const SHOW_EVENTS := true
const SHOW_RANKINGS := true
const SHOW_REALM_CHEST := true

# Post-V1.28 lean gameplay slices.
const SHOW_TOWER_DEFENSE := true
const SHOW_LANE_BATTLE := true

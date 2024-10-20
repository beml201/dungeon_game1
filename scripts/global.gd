extends Node

# Static MetaData
const TILE_SIZE := 64
const UPGRADE_OPTIONS := ['EMBIGGEN', 'ENLARGEN']

#  Dynamic MetaData
var player_current_attack = false
var player_can_attack = true
var dungeons_finished := 0

# Public calls
signal magic_mushroom

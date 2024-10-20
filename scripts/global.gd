extends Node

# Static MetaData
const TILE_SIZE := 64

#  Dynamic MetaData
var player_current_attack = false
var player_can_attack = true
var dungeons_finished := 0

# Public calls
signal magic_mushroom

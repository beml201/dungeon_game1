extends Node

# Static MetaData
const TILE_SIZE := 64
var UPGRADE_OPTIONS := ['EMBIGGEN', 'ENLARGEN', 'ENARMEN', 'ENSEEEN', 'ENLIGHTEN'] #'ENLEGGEN', 'ENSPEEDEN', 'ENSHEILDEN'
const BASE_TILE_DICT := {
	"ul":Vector2i(0,0), "ml":Vector2i(0,1), "bl":Vector2i(0,2),
	"um":Vector2i(1,0), "mm":Vector2i(1,1), "bm":Vector2i(1,2),
	"ur":Vector2i(2,0), "mr":Vector2i(2,1), "br":Vector2i(2,2)}

#  Dynamic MetaData
var player_direction = "right"
var player_current_attack = false
var player_can_attack = true
var dungeons_finished := 0
var player_can_upgrade := false
var key_spawned := false
var rooms_spawned = 0
var mobs_left := 0
var villagers_killed := 0
var game_end = false

# Public calls
signal player_attack
signal mob_attack
signal magic_mushroom
signal create_enemies
signal log_player_position

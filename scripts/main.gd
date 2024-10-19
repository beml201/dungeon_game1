extends Node2D

const Player = preload("res://scenes/sam.tscn")
const Dungeon = preload("res://scenes/dungeon.tscn")
const tilesize = 16
const Slime = preload("res://scenes/mob_slime.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	# Load dungeon
	var dungeon = Dungeon.instantiate()
	add_child(dungeon)
	
	#var player_current_attack = false
	
	# Load player
	var player = Player.instantiate()
	player.global_position = Vector2i(5*tilesize,5*tilesize)	
	add_child(player)
	
	
	var slime = Slime.instantiate()
	slime.global_position = Vector2i(12*tilesize,12*tilesize)	
	add_child(slime)
	var slime2 = Slime.instantiate()
	slime2.global_position = Vector2i(20*tilesize,20*tilesize)	
	add_child(slime2)
	
	const Mush = preload("res://scenes/mushroom.tscn")
	var mush = Mush.instantiate()
	mush.global_position = Vector2i(4*tilesize, 4*tilesize)
	add_child(mush)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

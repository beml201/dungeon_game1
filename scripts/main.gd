extends Node2D

# Instantiate single objects
const Player = preload("res://scenes/sam.tscn")
@onready var player = Player.instantiate()
const Dungeon = preload("res://scenes/dungeon.tscn")
@onready var dungeon = Dungeon.instantiate()
const tilesize = 16
# Preload multiple use objects
const Slime = preload("res://scenes/mob_slime.tscn")
const Mush = preload("res://scenes/mushroom.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	add_child(dungeon)
	player.global_position = Vector2i(5*tilesize,5*tilesize)	
	add_child(player)
	
	#var player_current_attack = false	
	var slime = Slime.instantiate()
	slime.global_position = Vector2i(12*tilesize,12*tilesize)	
	add_child(slime)
	var slime2 = Slime.instantiate()
	slime2.global_position = Vector2i(20*tilesize,20*tilesize)	
	add_child(slime2)
	
	#var mush = Mush.instantiate()
	#mush.global_position = Vector2i(4*tilesize, 4*tilesize)
	#add_child(mush)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

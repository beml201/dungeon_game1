extends Node2D

# Instantiate single objects
const Player = preload("res://scenes/sam.tscn")
@onready var player = Player.instantiate()
const Dungeon = preload("res://scenes/dungeon.tscn")
@onready var dungeon = Dungeon.instantiate()
const tilesize = 16
# Preload multiple use objects
##Mobs
const Slime = preload("res://scenes/mob_slime.tscn")
const Crawler = preload("res://scenes/mob_crawl.tscn")
const Arms = preload("res://scenes/mob_arms.tscn")
const Legs = preload("res://scenes/mob_legs.tscn")
const Phantom = preload("res://scenes/mob_phantom.tscn")
##Other
const Mush = preload("res://scenes/mushroom.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	Global.connect("create_enemies", add_enemies)
	add_child(dungeon)
	player.global_position = Vector2i(5*tilesize,5*tilesize)	
	add_child(player)
	
	#var player_current_attack = false
	var start = [Vector2i(0,0), Vector2i(0,0)]
	add_enemies([0],start)
	#var mush = Mush.instantiate()
	#mush.global_position = Vector2i(4*tilesize, 4*tilesize)
	#add_child(mush)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass

func add_enemies(difficulty,room_corners):
	var enemy_types = [Slime]
	var room_corner := Vector2i(room_corners[Global.rooms_spawned][0],room_corners[Global.rooms_spawned][1])
	var enemies = 2
	
	if len(difficulty) > 1:
		enemies = randi()%3 + 2
		enemy_types.append(Crawler)
		enemy_types.append(Arms)
		enemy_types.append(Legs)
		enemy_types.append(Phantom)
		
	print(room_corner)
	for i in range(0,enemies):
		var random_enemy = randi()%len(enemy_types)
		var random_x = randi_range(3, 8)
		var random_y = randi_range(3, 8)
		#print(random_x, ",", random_y)
		var new_enemy = enemy_types[random_enemy].instantiate()
		new_enemy.global_position = (room_corner+Vector2i(random_x, random_y))*Global.TILE_SIZE
		add_child(new_enemy)
	Global.rooms_spawned += 1

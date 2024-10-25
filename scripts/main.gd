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
const Slug = preload("res://scenes/mob_slug.tscn")
const Phantom = preload("res://scenes/mob_phantom.tscn")
##Other
const Mush = preload("res://scenes/mushroom.tscn")
const Key = preload("res://scenes/key.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	Global.connect("create_enemies", add_enemies)
	add_child(dungeon)
	player.global_position = Vector2i(5*tilesize,5*tilesize)	
	add_child(player)
	$Background_music.play()
	#var player_current_attack = false
	add_enemies(0)
	#var mush = Mush.instantiate()
	#mush.global_position = Vector2i(4*tilesize, 4*tilesize)
	#add_child(mush)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.mobs_left == 0 and not Global.key_spawned and not Global.player_can_upgrade:
		add_key(Global.dungeons_finished)

func add_enemies(room_number):
	var enemy_types = [Slime]
	#var room_corner := Vector2i(dunroom_corners[Global.rooms_spawned][0],room_corners[Global.rooms_spawned][1])
	var difficulty = room_number+1
	var enemies = 2
	
	if difficulty > 1:
		enemies = randi()%3 + 2
		enemy_types.append(Crawler)
		#enemy_types.append(Arms)
		#enemy_types.append(Legs)
		#enemy_types.append(Slug)
		enemy_types.append(Phantom)
		
	#print(room_corner)
	for i in range(0,enemies):
		var random_enemy = randi()%len(enemy_types)
		var random_x = randi()%(dungeon.ROOM_SIZE[0]-2)+1
		var random_y = randi()%(dungeon.ROOM_SIZE[1]-2)+1#randi_range(3, 8)
		#print(random_x, ",", random_y)
		var new_enemy = enemy_types[random_enemy].instantiate()
		new_enemy.global_position = (dungeon.room_pos_ul[room_number]+Vector2i(random_x, random_y))*Global.TILE_SIZE
		add_child(new_enemy)
	Global.mobs_left = enemies
	Global.rooms_spawned += 1

func add_key(room_number):
	Global.key_spawned = true
	var key = Key.instantiate()
	key.position = dungeon.room_pos_ul[room_number] + (dungeon.ROOM_SIZE/2)
	key.position *= Global.TILE_SIZE
	add_child(key)

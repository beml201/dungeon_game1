extends Node2D

# Instantiate single objects
const Player = preload("res://scenes/sam.tscn")
@onready var player = Player.instantiate()
const Dungeon = preload("res://scenes/dungeon.tscn")
@onready var dungeon = Dungeon.instantiate()
# Preload multiple use objects
##Mobs
const Slime = preload("res://scenes/mob_slime.tscn")
const Crawler = preload("res://scenes/mob_crawl.tscn")
const Arms = preload("res://scenes/mob_arms.tscn")
const Legs = preload("res://scenes/mob_legs.tscn")
const Slug = preload("res://scenes/mob_slug.tscn")
const Phantom = preload("res://scenes/mob_phantom.tscn")
var enemy_order = [Slime, Crawler, Phantom]
##Other
const Mush = preload("res://scenes/mushroom.tscn")
const Key = preload("res://scenes/key.tscn")
# Called when the node enters the scene tree for the first time.
func _ready():
	Global.connect("create_enemies", add_enemies)
	add_child(dungeon)
	player.global_position = dungeon.ROOM_SIZE/2*Global.TILE_SIZE
	add_child(player)
	$Background_music.play()
	add_enemies(0)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.mobs_left == 0 and not Global.key_spawned and not Global.player_can_upgrade:
		add_key(Global.dungeons_finished)

func add_enemies(room_number):
	if room_number+1==dungeon.N_ROOMS:
		Global.mobs_left += 1
		return
	# Select the last enemy for the room number to generate
	var enemies = enemy_order.slice(0, 1+min(room_number, enemy_order.size()))
	var to_spawn = enemies
	for i in range(room_number+1):
		to_spawn.append(enemies.pick_random())
		
	for enemy in to_spawn:
		var random_x = randi()%(dungeon.ROOM_SIZE[0]-2)+1
		var random_y = randi()%(dungeon.ROOM_SIZE[1]-2)+1
		var new_enemy = enemy.instantiate()
		new_enemy.global_position = (dungeon.room_pos_ul[room_number]+Vector2i(random_x, random_y))*Global.TILE_SIZE
		add_child(new_enemy)
	Global.mobs_left = to_spawn.size()
	Global.rooms_spawned += 1

func add_key(room_number):
	Global.key_spawned = true
	var key = Key.instantiate()
	key.position = dungeon.room_pos_ul[room_number] + (dungeon.ROOM_SIZE/2)
	key.position *= Global.TILE_SIZE
	add_child(key)

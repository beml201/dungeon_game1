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
const Villager = preload("res://scenes/villager.tscn")
var enemy_order = [Slime, Crawler, Phantom]
##Other
const Mush = preload("res://scenes/mushroom.tscn")
const Key = preload("res://scenes/key.tscn")
const Ladder = preload("res://scenes/Ladder.tscn")
const Cutscene = preload("res://scenes/cutscene.tscn")
var ladder = null
# Called when the node enters the scene tree for the first time.
func _ready():
	Global.connect("create_enemies", add_enemies)
	add_child(dungeon)
	player.global_position = dungeon.ROOM_SIZE/2*Global.TILE_SIZE
	add_child(player)
	$Background_music.play()
	add_enemies(0)
	Global.connect("climb_ladder", climb_ladder)
	Global.connect("cutscene_end", begin_phase2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if Global.mobs_left == 0 and not Global.key_spawned and not Global.player_can_upgrade:
		if Global.rooms_spawned==dungeon.N_ROOMS:
			Global.mobs_left += 1
			add_ladder()
		else:
			add_key(Global.dungeons_finished)

func add_enemies(room_number):
	# Don't create mobs in the final dungeon
	#if room_number+1==dungeon.N_ROOMS:
	#	Global.mobs_left += 1
	#	var ladder = Ladder.instantiate()
	#	ladder.position = dungeon.room_pos_ul[room_number] + (dungeon.ROOM_SIZE/2)
	#	ladder.position *= Global.TILE_SIZE
	#	add_child(ladder)
	#	return
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
	
func add_ladder():
	ladder = Ladder.instantiate()
	ladder.position = dungeon.room_pos_ul[-1] + (dungeon.ROOM_SIZE/2)
	ladder.position *= Global.TILE_SIZE
	ladder.z_index = 99
	add_child(ladder)
	
func climb_ladder():
	# Disable the player and hide the set
	player.process_mode = PROCESS_MODE_DISABLED
	player.get_node("Camera2D").enabled = false
	dungeon.hide()
	# Change to cutscene
	$Cutscene.z_index = 100
	$Cutscene.get_node("Camera2D").enabled = true
	$Cutscene.show()
	
func add_random_villager():
	var new_villager = Villager.instantiate()
	var random_type = randi()%100
	if random_type<80:
		new_villager.villager_type="REGULAR"
	elif random_type<95:
		new_villager.villager_type="LEGS"
	else:
		new_villager.villager_type="ARMS"
	var random_room = randi()%(50+dungeon.N_ROOMS)
	if random_room<dungeon.N_ROOMS:
		new_villager.global_position = dungeon.room_pos_ul[random_room]+dungeon.ROOM_SIZE/2
	else:
		new_villager.global_position = dungeon.room_pos_ul[-1]+dungeon.ROOM_SIZE/2
	new_villager.global_position += Vector2(randi_range(-2,2), randi_range(-2,2))
	new_villager.global_position *= Global.TILE_SIZE
	add_child(new_villager)

func begin_phase2():
	# Unlock everything
	$Cutscene.get_node("Camera2D").enabled = false
	$Cutscene.hide()
	dungeon.show()
	player.process_mode = PROCESS_MODE_INHERIT
	player.get_node("Camera2D").enabled = true
	
	player.give_player_position()
	# Start making waves of villagers
	for i in range(100):
		if Global.game_end:
			break
		var new_villager_timeout = randf_range(0.5, 5^(i/100))
		await get_tree().create_timer(new_villager_timeout).timeout
		add_random_villager()
	Global.game_end = true
	print("End of game")

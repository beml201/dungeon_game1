extends Node2D

# Static Dungeon MetaData
const N_ROOMS := 5
const ROOM_SIZE := Vector2i(10,10)
const DIRECTIONS := [Vector2i(1,0),
					 Vector2i(-1,0),
					 Vector2i(0, 1),
					 Vector2i(0, -1)]

# Generated Dungeon MetaData
@onready var tiles: TileMapLayer = $RoomMap
var generated_rooms: Array = []
# Used in draw_corridor()
var room_pos_ul: Array = []
# Give the positions of wherecorridors are
var corridor_pos_average: Array = []

# Called when the node enters the scene tree for the first time.
func _ready():
	# Listen for mushroom signal to tell it to draw the corridors
	Global.connect("magic_mushroom", _on_magic_mushroom)
	
	# Generate a room order so we can identify which corridors to draw and when
	generated_rooms = generate_room_order()
	print(generated_rooms)
	var first_room := true
	for room in generated_rooms[0]:
		var room_ul := Vector2i((room[0]*ROOM_SIZE[0]),
								(room[1]*ROOM_SIZE[1]))
		room_pos_ul.append(room_ul)
		draw_room(room_ul, ROOM_SIZE[0], ROOM_SIZE[1])
		# Add the mushrooms
		var mushroom_types := []
		if first_room:
			mushroom_types = ["EMBIGGEN", "ENLARGEN"]
			first_room = false
		else:
			mushroom_types = [Global.UPGRADE_OPTIONS.slice(2,10).pick_random()]
			mushroom_types.append(Global.UPGRADE_OPTIONS.slice(2,10).pick_random())
		# Don't add musrooms to the last room
		if room!=generated_rooms[0][-1]:
			add_mushrooms(room_ul, ROOM_SIZE[0], ROOM_SIZE[1], mushroom_types)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_magic_mushroom(event):
	Global.dungeons_finished += 1
	draw_corridor(Global.dungeons_finished)
	Global.emit_signal("create_enemies",Global.dungeons_finished)
	
func draw_room(coord_upperleft, width, height):
	const atlas := Global.BASE_TILE_DICT
	var cells := []
	for y in range(height):
		for x in range(width):
			cells.append(Vector2i(x+coord_upperleft[0], y+coord_upperleft[1]))

	# Name the atlas location of the tile to use
	var cell_tiles := []
	cell_tiles.append(atlas['ul'])
	for x in range(width-2):
		cell_tiles.append(atlas['um'])
	cell_tiles.append(atlas['ur'])
	for y in range(height-2):
		cell_tiles.append(atlas['ml'])
		for x in range(width-2):
			cell_tiles.append(atlas['mm'])
		cell_tiles.append(atlas['mr'])
	cell_tiles.append(atlas['bl'])
	for x in range(width-2):
		cell_tiles.append(atlas['bm'])
	cell_tiles.append(atlas['br'])
	
	# Print all the tiles
	for i in range(cells.size()):
		tiles.set_cell(cells[i], 1, cell_tiles[i])
	
func generate_room_order() -> Array:
	var init := Vector2i(0,0)
	var rooms := [init]
	var direction_history := [init]
	for i in range(N_ROOMS-1):
		var new_room = rooms.pick_random()
		var new_room_direction = DIRECTIONS[randi()%4]
		new_room += new_room_direction
		while new_room in rooms:
			new_room = rooms.pick_random()
			new_room_direction = DIRECTIONS[randi()%4]
			new_room += new_room_direction
		rooms.append(new_room)
		direction_history.append(new_room_direction)
	return [rooms, direction_history]
	
func draw_corridor(n_events):
	if n_events >= generated_rooms[1].size():
		return
	# Create corridor from new room to old room
	var which_side = generated_rooms[1][n_events]*Vector2i(-1,-1)
	# Navigate the corridor to the correct position
	var corridor_pos := [which_side + Vector2i(1,1)]
	# Standardise to world
	corridor_pos[0] = room_pos_ul[n_events] + corridor_pos[0]*(ROOM_SIZE+Vector2i(-1,-1))/2
	# Add the other positions
	corridor_pos.append(corridor_pos[0]+Vector2i(which_side))
	var tile_below := Vector2i(abs(which_side[1]), abs(which_side[0]))
	corridor_pos.append(corridor_pos[0]+tile_below)
	corridor_pos.append(corridor_pos[1]+tile_below)
	
	# Code to select the correct tiles
	var alt_tile_order = []
	if which_side==Vector2i(1, 0):
		alt_tile_order = [1,3,0,2]
	elif which_side==Vector2i(-1, 0):
		alt_tile_order = [3,1,2,0]
	elif which_side==Vector2i(0, -1):
		alt_tile_order = [6,4,7,5]
	elif which_side==Vector2i(0,1):
		alt_tile_order = [4,6,5,7]
		
	var average_corridor_position = Vector2i(0, 0)
	for i in range(corridor_pos.size()):
		tiles.set_cell(corridor_pos[i], 0, Vector2i(0,0), alt_tile_order[i])
		average_corridor_position += corridor_pos[i]
	# Update where the bridge positions are
	corridor_pos_average.append(Vector2(average_corridor_position)/4)

func add_mushrooms(coord_upperleft, room_width, room_height, types=['EMBIGGEN']):
	for i in range(types.size()):
		var mushroom = preload("res://scenes/mushroom.tscn").instantiate()
		mushroom.global_position = (coord_upperleft+Vector2i(1, 1+i))*Global.TILE_SIZE
		mushroom.mushroom_type = types[i]
		add_child(mushroom)

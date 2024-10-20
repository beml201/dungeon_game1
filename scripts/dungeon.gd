extends Node2D

# Static Dungeon MetaData
const N_ROOMS := 6
const ROOM_SIZE := Vector2i(10,10)
const CORRIDOR_LENGTH = 5
const DIRECTIONS := [Vector2i(1,0),
					 Vector2i(-1,0),
					 Vector2i(0, 1),
					 Vector2i(0, -1)]
const TILE_DICT := {"ul":Vector2i(0,0), "ml":Vector2i(0,1), "bl":Vector2i(0,2),
					"um":Vector2i(1,0), "mm":Vector2i(1,1), "bm":Vector2i(1,2),
					"ur":Vector2i(2,0), "mr":Vector2i(2,1), "br":Vector2i(2,2)}

# Generated Dungeon MetaData
@onready var tiles: TileMapLayer = $RoomMap
var generated_rooms: Array = []
# Used in draw_corridor()
var room_pos_ul: Array = []

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
			mushroom_types = [Global.UPGRADE_OPTIONS[0], Global.UPGRADE_OPTIONS[0]]
			first_room = false
		else:
			mushroom_types = [Global.UPGRADE_OPTIONS.pick_random(), Global.UPGRADE_OPTIONS.pick_random()]
		# Don't add musrooms to the last room
		if room!=generated_rooms[0][-1]:
			add_mushrooms(room_ul, ROOM_SIZE[0], ROOM_SIZE[1], mushroom_types)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func _on_magic_mushroom():
	Global.dungeons_finished += 1
	draw_corridor(Global.dungeons_finished)
	
func draw_room(coord_upperleft, width, height):
	var cells := []
	for y in range(height):
		for x in range(width):
			cells.append(Vector2i(x+coord_upperleft[0], y+coord_upperleft[1]))

	# Generate the tile look
	var cell_tiles := []
	cell_tiles.append(TILE_DICT['ul'])
	for x in range(width-2):
		cell_tiles.append(TILE_DICT['um'])
	cell_tiles.append(TILE_DICT['ur'])
	for y in range(height-2):
		cell_tiles.append(TILE_DICT['ml'])
		for x in range(width-2):
			cell_tiles.append(TILE_DICT['mm'])
		cell_tiles.append(TILE_DICT['mr'])
	cell_tiles.append(TILE_DICT['bl'])
	for x in range(width-2):
		cell_tiles.append(TILE_DICT['bm'])
	cell_tiles.append(TILE_DICT['br'])
	
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
	# Create corridor from new room to old room
	var which_side = generated_rooms[1][n_events]*Vector2i(-1,-1)
	# Navigate the corridor to the right position
	var corridor_pos = (which_side + Vector2i(1,1))
	# Standardise to world
	corridor_pos = room_pos_ul[n_events] + corridor_pos*(ROOM_SIZE+Vector2i(-1,-1))/2
	# Add the other end
	var cp2 = corridor_pos+Vector2i(which_side)
	
	tiles.set_cell(corridor_pos, 1, TILE_DICT['mm'])
	tiles.set_cell(cp2, 1, TILE_DICT['mm'])
	
func add_mushrooms(coord_upperleft, room_width, room_height, types=['EMBIGGEN']):
	for i in range(types.size()):
		var mushroom = preload("res://scenes/mushroom.tscn").instantiate()
		mushroom.global_position = (coord_upperleft+Vector2i(1+i, 1))*Global.TILE_SIZE
		mushroom.mushroom_type = types[i]
		add_child(mushroom)

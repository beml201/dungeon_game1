extends Node2D

const N_ROOMS := 5
const ROOM_SIZE := Vector2i(10,14)
const DIRECTIONS := [Vector2i(1,0),
					 Vector2i(-1,0),
					 Vector2i(0, 1),
					 Vector2i(0, -1)]

@onready var tiles: TileMap = $TileMapLayer

# Called when the node enters the scene tree for the first time.
func _ready():
	generate_room_order()
	tile_room()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
func tile_room():
	var tile_dict := {
		"CORNER_TOP_LEFT":Vector2i(0,0),
		"SIDE_LEFT":Vector2i(0,1),
		"CORNER_BOTTOM_LEFT":Vector2i(0,2),
		"CORNER_TOP_RIGHT":Vector2i(2,0),
		"SIDE_RIGHT":Vector2i(2,1),
		"CORNER_BOTTOM_RIGHT":Vector2i(2,2),
		"TOP":Vector2i(1,0),
		"MIDDLE":Vector2i(1,1),
		"BOTTOM":Vector2i(1,2)
	}
	
	var cells := []
	# Add left side
	tiles.set_cell(0, Vector2i(0,0), 2, tile_dict["CORNER_TOP_LEFT"])
	tiles.set_cell(0, Vector2i(0, ROOM_SIZE[1]), 2, tile_dict["CORNER_BOTTOM_LEFT"])
	for y in range(ROOM_SIZE[1]-1):
		tiles.set_cell(0, Vector2i(0, y+1), 2, tile_dict["SIDE_LEFT"])
	
	# Add right side
	tiles.set_cell(0, Vector2i(ROOM_SIZE[0],0), 2, tile_dict["CORNER_TOP_RIGHT"])
	tiles.set_cell(0, Vector2i(ROOM_SIZE[0], ROOM_SIZE[1]), 2, tile_dict["CORNER_BOTTOM_RIGHT"])
	for y in range(ROOM_SIZE[1]-1):
		tiles.set_cell(0, Vector2i(ROOM_SIZE[0], y+1), 2, tile_dict["SIDE_RIGHT"])
		
	# Add top
	for x in range(ROOM_SIZE[0]-1):
		tiles.set_cell(0, Vector2i(x+1, 0), 2, tile_dict["TOP"])
	for x in range(ROOM_SIZE[0]-1):
		tiles.set_cell(0, Vector2i(x+1, ROOM_SIZE[1]), 2, tile_dict["BOTTOM"])
	for x in range(ROOM_SIZE[0]-1):
		for y in range(ROOM_SIZE[1]-1):
			tiles.set_cell(0, Vector2i(x+1,y+1), 2, tile_dict["MIDDLE"])
	
	#cells := []	
	#for y in range(ROOM_SIZE[0]):
#		for x in range(ROOM_SIZE[1]):
#			cells.append(Vector2i(x, y))
#	tiles.set_cells(0, cells, 2, )
	
func generate_room_order():
	var init = Vector2i(0,0)
	var rooms = [init]
	for i in range(N_ROOMS):
		var new_room = rooms.pick_random()
		var new_room_direction = DIRECTIONS[randi()%4]
		new_room += new_room_direction
		while new_room in rooms:
			new_room = rooms.pick_random()
			new_room_direction = DIRECTIONS[randi()%4]
			new_room += new_room_direction
		rooms.append(new_room)
	print(rooms)

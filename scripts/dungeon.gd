extends Node2D

const TILE_SIZE := 64
const N_ROOMS := 5
const ROOM_SIZE := Vector2i(6,6)
const CORRIDOR_LENGTH = 5
const DIRECTIONS := [Vector2i(1,0),
					 Vector2i(-1,0),
					 Vector2i(0, 1),
					 Vector2i(0, -1)]
const TILE_DICT := {"ul":Vector2i(0,0), "ml":Vector2i(0,1), "bl":Vector2i(0,2),
					"um":Vector2i(1,0), "mm":Vector2i(1,1), "bm":Vector2i(1,2),
					"ur":Vector2i(2,0), "mr":Vector2i(2,1), "br":Vector2i(2,2)}

@onready var tiles: TileMapLayer = $RoomMap

# Called when the node enters the scene tree for the first time.
func _ready():
	print(generate_room_order())
	draw_room(Vector2i(0,0), ROOM_SIZE[0], ROOM_SIZE[1])

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	pass
	
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
	for i in range(N_ROOMS):
		var new_room = rooms.pick_random()
		var new_room_direction = DIRECTIONS[randi()%4]
		new_room += new_room_direction
		while new_room in rooms:
			new_room = rooms.pick_random()
			new_room_direction = DIRECTIONS[randi()%4]
			new_room += new_room_direction
		rooms.append(new_room)
	return rooms

extends Camera2D

var zoom_speed = 0.1

func _ready():
	# Zoom so we can't see other items
	zoom = Vector2(2, 2)

func _input(event):
	if event is InputEventMouseButton:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:
				zoom = Vector2(2, 2)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

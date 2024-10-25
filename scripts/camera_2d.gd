extends Camera2D

var zoom_speed = 0.1

func _ready():
	# Zoom so we can't see other items
	zoom = Vector2(2, 2)

func _input(event):
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

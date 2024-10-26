extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.connect("magic_mushroom", _new_label)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func _new_label(label):
	if label=="ENSEEEN":
		$Shoot.show()
	if label=="ENLEGGEN":
		$Stomp.show()

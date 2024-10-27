extends CanvasLayer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.connect("magic_mushroom", _new_label)
	Global.connect("cutscene_end", _scoreboard)
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	$Score.text = "Villagers brutally murdered: " + str(Global.villagers_killed)
	pass

func _new_label(label):
	if label=="ENSEEEN":
		$Shoot.show()
	if label=="ENLEGEN":
		$Stomp.show()
		
func _scoreboard():
	$Score.show()
	


func _on_button_pressed() -> void:
	$Sprite2D.hide()
	$Button.hide()
	get_tree().paused = false
	print("hello dungeon")

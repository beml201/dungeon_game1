extends CharacterBody2D

# MetaData

# Other variables
var in_range = false
var sprite_changed = false
var mushroom_type = 'EMBIGGEN'

func _ready():
	if mushroom_type==Global.UPGRADE_OPTIONS[0]:
		$TextBox/Label.text = "A shroom of embiggening"
		$Sprite2D.texture = load("res://assets/mush in cage.png")
	else:
		$Sprite2D.texture = load("res://assets/green mush in cage.png")
	Global.connect("player_attack", _player_interact)

	if mushroom_type==Global.UPGRADE_OPTIONS[1]:
		$TextBox/Label.text = "a shroom of enstrengthening"
		$Sprite2D.texture = load("res://assets/green mush in cage.png")
	else:
		$Sprite2D.texture = load("res://assets/mush in cage.png")
		
		
		
func _physics_process(delta: float) -> void:
	pass
	#if in_range and Global.player_current_attack and not sprite_changed:
	#	sprite_changed = true
	#	if Global.player_can_upgrade:
	#		Global.magic_mushroom.emit("EMBIGGEN")
	#		$TextBox/Label.text = "An empty cage..."
	#		$Sprite2D.texture = load("res://assets/cage.png")
	#	else:
	#		Global.magic_mushroom.emit()
	#		$TextBox/Label.text = "The caged mushroom stays caged..."
	#	Global.player_can_upgrade = false

func _player_interact(strength):
	if in_range and not sprite_changed:
		sprite_changed = true
		if Global.player_can_upgrade:
			Global.magic_mushroom.emit(mushroom_type)
			$TextBox/Label.text = "An empty cage..."
			$Sprite2D.texture = load("res://assets/cage.png")
		else:
			Global.magic_mushroom.emit("")
			$TextBox/Label.text = "The caged mushroom stays caged..."
		#Global.player_can_upgrade = false

func _on_view_body_entered(body: Node2D) -> void:
	if body.name=="sam":
		$TextBox.show()
		in_range = true
	else:
		pass
		#print(body)
	pass # Replace with function body.


func _on_view_body_exited(body: Node2D) -> void:
	if body.name=="sam":
		$TextBox.hide()
		in_range=false

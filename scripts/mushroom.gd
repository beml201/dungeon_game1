extends CharacterBody2D

# MetaData

# Other variables
var in_range = false
var sprite_changed = false
var mushroom_type = 'EMBIGGEN'
var default_text = "A shroom of embiggening"

func _ready():
	Global.connect("player_attack", _player_interact)
	if mushroom_type=="EMBIGGEN":
		default_text = "A shroom of embiggening"
		$Sprite2D.texture = load("res://assets/mush in cage.png")
	elif mushroom_type=="ENARMEN":
		default_text = "a shroom of enstrengthening"
		$Sprite2D.texture = load("res://assets/green mush in cage.png")
	$Sprite2D/Label.text = default_text
		
func _physics_process(delta: float) -> void:
	pass

func _player_interact(strength):
	if in_range and not sprite_changed:
		if Global.player_can_upgrade and not Global.key_spawned:
			sprite_changed = true
			Global.player_can_upgrade = false
			Global.magic_mushroom.emit(mushroom_type)
			default_text = "An empty cage..."
			$TextBox/Label.text = default_text
			$Sprite2D.texture = load("res://assets/cage.png")
		else:
			#Global.magic_mushroom.emit("")
			$TextBox/Label.text = "You'll need a key first"

func _on_view_body_entered(body: Node2D) -> void:
	if body.name=="sam":
		$TextBox.show()
		in_range = true

func _on_view_body_exited(body: Node2D) -> void:
	if body.name=="sam":
		$TextBox.hide()
		$TextBox/Label.text = default_text
		in_range=false

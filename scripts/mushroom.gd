extends CharacterBody2D

var in_range = false
var sprite_changed = false

func _physics_process(delta: float) -> void:
	if in_range and Global.player_current_attack and not sprite_changed:
		print("sprite change!")
		sprite_changed=true
		Global.magic_mushroom.emit()
		#$Sprite2D.texture = load("res://assets/green mush in cage.png")

func _on_view_body_entered(body: Node2D) -> void:
	if body.name=="sam":
		$TextBox/Label.text = "A shroom"
		$TextBox.show()
		in_range = true
	else:
		print(body)
	pass # Replace with function body.


func _on_view_body_exited(body: Node2D) -> void:
	if body.name=="sam":
		$TextBox.hide()
		in_range=false

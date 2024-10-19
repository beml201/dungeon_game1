extends CharacterBody2D

func _physics_process(delta: float) -> void:
	pass

func _on_view_body_entered(body: Node2D) -> void:
	if body.name=="sam":
		$TextBox/Label.text = "A shroom"
		$TextBox.show()
	else:
		print(body)
	pass # Replace with function body.


func _on_view_body_exited(body: Node2D) -> void:
	if body.name=="sam":
		$TextBox.hide()

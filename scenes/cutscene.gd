extends Node2D

var to_show = ["RichTextLabel", "Sprite2D2", "Sprite2D3", "Sprite2D4", "RichTextLabel2"]
var to_animate = ["cutscene", null, null, null, null]
var click = null
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

func _on_button_pressed() -> void:
	if to_show.size()!=0:
		var mynode = get_node(to_show[0])
		if to_animate[0]!=null:
			$AnimationPlayer.play(to_animate[0])
		#mynode.modulate.a = 0
		mynode.show()
		to_show.pop_front()
		to_animate.pop_front()
		#for i in range(10):
		#	print(i)
		#	await get_tree().create_timer(0.01).timeout
		#	mynode.modulate.a = i/10
	else:
		Global.cutscene_end.emit()
		print("Back to game...")
		#get_tree().change_scene_to_file("res://scenes/main.tscn")
	#$RichTextLabel.show()
	#$AnimationPlayer.play("cutscene")
	
	

extends CharacterBody2D

var speed = 100
var player_chase = false
var player = null

func _physics_process(delta):
	get_node ("AnimationPlayer").play("jump")
	if player_chase:
		position += (player.global_position - global_position)/speed
		

func _on_view_body_entered(body):
	player = body
	player_chase = true
	print("chasing")
	
func _on_view_body_exited(body):
	player = null
	player_chase = false
	
	

extends CharacterBody2D

var speed = 200
var player_chase = false
#var player = get_parent().get_node("sam")

func _physics_process(delta):
	get_node ("AnimationPlayer").play("jump")
	if player_chase:
		#position += (player.position - position)/speed
		
		get_node ("AnimationPlayer").play("jump")

func _on_view_area_body_entered(body):
	#player = body
	player_chase = true
	
	

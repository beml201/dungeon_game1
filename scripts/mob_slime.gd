extends CharacterBody2D

var speed = 100 +randi()%20
var player_chase = false
var player = null
var health = 100
var player_inattack_zone = false
var player_attack_cooldown
#var player_current_attack = false

func _physics_process(delta):
	get_node ("AnimationPlayer").play("jump")
	deal_with_damage()
	if player_chase:
		position += (player.global_position - global_position)/speed
		


func _on_view_body_entered(body):
	player = body
	player_chase = true
	print("chasing")
	
func _on_view_body_exited(body):
	player = null
	player_chase = false
	
func mob_slime():
	pass 


func _on_enemy_hitbox_body_entered(body):
	if body.has_method("player"):
		player_inattack_zone = true 


func _on_enemy_hitbox_body_exited(body):
	if body.has_method("player"):
		player_inattack_zone = false
		
func deal_with_damage():
	if player_inattack_zone and Global.player_current_attack == true:
		health = health - 20
		player_attack_cooldown = false
		$attack_cooldown.start()
		print(health)
		#position += (global_position - player.global_position)-2 
		print("slime health =", health)
		if health <=0:
			#get_node("AnimationPlayer").play("die")
			self.queue_free()
		

func _on_attack_cooldown_timeout() -> void:
	player_attack_cooldown = true

func _on_timer_timeout() -> void:
	pass # Replace with function body.

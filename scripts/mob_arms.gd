extends CharacterBody2D

# MetaData
var speed = 100 +randi()%20
var health := 100
var strength := 1
var attack_speed := 1.0

# Other variables
var player = null
var player_chase = false
var is_attacking = false
var in_range = false
var damaged = false
var player_attack_cooldown
var mob_direction = "left"
#var player_current_attack = false

func _ready():
	Global.connect("player_attack", _take_damage)

func _physics_process(delta):
	
	attack()
	#deal_with_damage()
	if player_chase:
		if not damaged:
			$AnimationPlayer.play("attack")
		velocity = player.global_position - global_position
		$Sprite2D.flip_h = sign(velocity[0])==-1
		move_and_slide()
		if velocity[0]>0:
			mob_direction = "right"
		elif velocity[0]<0:
			mob_direction = "left"

func _take_damage(damage):
	if in_range and Global.player_direction!=mob_direction:
		damaged = true
		$AnimationPlayer.play("damaged")
		health -= damage
		$HealthLabel.text = "Health: "+str(max(0,health))
		if health<=0:
			queue_free()
		
func attack():
	if in_range and not is_attacking:
		is_attacking = true
		Global.mob_attack.emit(strength)
		await get_tree().create_timer(attack_speed).timeout
		is_attacking = false

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _on_view_body_entered(body):
	if body.has_method("player"):
		player = body
		player_chase = true
#	print("chasing")
	
func _on_view_body_exited(body):
	if body.has_method("player"):
		player = null
		player_chase = false

func _on_enemy_hitbox_body_entered(body):
	if body.has_method("player"):
		in_range = true

func _on_enemy_hitbox_body_exited(body):
	if body.has_method("player"):
		in_range = false
		
func deal_with_damage():
	if in_range and Global.player_current_attack and Global.player_direction!=mob_direction:
		#health -= 20
		player_attack_cooldown = false
		$attack_cooldown.start()
		#position += (global_position - player.global_position) 
		$HealthLabel.text = "Health: "+str(max(0,health))
		
func _on_attack_cooldown_timeout() -> void:
	player_attack_cooldown = true
	print("arms health =", health)
	if health <=0:
	#get_node("AnimationPlayer").play("die")
		self.queue_free()


func _on_animation_player_animation_finished(anim_name):
	if anim_name == "damaged":
		damaged = false
	else:
		pass
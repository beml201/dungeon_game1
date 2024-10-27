extends CharacterBody2D

# MetaData
var speed = 100 +randi()%20
var health := 100
var strength := 1
var attack_speed := 1.0
# Finite state machine to track current state
enum {IDLE, NEW_DIR, WALK, CHASE, ATTACK, KNOCKBACK}
# Other variables
#var player_chase = false
var player = null
var is_attacking = false
var check_for_damage = false
var player_attack_cooldown
var mob_direction = "right"
var current_state = IDLE
var dir = Vector2.LEFT
var knockback_y = 0
var knockback_time := 0.3
var stun := 0.2
#var player_current_attack = false

func _ready():
	randomize()
	Global.connect("player_attack", _take_damage)

func _physics_process(delta):
	match current_state:
		IDLE: # Do Nothing
			pass
		NEW_DIR: # Pick a new direction to walk
			dir = choose([Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN])
		WALK: # Idle walk
			walk()
		CHASE: # Chase Player
			chase()
		ATTACK: # Attack Player
			attack()
		KNOCKBACK:
			knockback()
	#deal_with_damage()

func walk():
	velocity = dir * speed
	move()

func chase():
	velocity = player.global_position - global_position
	move()

func attack():
	if not is_attacking:
		is_attacking = true
		Global.mob_attack.emit(strength)
		await get_tree().create_timer(attack_speed).timeout
		is_attacking = false

func move():
	$AnimationPlayer.play("crawl")
	$Sprite2D.flip_h = sign(velocity[0])==-1
	if $Sprite2D.frame!=3:
		velocity /=20
	move_and_slide()
	if velocity[0]>0:
		mob_direction = "right"
		$body.position.x = -8
	elif velocity[0]<0:
		mob_direction = "left"
		$body.position.x = 8

func _take_damage(damage):
	if check_for_damage:
		health -= damage
		$HealthLabel.text = "Health: "+str(max(0,health))
		check_for_damage = false
		current_state = KNOCKBACK
		knockback_y = randf_range(-1, 1)
		if health<=0:
			Global.mobs_left -= 1
			queue_free()
		damage_visual()
		
func damage_visual(n_flashes=3):
	for i in range(2*n_flashes):
		var time = knockback_time/(2*n_flashes)
		await get_tree().create_timer(time).timeout
		if i%2==0:
			$Sprite2D.set_modulate(Color(1,0.2,0.2))
		else:
			$Sprite2D.set_modulate(Color(1,1,1))
			
			
func knockback():
	velocity.x = int(mob_direction=="right")*2-1
	velocity.x *= -1
	velocity.y = knockback_y
	velocity *= 2*speed
	move_and_slide()

# Picks random value from array
func choose(array):
	array.shuffle()
	return array.front()


func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _on_view_body_entered(body):
	if body.has_method("player"):
		player = body
		current_state = CHASE
		$idle.paused = true
#	print("chasing")
	
func _on_view_body_exited(body):
	if body.has_method("player"):
		player = null
		current_state = IDLE
		$idle.paused = false

func _on_enemy_hitbox_body_entered(body):
	if body.has_method("player"):
		current_state = ATTACK
	

func _on_enemy_hitbox_body_exited(body):
	if body.has_method("player"):
		# Add an additional timer if there is knockback
		if current_state==KNOCKBACK:
			await get_tree().create_timer(knockback_time).timeout
			current_state = IDLE
		await get_tree().create_timer(stun).timeout
		current_state = CHASE
		

# After 0.15 seconds, choose new state
func _on_idle_timeout():
	$idle.wait_time = choose([0.5, 1, 1.5])
	current_state = choose([IDLE, NEW_DIR, WALK])


func _on_enemy_hitbox_area_entered(area):
	if area.has_method("sword"):
		check_for_damage = true


func deal_with_damage():
	if check_for_damage and Global.player_current_attack and Global.player_direction!=mob_direction:
		#health -= 20
		player_attack_cooldown = false
		$attack_cooldown.start()
		#position += (global_position - player.global_position) 
		$HealthLabel.text = "Health: "+str(max(0,health))
		
func _on_attack_cooldown_timeout() -> void:
	player_attack_cooldown = true
	print("crawler health =", health)
	if health <=0:
	#get_node("AnimationPlayer").play("die")
		self.queue_free()


#func _on_animation_player_animation_started(anim_name: StringName) -> void:

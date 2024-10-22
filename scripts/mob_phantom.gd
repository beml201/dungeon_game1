extends CharacterBody2D

# MetaData
var speed = 100 +randi()%20
var health := 100
var strength := 1
var attack_speed := 1.0
const projectile = preload("res://scenes/phantom_projectile.tscn")
# Finite state machine to track current state
enum {
	IDLE,
	NEW_DIR,
	WALK,
	ATTACK
}
# Other variables
#var player_chase = false
var player = null
var is_attacking = false
var check_for_damage = false
var player_attack_cooldown
var mob_direction = "left"
var current_state = IDLE
var dir = Vector2.LEFT
#var player_current_attack = false

func _ready():
	randomize()
	Global.connect("player_attack", _take_damage)

func _physics_process(delta):
	match current_state:
		IDLE: # Do Nothing
			$AnimationPlayer.play("idle")
		NEW_DIR: # Pick a new direction to walk
			dir = choose([Vector2.LEFT, Vector2.RIGHT, Vector2.UP, Vector2.DOWN])
		WALK: # Idle walk
			walk()
		ATTACK: # Attack Player
			attack()
	
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
		cast()
		await get_tree().create_timer(attack_speed).timeout
		is_attacking = false

func cast():
	$AnimationPlayer.play("cast")
	var b = projectile.instantiate()
	add_child(b)
	b.global_position = $Hand.global_position
	var dir = (player.global_position - global_position).normalized()
	b.global_rotation = dir.angle() + PI /2.0
	b.direction = dir


func move():
	$AnimationPlayer.play("idle")
	$Sprite2D.flip_h = sign(velocity[0])==1
	move_and_slide()
	if velocity[0]>0:
		mob_direction = "right"
	elif velocity[0]<0:
		mob_direction = "left"

func _take_damage(damage):
	if check_for_damage:
		health -= damage
		$HealthLabel.text = "Health: "+str(max(0,health))
		check_for_damage = false
		if health<=0:
			queue_free()

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
		current_state = ATTACK
		$idle.paused = true
#	print("chasing")
	
func _on_view_body_exited(body):
	if body.has_method("player"):
		player = null
		current_state = IDLE
		$idle.paused = false

func _on_enemy_hitbox_body_entered(body):
	if body.has_method("player"):
		pass
		#current_state = ATTACK
	

func _on_enemy_hitbox_body_exited(body):
	if body.has_method("player"):
		pass
		#current_state = CHASE
		

# After 0.15 seconds, choose new state
func _on_idle_timeout():
	$idle.wait_time = choose([0.5, 1, 1.5])
	current_state = choose([IDLE, NEW_DIR, WALK])


func _on_enemy_hitbox_area_entered(area):
	if area.has_method("sword"):
		check_for_damage = true

func phantom():
	pass






func deal_with_damage():
	if check_for_damage and Global.player_current_attack and Global.player_direction!=mob_direction:
		#health -= 20
		player_attack_cooldown = false
		$attack_cooldown.start()
		#position += (global_position - player.global_position) 
		$HealthLabel.text = "Health: "+str(max(0,health))
		
func _on_attack_cooldown_timeout() -> void:
	player_attack_cooldown = true
	print("slime health =", health)
	if health <=0:
	#get_node("AnimationPlayer").play("die")
		self.queue_free()

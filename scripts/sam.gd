extends CharacterBody2D

@export var speed = 400

var mob_slime_inattack_range = false 
var mob_slime_attack_cooldown = true
var health = 100
var player_alive = true
var attack_ip = false
#var player_current_attack = false

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed
	if velocity != Vector2(0,0):
		get_node("AnimationPlayer").play("walking")
	else:
		get_node("AnimationPlayer").stop()
	
func _physics_process(delta):
	get_input()
	move_and_slide()
	mob_slime_attack()
	if health <= 0:
		player_alive = false
		health = 0
		print ("you died")
		self.queue_free()
	
func _input(event):
	if event is InputEventMouseButton:
		Global.player_current_attack = true
		get_node("AnimationPlayer").play("slash")
		
#func attack():
	#if Input.is_action_just_pressed("attack"):
		#player_current_attack = true
	
func player():
	pass

func _on_hit_box_body_entered(body):
	if body.has_method("mob_slime"):
		mob_slime_inattack_range = true


func _on_hit_box_body_exited(body):
	if body.has_method("mob_slime"):
		mob_slime_inattack_range = false
		
func mob_slime_attack():
	if mob_slime_inattack_range and mob_slime_attack_cooldown == true:
		health = health - 20
		mob_slime_attack_cooldown = false
		$attack_cooldown.start()
		print(health)


func _on_attack_cooldown_timeout() -> void:
	mob_slime_attack_cooldown = true

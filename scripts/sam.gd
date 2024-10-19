extends CharacterBody2D

@export var speed = 400

var mob_slime_inattack_range = false 
var mob_slime_attack_cooldown = true
var health = 100
var player_alive = true

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	velocity = input_direction * speed

func _physics_process(delta):
	get_input()
	move_and_slide()
	mob_slime_attack()
	
func _input(event):
	if event is InputEventMouseButton:
		get_node("AnimationPlayer").play("slash")
		print("attack") 
	
	
func player():
	pass

func _on_hit_box_body_entered(body: Node2D) -> void:
	if body.has_method("mob_slime"):
		mob_slime_inattack_range = true


func _on_hit_box_body_exited(body: Node2D) -> void:
	if body.has_method("mob_slime"):
		mob_slime_inattack_range = false
		
func mob_slime_attack():
	if mob_slime_inattack_range:
		print("player took damage")

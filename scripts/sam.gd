extends CharacterBody2D

# MetaData
@export var speed = 400
var health := 100
var strength := 20

# Other variables
var mob_slime_inattack_range = false 
var mob_slime_attack_cooldown = true
var player_alive = true
var attack_ip = false
var is_big = false
var is_attacking = false
#var player_current_attack = false
#@onready var SpriteChange = load("res://scenes/mushroom.tscn").instantiate()
func _ready() -> void:
	print("READY!")
	Global.connect("mob_attack", _take_damage)
	Global.connect("magic_mushroom", _on_spritechange)
#	SpriteChange.spritechange.connect(_on_spritechange)
func _take_damage(damage):
	health -= damage
	$HealthLabel.text = "Health: "+str(max(0,health))
	if health<=0:
		queue_free()
		print("DEATH!!!")
	
func _on_spritechange(event):
	if event=="EMBIGGEN":
		$Sprite2D.texture = load("res://assets/animations/lil dude walking.png")
		$body.position.x = -14.75
		$body.position.y = 4.75
		$body.shape.size.x = 28.5
		$body.shape.size.y = 53.5
		$hit_box/CollisionShape2D.position.x = -9.158
		$hit_box/CollisionShape2D.position.y = 7.969
		$hit_box/CollisionShape2D.shape.radius = 13.5
		$Sprite2D/SwordHit/sword.shape.size.x = 29
		$Sprite2D/SwordHit/sword.shape.size.y = 32
		$Sprite2D/SwordHit/sword.position.x = 18.5
		$Sprite2D/SwordHit/sword.position.y = 0
		is_big = true
	else:
		$Arm.show()

	
func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	if input_direction[0] < 0:
		Global.player_direction = "left"
		$Sprite2D.flip_h = true
		if is_big:
			$Sprite2D.position.x = -30
			$Sprite2D/SwordHit/sword.position.x = -18
		else:
			$Sprite2D.position.x = -39
			$Sprite2D/SwordHit/sword.position.x = -10
	if input_direction[0] > 0:
		Global.player_direction = "right"
		$Sprite2D.flip_h = false
		$Sprite2D.position.x = 0
		if is_big:
			$Sprite2D/SwordHit/sword.position.x = 18.5
		else:
			$Sprite2D/SwordHit/sword.position.x = 9
	# Animation code
	velocity = input_direction * speed
	if not is_attacking:
		if velocity != Vector2(0,0):
			$Basic_Animations.play("walking")
		else:
			$Basic_Animations.stop()
	#if is_attacking:
	#	$Basic_Animations.play("walking-slash")
		#if Global.player_current_attack == true or is_attacking:
			#get_node("Basic_Animations").play("walking-slash")
			#$attack_duration.start()
		#else:
		#	get_node("Basic_Animations").play("walking")
	#elif Global.player_current_attack == false:
	#	get_node("Basic_Animations").stop()
	
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
	if event.is_action("attack") and not is_attacking:
		is_attacking = true
		Global.player_attack.emit(strength)
		$Basic_Animations.play("walking-slash")
		#print('attack')
	#if event is InputEventMouseButton and Global.player_can_attack:
		#Global.player_current_attack = true
		#Global.player_can_attack = false
	#	get_node("Basic_Animations").play("slash")
	#	print("attacking")
		#$attack_duration.start()
		
		
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


func _on_attack_duration_timeout() -> void:
	Global.player_current_attack = false
	Global.player_can_attack = true 
	#get_node("AnimationPlayer").play("walking")
	#print("not attacking")


func _on_animation_player_animation_finished(anim_name):
	#print(anim_name)
	if anim_name == "slash" or anim_name == "walking-slash":
		is_attacking = false
		Global.player_current_attack = false
		Global.player_can_attack = true 
		#print("player_can_attack")
	else:
		return

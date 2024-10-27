extends CharacterBody2D

# MetaData
@export var speed = 400
var health := 100
var strength := 10

# Other variables
var player_upgrades := []
var mob_slime_inattack_range = false 
var mob_slime_attack_cooldown = true
var player_alive = true
var attack_ip = false
var is_attacking = false
var animation_melee = null
var animation_walk = null
var animation_shoot = null
var stomp = null
const Projectile = preload("res://scenes/projectile.tscn")
func player():
	pass

#var player_current_attack = false
#@onready var SpriteChange = load("res://scenes/mushroom.tscn").instantiate()
func _ready() -> void:
	print("READY!")
	Global.connect("mob_attack", _take_damage)
	Global.connect("magic_mushroom", _on_spritechange)
	#_load_small_sam()
	animation_melee = $Basic_Animations
	animation_walk = $Basic_Animations
	$Stomp/CollisionShape2D.disabled = true
	#print($Stomp/CollisionShape2D.disabled)

#func _load_small_sam():
#	$body.shape = $SamSmall/CollisionShape2D.shape
	#$body.position = $SamSmall/CollisionShape2D.position
	#$hit_box/CollisionShape2D.shape = $SamSmall/HitBox/CollisionShape2D.shape
	#$hit_box/CollisionShape2D.position = $SamSmall/HitBox/CollisionShape2D.position
	#$hit_box/CollisionShape2D.scale = $SamSmall/HitBox/CollisionShape2D.scale
#	SpriteChange.spritechange.connect(_on_spritechange)

func _load_embiggened_sam():
	$SamSmall.hide()
	$SamEmbiggened.show()
	strength += 5
	animation_melee = $SamEmbiggened/Animations
	animation_walk = $SamEmbiggened/Animations
	
func _load_arm():
	$Arm.show()
	animation_melee = $Arm/Arm_Animations
	strength += 10
	$SamEmbiggened/Sprite2D.texture = load("res://assets/animations/lil dude ahhh my arm.png")
	
func _load_eye():
	$Eye.show()
	
func _load_hawkeye():
	$HawkEye.show()
	$Camera2D.zoom = Vector2(1.5, 1.5)
	
func _load_fastleg():
	$FastLeg.show()
	speed += 100
	
func _load_stomp():
	$Stomp.show()
	$Stomp/CollisionShape2D.disabled = true
	$Stomp/CollisionShape2D/Sprite2D.hide()
	
func _load_shield():
	$Shield.show()
	$Shield/Shield_Animations.play("static")
	health += 50
	$HealthLabel.text = "Health: "+str(max(0,health))
	
func _take_damage(damage):
	if "ENSHIELD" in player_upgrades:
		damage = max(1, floorf(damage*0.5))
	health -= damage
	damage_visual()
	$HealthLabel.text = "Health: "+str(max(0,health))
	if health<=0:
		Global.game_end = true
		queue_free()
		
func damage_visual(n_flashes=2):
	for i in range(2*n_flashes):
		var time = 0.5/(2*n_flashes)
		await get_tree().create_timer(time).timeout
		for sprite in get_tree().get_nodes_in_group("sam_sprites"):
			if i%2==0:
				sprite.set_modulate(Color(1,0.2,0.2))
			else:
				sprite.set_modulate(Color(1,1,1))

func _on_spritechange(event):
	player_upgrades.append(event)
	match event:
		"EMBIGGEN":
			_load_embiggened_sam()
		"ENLARGEN":
			_load_embiggened_sam()
		"ENARMEN":
			_load_arm()
		"ENSEEEN":
			_load_eye()
		"ENLIGHTEN":
			_load_hawkeye()
		"ENSPEEDEN":
			_load_fastleg()
		"ENLEGEN":
			_load_stomp()
		"ENSHIELD":
			_load_shield()

func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	if input_direction[0] < 0 and Global.player_direction=="right":
		Global.player_direction = "left"
		self.scale.x = -1
		$HealthLabel.scale.x = -1
		$HealthLabel.position.x = abs($HealthLabel.position.x)
	if input_direction[0] > 0 and Global.player_direction=="left":
		Global.player_direction = "right"
		self.scale.x = -1
		$HealthLabel.scale.x = 1
		$HealthLabel.position.x = -1*abs($HealthLabel.position.x)
	# Animation code
	velocity = input_direction * speed
	if not is_attacking:
		if velocity != Vector2(0,0):
			#$Basic_Animations.play("walking")
			animation_walk.play("walking")
			if "ENSPEEDEN" in player_upgrades:
				$FastLeg/AnimationPlayer.play("walking")
			if"ENLEGEN" in player_upgrades:
				$Stomp/Stomp_Animations.play("walking")
		else:
			#$Basic_Animations.stop()
			animation_walk.stop()
	
func _physics_process(delta):
	get_input()
	move_and_slide()
	mob_slime_attack()
	if health <= 0:
		player_alive = false
		health = 0
		Global.game_end = true
		print ("you died")
		self.queue_free()
		
	
func _input(event):
	if event.is_action("attack") and not is_attacking:
		is_attacking = true
		#$Basic_Animations.play("walking-slash")
		animation_melee.play("slash")
		#Global.player_attack.emit(strength)
	if event.is_action("stomp") and not is_attacking and "ENLEGEN" in player_upgrades:
		is_attacking = true
		$Stomp/Stomp_Animations.play("Stomp")
		$Stomp/CollisionShape2D/Sprite2D.show()
		
		
	if event.is_action("shoot") and not is_attacking and "ENSEEEN" in player_upgrades:
		is_attacking = true
		var projectile = Projectile.instantiate()
		projectile.global_position = $Eye.global_position
		$Eye/Eye_Animations.play("attack")
		get_parent().add_child(projectile)
		await get_tree().create_timer(0.4).timeout
		is_attacking = false 

func _on_stomp_animations_animation_finished(anim_name: StringName) -> void:
	if anim_name == "Stomp":
		$Stomp/CollisionShape2D/Sprite2D.hide()
		await get_tree().create_timer(1).timeout
		is_attacking = false
		

func _on_hit_box_body_entered(body):
	if body.has_method("mob_slime"):
		mob_slime_inattack_range = true

func _on_hit_box_body_exited(body):
	if body.has_method("mob_slime"):
		mob_slime_inattack_range = false
		
func _on_stomp_body_entered(body):
	#print(body)
	#print($Stomp/CollisionShape2D.disabled)
	if body.has_method("_take_damage") and not body.has_method("player"):
		body.check_for_damage = true
		body._take_damage(20)

		
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

func _on_animation_player_animation_finished(anim_name):
	if anim_name == "slash" or anim_name == "walking-slash":
		is_attacking = false
		Global.player_current_attack = false
		Global.player_can_attack = true 
		Global.player_attack.emit(strength)

func _on_arm_animations_animation_finished(anim_name: StringName) -> void:
	$Arm/Arm_Animations.play("static")
	pass # Replace with function body.
	
func _on_eye_animations_animation_finished(anim_name: StringName) -> void:
	$Eye/Eye_Animations.play("static")
	pass # Replace with function body.
	
func _on_fast_leg_animation_animation_finished(anim_name: StringName) -> void:
	$FastLeg/AnimationPlayer.play("static")
	pass
	
func give_player_position():
	while Global.villagers_killed!=Global.MAX_VILLAGERS_KILLED and not Global.game_end:
		await get_tree().create_timer(0.5).timeout
		Global.log_player_position.emit(self.global_position)

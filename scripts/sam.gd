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
var animation_melee = null
var animation_walk = null
var animation_shoot = null
const Projectile = preload("res://scenes/projectile.tscn")

#var player_current_attack = false
#@onready var SpriteChange = load("res://scenes/mushroom.tscn").instantiate()
func _ready() -> void:
	print("READY!")
	Global.connect("mob_attack", _take_damage)
	Global.connect("magic_mushroom", _on_spritechange)
	#_load_small_sam()
	animation_melee = $Basic_Animations
	animation_walk = $Basic_Animations
	
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
	strength += 10
	animation_melee = $SamEmbiggened/Animations
	animation_walk = $SamEmbiggened/Animations
	
func _load_arm():
	$Arm.show()
	animation_melee = $Arm/Arm_Animations
	strength += 20
	$SamEmbiggened/Sprite2D.texture = load("res://assets/animations/lil dude ahhh my arm.png")
	
func _load_eye():
	$Eye.show()
	

	
func _take_damage(damage):
	health -= damage
	$HealthLabel.text = "Health: "+str(max(0,health))
	if health<=0:
		queue_free()
		print("DEATH!!!")
	


func _on_spritechange(event):
	if event=="EMBIGGEN":
		_load_embiggened_sam()
		#$Sprite2D.texture = load("res://assets/animations/lil dude walking.png")
		#$body.pos$Node2Dition.x = -14.75
		#$body.position.y = 4.75
		#$body.shape.size.x = 28.5
		#$body.shape.size.y = 53.5
		#$hit_box/CollisionShape2D.position.x = -9.158
		#$hit_box/CollisionShape2D.position.y = 7.969
		#$hit_box/CollisionShape2D.shape.radius = 13.5
		#$Sprite2D/SwordHit/sword.shape.size.x = 29
		#$Sprite2D/SwordHit/sword.shape.size.y = 32
		#$Sprite2D/SwordHit/sword.position.x = 18.5
		#$Sprite2D/SwordHit/sword.position.y = 0
		is_big = true
	else:
		_load_arm()
		


	
func get_input():
	var input_direction = Input.get_vector("left", "right", "up", "down")
	if input_direction[0] < 0 and Global.player_direction=="right":
		Global.player_direction = "left"
		self.scale.x = -1
		#$Sprite2D.flip_h = true
		if is_big:
			pass
		#	$Sprite2D.position.x = -30
		#	$Sprite2D/SwordHit/sword.position.x = -18
		else:
			pass
			#$Sprite2D.position.x = -39
		#	$Sprite2D/SwordHit/sword.position.x = -10
	if input_direction[0] > 0 and Global.player_direction=="left":
		Global.player_direction = "right"
		self.scale.x = -1
		#$Sprite2D.flip_h = false
		#$Sprite2D.position.x = 0
		if is_big:
			pass
			#$Sprite2D/SwordHit/sword.position.x = 18.5
		else:
			pass
			#$Sprite2D/SwordHit/sword.position.x = 9
	# Animation code
	velocity = input_direction * speed
	if not is_attacking:
		if velocity != Vector2(0,0):
			#$Basic_Animations.play("walking")
			animation_walk.play("walking")
		else:
			#$Basic_Animations.stop()
			animation_walk.stop()
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
		#$Basic_Animations.play("walking-slash")
		animation_melee.play("slash")
		Global.player_attack.emit(strength)
		
	if event.is_action("shoot") and not is_attacking:
		is_attacking = true
		var projectile = Projectile.instantiate()
		projectile.global_position = $Eye.global_position
		get_parent().add_child(projectile)
		await get_tree().create_timer(0.1).timeout
		is_attacking = false 
		#print('attack')
	#if event is InputEventMouseButton and Global.player_can_attack:
		#Global.player_current_attack = true
		#Global.player_can_attack = false
	#	get_node("Basic_Animations").play("slash")
	#	print("attacking")
		#$attack_duration.start()
		#for strategy in player.upgrades:
		#	strategy.apply_upgrade(SamUpgrades)
			
			
			
		
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

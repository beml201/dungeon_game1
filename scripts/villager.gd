extends CharacterBody2D

# MetaData
var speed := 200 +randi()%20
var health := 50
var strength := 10
var attack_speed := 3
var knockback_time := 0.5
var stun := 2
const MAX_PLAYER_POSITIONS := 5
const villager_types := ["REGULAR", "ARMS", "LEGS"]
var villager_type := "REGULAR"

# Other variables
enum { IN_RANGE, IN_VIEW, KNOCKBACK, LONG_FOLLOW }
var current_state = LONG_FOLLOW
var can_attack := false
var check_for_damage := false
var player = null
var villager_direction = "right"
var player_positions := []
var villager_sprite = null
var villager_animation = null
var knockback_y = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.connect("player_attack", _take_damage)
	Global.connect("log_player_position", _log_player_position)
	# Decide what kind of villager you are
	match villager_type:
		"REGULAR":
			villager_sprite = $Regular/Sprite/Sprite2D
			villager_animation = $Regular/AnimationPlayer
		"ARMS":
			villager_sprite = $Arms/Sprite/Sprite2D
			villager_animation = $Arms/AnimationPlayer
			$Arms.show()
			attack_speed = 0.5
			knockback_time = 1.0
			$Regular.hide()
		"LEGS":
			villager_sprite = $Legs/Sprite/Sprite2D
			villager_animation = $Legs/AnimationPlayer
			$Legs.show()
			speed += 100
			strength += 10
			attack_speed = 1.0
			$Regular.hide()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	match current_state:
		IN_VIEW:
			villager_animation.play("walk")
			walk_directly_to_player()
		IN_RANGE:
			attack()
		KNOCKBACK:
			knockback()
		LONG_FOLLOW:
			villager_animation.play("walk")
			track_player()

func flip_sprite():
	var direction = ""
	if sign(velocity.x)==-1:
		direction = "left"
	elif sign(velocity.x)==1:
		direction = "right"
		
	if direction!=villager_direction and direction!="":
		self.scale.x = -1
		villager_direction = direction
	
	match direction:
		"left":
			$HealthLabel.scale.x = -1
			$HealthLabel.position.x = abs($HealthLabel.position.x)
		"right":
			$HealthLabel.scale.x = 1
			$HealthLabel.position.x = -1*abs($HealthLabel.position.x)

func track_player():
	for pos in player_positions:
		if pos.distance_squared_to(global_position)<9:
			player_positions.pop_front()
		if player_positions.size()>0:
			velocity = (player_positions[0]-global_position).normalized()
			velocity *= speed/4
			flip_sprite()
			move_and_slide()

func walk_directly_to_player():
	player_positions = []
	velocity = (player.global_position-global_position).normalized()
	velocity *= speed/4
	flip_sprite()
	move_and_slide()
	
func attack():
	if can_attack:
		can_attack = false
		if "attack" in villager_animation.get_animation_list():
			villager_animation.play("attack")
		Global.mob_attack.emit(strength)
		await get_tree().create_timer(attack_speed).timeout
		can_attack = true

func knockback():
	velocity.x = sign((player.global_position-global_position).x)
	velocity.x *= -1
	velocity.y = knockback_y
	velocity *= speed
	move_and_slide()

func damage_visual(n_flashes=3):
	for i in range(2*n_flashes):
		var time = knockback_time/(2*n_flashes)
		await get_tree().create_timer(time).timeout
		if i%2==0:
			villager_sprite.set_modulate(Color(1,0.2,0.2))
		else:
			villager_sprite.set_modulate(Color(1,1,1))
			
func _take_damage(damage):
	if check_for_damage:
		check_for_damage = false
		# Damage
		health -= damage
		$HealthLabel.text = "Health: "+str(max(0,health))
		if health<=0:
			Global.villagers_killed += 1
			queue_free()
		# Allow damage to be taken again
		current_state = KNOCKBACK
		knockback_y = randf_range(-1, 1)
		# Show that the mob has taken damage
		damage_visual()
	
func _log_player_position(player_position):
	player_positions.append(player_position)
	if player_positions.size()>MAX_PLAYER_POSITIONS:
		player_positions.pop_front()

func _on_view_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		current_state = IN_VIEW
		player = body

func _on_view_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		current_state = LONG_FOLLOW

func _on_hitbox_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		current_state = IN_RANGE
		can_attack = true

func _on_hitbox_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		# Add an additional timer if there is knockback
		if current_state==KNOCKBACK:
			await get_tree().create_timer(knockback_time).timeout
			current_state = null
			# Wait a bit so the player can get away
			await get_tree().create_timer(stun).timeout
			current_state = LONG_FOLLOW

func _on_hitbox_area_entered(area: Area2D) -> void:
	if area.has_method("sword"):
		check_for_damage = true

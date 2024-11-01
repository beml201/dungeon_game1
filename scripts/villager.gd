extends CharacterBody2D

# MetaData
var speed := 200 +randi()%100
var health := 50
var strength := 10
var attack_speed := 2
var knockback_time := 0.5
var stun := 1
const MAX_PLAYER_POSITIONS := 6
const villager_types := ["REGULAR", "ARMS", "LEGS"]
var villager_type := "REGULAR"
var corridor_positions := []

# Other variables
enum { IN_RANGE, IN_VIEW, KNOCKBACK, LONG_FOLLOW }
var current_state = null
var can_attack := false
var check_for_damage := false
var player = null
var villager_direction = "right"
var player_positions := []
var villager_sprite = null
var villager_animation = null
var knockback_y = 0
var spawn_wait = true

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.connect("player_attack", _take_damage)
	Global.connect("log_player_position", _log_player_position)
	# Decide what kind of villager you are
	match villager_type:
		"REGULAR":
			# Swap sprites randomly for teh regular villager
			if randi()%2==1:
				$Regular/Sprite/Sprite2D.texture = load("res://assets/animations/villager normal2.png")
			villager_sprite = $Regular/Sprite/Sprite2D
			villager_animation = $Regular/AnimationPlayer
			$body.shape = $Regular/body.shape
			$body.scale = $Regular/body.scale
		"ARMS":
			$Regular.hide()
			villager_sprite = $Arms/Sprite/Sprite2D
			villager_animation = $Arms/AnimationPlayer
			$Arms.show()
			$body.shape = $Arms/body.shape
			$body.scale = $Arms/body.scale
			speed += 50
			health = 75
			strength = 3
			attack_speed = 0.1
			knockback_time = 0.5
			stun = 2
		"LEGS":
			$Regular.hide()
			villager_sprite = $Legs/Sprite/Sprite2D
			villager_animation = $Legs/AnimationPlayer
			$Legs.show()
			$body.shape = $Legs/body.shape
			$body.scale = $Legs/body.scale
			speed -= 100
			health = 60
			strength = 15
			attack_speed = 1
			knockback_time = 2
			stun = 2
	# Update the health label
	$HealthLabel.text = "Health: "+str(max(0,health))
	# Make it so you have a second to get away
	await get_tree().create_timer(1).timeout
	spawn_wait = false
	current_state = LONG_FOLLOW
	
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if spawn_wait:
		return
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
		if pos.distance_squared_to(global_position)<900:
			player_positions.pop_front()
			break
	if player_positions.size()>0:
		velocity = (player_positions[0]-global_position).normalized()
		velocity *= speed
		flip_sprite()
		move_and_slide()
	else:
		_add_nearest_bridge_to_player_positions()

func walk_directly_to_player():
	#player_positions = []
	if player !=null:
		velocity = (player.global_position-global_position).normalized()
		velocity *= speed/2
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
	velocity.x = int(villager_direction=="right")*2-1
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
	# If the villager hits a wall, go to the nearest bridge instead
	if body.name=="RoomMap" and len(corridor_positions)>0:
		if body.get_cell_source_id(global_position/Global.TILE_SIZE)==1:
			_add_nearest_bridge_to_player_positions(body)
			
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
		
func _add_nearest_bridge_to_player_positions(tile=null):
	var atlas_coords = Vector2(-1,-1)
	if tile!=null:
		atlas_coords = tile.get_cell_atlas_coords(global_position/Global.TILE_SIZE)
	# Find the minimum distance
	var closest_bridge_idx = 0
	if atlas_coords.y==1:
		for i in range(len(corridor_positions)):
			if abs(global_position-corridor_positions[i]).y<abs(global_position-corridor_positions[closest_bridge_idx]).y:
				closest_bridge_idx = i
	elif atlas_coords.x==1:
		for i in range(len(corridor_positions)):
			if abs(global_position-corridor_positions[i]).x<abs(global_position-corridor_positions[closest_bridge_idx]).x:
				closest_bridge_idx = i
	else:
		for i in range(len(corridor_positions)):
			if global_position.distance_squared_to(corridor_positions[i])<global_position.distance_squared_to(corridor_positions[closest_bridge_idx]):
				closest_bridge_idx = i
	# Only got to the bridge it the villager isn't already going there
	if player_positions.size()!=0:
		if player_positions[0]==corridor_positions[closest_bridge_idx]:
			return
	player_positions.insert(0, corridor_positions[closest_bridge_idx])

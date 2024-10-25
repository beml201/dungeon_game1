extends CharacterBody2D

var speed = 400
var player = null
var direction = Global.player_direction
var damage = 10

func _ready():
	global_position.y += 15
	if Global.player_direction == "right":
		global_position.x += 25
	elif Global.player_direction == "left":
		position.x -= 25
		speed = -speed
		$Sprite2D.flip_h = true

func _physics_process(delta):
	move_and_slide()
	velocity.x = speed

func _on_area_2d_body_entered(body: Node2D) -> void:
	if not body.has_method("player") and body.name!="Projectile":
		if body.has_method("_take_damage"):
			body.check_for_damage = true
			body._take_damage(damage)
		queue_free()

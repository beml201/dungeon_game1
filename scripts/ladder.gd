extends Area2D


const drop_height := 3*Global.TILE_SIZE
const drop_speed := 10
var in_range = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Global.connect("player_attack", _player_interact)
	# Drop the key
	position.y -= drop_height
	for i in range(drop_speed):
		position.y += drop_height/drop_speed
		await get_tree().create_timer(0.01).timeout

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	
func _player_interact(strength):
	if in_range:
		Global.climb_ladder.emit()
		$CollisionShape2D.disabled = true
		in_range = false
	
	
func _on_body_entered(body: Node2D) -> void:
	if body.has_method("player"):
		in_range = true

func _on_body_exited(body: Node2D) -> void:
	if body.has_method("player"):
		in_range = false

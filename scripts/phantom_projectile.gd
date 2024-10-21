extends Area2D

var speed = 100
var player = null
var direction := Vector2.LEFT
var damage := 1

func _physics_process(delta):
	translate(direction*speed*delta)
	

func _on_body_entered(body):
	if body.has_method("player"):
		Global.mob_attack.emit(damage)
		queue_free()
	elif not body.has_method("phantom"):
		queue_free()

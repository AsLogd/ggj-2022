extends KinematicBody

const SPEED = 0.3

var velocity = Vector3.ZERO

func _physics_process(_delta):
	var col = move_and_collide(velocity)
	if col != null:
		queue_free()
	
func initialize(start_position, player_position):
	translation = start_position
	look_at(player_position, Vector3.UP)
	velocity = Vector3.FORWARD * SPEED
	velocity = velocity.rotated(Vector3.UP, rotation.y)

extends KinematicBody

var velocity = Vector3.ZERO
var damage = 1
var speed = 0.3

func _physics_process(_delta):
	var col = move_and_collide(velocity)
	if col != null:
		col.collider.hit(damage)
		queue_free()
	
func initialize(start_position, player_position, type):
	translation = start_position
	look_at(player_position, Vector3.UP)
	velocity = Vector3.FORWARD * speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	
	if type == 0:
		damage = 1
		speed = 0.3
	elif type == 1:
		damage = 5
		speed = 0.5

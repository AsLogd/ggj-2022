extends KinematicBody

var velocity = Vector3.ZERO
var damage = 1
var speed = 0.3

func _physics_process(_delta):
	var col = move_and_collide(velocity)
	if col != null:
		col.collider.hit(damage)
		queue_free()

func initialize(start_position, target_position, the_damage):
	translation = start_position
	look_at(target_position, Vector3.UP)
	velocity = Vector3.FORWARD * speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	damage = the_damage

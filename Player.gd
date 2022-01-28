extends KinematicBody

export (PackedScene) var player_shot_scene

# How fast the player moves in meters per second.
export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
export var fall_acceleration = 75

export var max_damage = 150
export var max_hp = 100

const SHOOT_COOLDOWN = 0.3

var current_hp = max_hp
var current_damage = 0

var velocity = Vector3.ZERO
var rng = RandomNumberGenerator.new()

var shot_cooldown = -1

var current_direction =  Vector3.ZERO

signal update_health_and_damage(new_damage, new_health)

func _physics_process(delta):
	# We create a local variable to store the input direction.
	var direction = Vector3.ZERO

	shot_cooldown -= delta

	# We check for each move input and update the direction accordingly.
	if Input.is_action_pressed("move_right"):
		direction.x += 1
	if Input.is_action_pressed("move_left"):
		direction.x -= 1
	if Input.is_action_pressed("move_back"):
		# Notice how we are working with the vector's x and z axes.
		# In 3D, the XZ plane is the ground plane.
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1
	if Input.is_action_pressed("attack"):
		if shot_cooldown <= 0:
			shot_cooldown = SHOOT_COOLDOWN
			var shot = player_shot_scene.instance()
			get_tree().get_root().add_child(shot)
			shot.initialize(translation, $Pivot.transform.origin + current_direction, current_damage)

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		current_direction = translation + direction
		$Pivot.look_at(current_direction, Vector3.UP)

	velocity.x = direction.x * speed
	velocity.z = direction.z * speed
	# Vertical velocity
	velocity.y -= fall_acceleration * delta
	# Moving the character
	velocity = move_and_slide(velocity, Vector3.UP)
	
func _process(delta):
	current_damage = max_damage * (max_hp / current_hp)
	emit_signal("update_health_and_damage", (current_hp / float(max_hp)))
	
func hit(damage):
	current_hp -= damage
	print(current_hp)

func _on_change_health_timeout():
	print("test")

func get_outside_coords():
	var mob_spawn_location = get_node("Cam/SpawnPath/SpawnLocation")
	# And give it a random offset.
	mob_spawn_location.unit_offset = randf()
	return mob_spawn_location.translation + transform.origin

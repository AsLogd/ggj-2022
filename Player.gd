extends KinematicBody

export (PackedScene) var player_shot_scene

# How fast the player moves in meters per second.
export var speed = 14
# The downward acceleration when in the air, in meters per second squared.
export var fall_acceleration = 75

export var max_damage = 150
export var heal_per_second = 3
export var max_hp = 100

# In seconds
export var dash_refresh = 5
export var dash_multiplier = 10
export var dash_duration = 0.1

const SHOOT_COOLDOWN = 0.3

var dead = true
var current_hp = max_hp
var current_damage = 0
var dash_available = true
var dash_cooldown = 0
var dash_left = 0

var velocity = Vector3.ZERO
var rng = RandomNumberGenerator.new()

var shot_cooldown = -1

var current_direction =  Vector3.ZERO

signal update_health_and_damage(new_damage, new_health)

signal dies
func _ready():
	get_node("animated_fish/RootNode/AnimationPlayer").get_animation("Take 001").set_loop(true)
	get_node("animated_fish/RootNode/AnimationPlayer").play("Take 001")

func _physics_process(delta):
	if(dead):
		return
	# We create a local variable to store the input direction.
	var direction = Vector3.ZERO
	var speed_multiplier = 1.0
	
	if not dash_available:
		dash_cooldown -= delta
		
		if dash_cooldown <= 0.0:
			dash_available = true

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

	if Input.is_action_pressed("dash") and dash_available:
		dash_cooldown = dash_refresh
		dash_left = dash_duration
		dash_available = false

	dash_left -= delta

	if dash_left >= 0.0:
		speed_multiplier = dash_multiplier
		
	if Input.is_action_pressed("attack"):
		if shot_cooldown <= 0:
			shot_cooldown = SHOOT_COOLDOWN
			var shot = player_shot_scene.instance()
			get_tree().get_root().add_child(shot)
			shot.initialize(translation, $animated_fish.transform.origin + current_direction, current_damage)

	if direction != Vector3.ZERO:
		direction = direction.normalized()
		current_direction = translation + direction
		$animated_fish.look_at(current_direction, Vector3.UP)

	velocity.x = direction.x * speed * speed_multiplier
	velocity.z = direction.z * speed * speed_multiplier
	# Vertical velocity
	velocity.y -= fall_acceleration * delta
	# Moving the character
	velocity = move_and_slide(velocity, Vector3.UP)
	
	speed_multiplier = 1.0
	
func _process(delta):
	if(dead):
		return
		
	if(current_hp <= 0):
		current_hp = 0
		print("Player dies")
		dead = true
		emit_signal("dies")
		
	if !dead and current_hp < max_hp:
		current_hp += heal_per_second*delta
		if current_hp > max_hp:
			current_hp = max_hp
	
	current_damage = max_damage - (max_damage * (current_hp/float(max_hp))) + 1
	emit_signal("update_health_and_damage", (current_hp / float(max_hp)))
	
func hit(damage):
	if dash_left <= 0.0:
		current_hp -= damage



func _on_Main_game_start():
	dead = false
	transform.origin = Vector3(0, 0, 0)
	current_hp = max_hp
	current_damage = 0

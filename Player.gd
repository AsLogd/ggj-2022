extends KinematicBody

export (PackedScene) var player_shot_scene

# How fast the player moves in meters per second.
export var speed = 20
# The downward acceleration when in the air, in meters per second squared.
export var fall_acceleration = 75

export var max_damage = 150
export var heal_per_second = 3
export var max_hp = 100

# In seconds
export var dash_refresh = 2
export var dash_multiplier = 10
export var dash_duration = 0.1

const SHOOT_COOLDOWN = 0.3

var dead = true
var current_hp = max_hp
var current_damage = 0

var dash_available = true
var dash_cooldown = 0
var dash_left = 0

var look_direction = Vector3.ZERO
var velocity = Vector3.ZERO
var rng = RandomNumberGenerator.new()

var shot_cooldown = -1

var current_direction = Vector3.ZERO
var last_mouse_position = null
var using_gamepad = true

var current_state = "normal"

var invulnerable = false

# Dragging
var drag_target = null

var direction = Vector3.ZERO
var speed_multiplier = 1.0

signal update_health_and_damage(new_damage, new_health)
signal update_dash_cd()

signal dies
func _ready():
	get_node("animated_fish/RootNode/AnimationPlayer").get_animation("Take 001").set_loop(true)
	get_node("animated_fish/RootNode/AnimationPlayer").play("Take 001")

func _physics_process(delta):
	if(dead):
		return
		
	direction = Vector3.ZERO
	
	if current_state == "dragged":
		if !drag_target.get_ref() or (global_transform.origin - drag_target.get_ref().global_transform.origin).length() < 5:
			current_state = "normal"
			invulnerable = false
			return
			
		dragged_movement(delta)
	elif current_state == "normal":
		normal_movement(delta)
		
	velocity.x = direction.x * speed * speed_multiplier
	velocity.z = direction.z * speed * speed_multiplier
	# Vertical velocity
	velocity.y -= fall_acceleration * delta
	# Moving the character
	velocity = move_and_slide(velocity, Vector3.UP)
	
func dragged_movement(delta):
	direction = (drag_target.get_ref().global_transform.origin - global_transform.origin).normalized()
	speed_multiplier = 3.0
	
func normal_movement(delta):
	# We create a local variable to store the input direction.
	speed_multiplier = 1.0
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
		direction.z += 1
	if Input.is_action_pressed("move_forward"):
		direction.z -= 1

	var x_axis = Input.get_axis("joy_move_left", "joy_move_right")
	var z_axis = Input.get_axis("joy_move_forward", "joy_move_back")
	
	if abs(x_axis) > 0.1 or abs(z_axis) > 0.1:
		using_gamepad = true
		
	if using_gamepad:
		direction.x = x_axis
		direction.z = z_axis
	
	if Input.is_action_pressed("dash") and dash_available:
		dash_cooldown = dash_refresh
		dash_left = dash_duration
		dash_available = false
		
	target_and_shoot()

	dash_left -= delta

	if dash_left >= 0.0:
		speed_multiplier = dash_multiplier
		
	if direction != Vector3.ZERO:
		direction = direction.normalized()
		current_direction = translation + direction
	
func target_and_shoot():
	var look_at = null
	
	var mouse_pos = get_viewport().get_mouse_position()
	if last_mouse_position == null or (last_mouse_position - mouse_pos).length() > .1:
		using_gamepad = false
	
	var look_at_z = Input.get_axis("attack_forward", "attack_back")
	var look_at_x = Input.get_axis("attack_left", "attack_right")
	
	if abs(look_at_z) > 0.1 or abs(look_at_x) > 0.1:
		using_gamepad = true
		
	
	if using_gamepad:
		if look_at_z != 0 or look_at_x != 0:
			look_direction = Vector3(look_at_x, global_transform.origin.y, look_at_z) * 10
		look_at = global_transform.origin + look_direction.normalized()*10
	else:
		var camera = get_viewport().get_camera()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 10000
		look_at = Plane(Vector3.UP, transform.origin.y).intersects_ray(from, to)
		
	last_mouse_position = mouse_pos
	
	var target = get_node("Target")
	if look_at != null:
		target.global_transform.origin = look_at
		$animated_fish.look_at(look_at, Vector3.UP)
		
	if Input.is_action_pressed("attack"):
		if shot_cooldown <= 0:
			shot_cooldown = SHOOT_COOLDOWN
			var shot = player_shot_scene.instance()
			get_tree().get_root().add_child(shot)
			shot.initialize(translation, look_at, current_damage, speed/20)

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
	
	if dash_cooldown > 0.0:
		emit_signal("update_dash_cd", (float(dash_refresh) - dash_cooldown) / float(dash_refresh))

func hit(damage):
	if not invulnerable:
		if dash_left <= 0.0:
			current_hp -= damage
		
func drag_to(target):
	if current_state != "dragged":
		current_state = "dragged"
		invulnerable = true
		drag_target = weakref(target)

func get_multi():
	if current_hp == 0:
		return 0
	
	var percentage = current_hp/max_hp * 100
	if percentage > 80:
		return 1
	if percentage > 70:
		return 2
	if percentage > 50:
		return 3
	if percentage > 30:
		return 4
	if percentage > 20:
		return 8
	if percentage > 1:
		return 10

func _on_Main_game_start():
	dead = false
	transform.origin = Vector3(0, 0, 0)
	current_hp = max_hp
	current_damage = 0

export var health_pickup = 20
export var speed_pickup = 5
func _on_PowerUp_pickup(type):
	match type:
		1:
			print("Health up: ", health_pickup)
			max_hp += health_pickup
		2:
			print("Speed up: ", speed_pickup)
			speed += speed_pickup

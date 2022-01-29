extends KinematicBody

export (PackedScene) var shot_scene
export var enemy_type = 0

const speed = 10

const MAX_TIME_TO_CHANGE_DIRECTION = 1
const MIN_TIME_TO_CHANGE_DIRECTION = 3

const MIN_DISTANCE_TO_SHOT = 55.0

const TIME_BETWEEN_SHOTS = 1

export var TIME_BETWEEN_MOVEMENT_PATTERN = 2

var time_to_change_direction = -1
var time_to_shot = TIME_BETWEEN_SHOTS

var time_to_change_movement_pattern = TIME_BETWEEN_MOVEMENT_PATTERN
var movement_pattern = MovementPattern.RANDOM_MOVE

var velocity = Vector3.ZERO
var player

enum MovementPattern { RANDOM_MOVE, TOWARDS_PLAYER }

const max_hp = 40
var hp = max_hp

var stop = false

func hit(damage):
	hp -= damage
	if hp <= 0:
		var main = get_node("/root/Main")
		main.add_score(100 if enemy_type == 0 else 300)
		queue_free()
	
func _ready():
	var main = get_node("/root/Main")
	main.connect("game_over", self, "_on_Main_game_over")
	main.connect("game_start", self, "_on_Main_game_start")
	add_to_group("ENEMIES")

func _physics_process(_delta):
	if(stop):
		return
	move_and_slide(velocity)

func initialize(start_position, the_player):
	translation = start_position
	player = the_player

func _process(delta):
	if(stop):
		return
	time_to_change_direction-= delta;

	if time_to_change_direction < 0:
		rotate_object_local(Vector3.UP, rand_range(0,TAU))
		velocity = Vector3.FORWARD * speed
		velocity = velocity.rotated(Vector3.UP, rotation.y)
		time_to_change_direction += rand_range(MIN_TIME_TO_CHANGE_DIRECTION, MAX_TIME_TO_CHANGE_DIRECTION)
		
	if time_to_shot < 0:
		if transform.origin.distance_to(player.transform.origin) < MIN_DISTANCE_TO_SHOT:
			time_to_shot += TIME_BETWEEN_SHOTS
			shot()
	else:
		time_to_shot -= delta;
		
	if time_to_change_movement_pattern < 0:
		movement_pattern = MovementPattern.values()[randi()%MovementPattern.values().size()]

func _on_Main_game_start():
	queue_free()

func _on_Main_game_over():
	stop = true

func shot():
	if enemy_type == 0:
		var shot = shot_scene.instance()
		get_tree().get_root().add_child(shot)
		shot.initialize(translation, player.transform.origin, 0)
	else:
		for n in range(0,360,45):
			var shot = shot_scene.instance()
			get_tree().get_root().add_child(shot)
			shot.initialize(translation, translation + Vector3.FORWARD.rotated(Vector3.UP, n*TAU/360.0), 0)
			

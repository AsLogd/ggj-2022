extends KinematicBody

export (PackedScene) var shot_scene
export var enemy_type = 0

const speed = 10

const MAX_TIME_TO_CHANGE_DIRECTION = 1
const MIN_TIME_TO_CHANGE_DIRECTION = 3

const MIN_DISTANCE_TO_SHOT = 55.0

const TIME_BETWEEN_SHOTS = 1

var time_to_change_direction = -1
var time_to_shot = TIME_BETWEEN_SHOTS

var velocity = Vector3.ZERO
var player

export var base_max_hp = 40
var hp = base_max_hp

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

func initialize(start_position, the_player, a_hp = base_max_hp, a_enemy_type = 0):
	translation = start_position
	player = the_player
	hp = a_hp
	enemy_type = a_enemy_type

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
			

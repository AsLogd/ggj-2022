extends KinematicBody

export (PackedScene) var shot_scene

enum EnemyType { RANGED, RANGED_ELITE, MELEE, MELEE_ELITE }


var stats = {
	EnemyType.RANGED: {
		"base_hp": 30,
		"base_damage": 20,
		"projectile_speed": 0.3,
		"speed": 10,
		"projectile_scene": ResourceLoader.load("Shot.tscn"),
		"base_scene": ResourceLoader.load("enemy_fish.tscn"),
		"attack_cd": 1,
		"actions": ["damage"]
	},
	EnemyType.RANGED_ELITE: {
		"base_hp": 60,
		"base_damage": 40,
		"projectile_speed": 0.5,
		"speed": 12,
		"projectile_scene": ResourceLoader.load("Hook.tscn"),
		"base_scene": ResourceLoader.load("enemy_fish_elite.tscn"),
		"attack_cd": 2,
		"actions": ["damage"]
	},
	EnemyType.MELEE: {
		"base_hp": 80,
		"base_damage": 80,
		"projectile_speed": null,
		"speed": 20,
		"projectile_scene": null,
		"base_scene": ResourceLoader.load("enemy_fish.tscn"),
		"attack_cd": 1,
		"actions": ["damage"]
	},
	EnemyType.MELEE_ELITE: {
		"base_hp": 120,
		"base_damage": 120,
		"projectile_speed": 1.5,
		"speed": 14,
		"projectile_scene": ResourceLoader.load("Hook.tscn"),
		"base_scene": ResourceLoader.load("enemy_fish_elite.tscn"),
		"attack_cd": 5,
		"actions": ["damage", "drag"]
	}
}

# Varied constants
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
var enemy_type
var player

export (PackedScene) var drop_1
# 1/5 change of dropping 1
export var drop_list = [0,0,0,0,1]


enum MovementPattern { RANDOM_MOVE, TOWARDS_PLAYER }

# Stats
var base_max_hp
var hp
var projectile_speed
var base_damage
var speed
var projectile_scene
var attack_cd
var actions

var stop = false

func drop():
	drop_list.shuffle()
	var item_num = drop_list[0]
	var instance 
	match(item_num):
		1: 
			instance = drop_1.instance()
	
	if(instance):
		var main = get_node("/root/Main")
		instance.transform = transform
		main.add_child(instance)

func hit(damage):
	hp -= damage
	if hp <= 0:
		var main = get_node("/root/Main")
		main.add_score(100 if enemy_type == 0 else 300)
		drop()
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

func initialize(start_position, the_player, a_enemy_type = 0):
	translation = start_position
	player = the_player
	
	var type_definition = stats[a_enemy_type]
	
	base_max_hp = type_definition["base_hp"]
	hp = type_definition["base_hp"]
	base_damage = type_definition["base_damage"]
	projectile_speed = type_definition["projectile_speed"]
	speed = type_definition["speed"]
	shot_scene = type_definition["projectile_scene"]
	attack_cd = type_definition["attack_cd"]
	actions = type_definition["actions"]
	
	enemy_type = a_enemy_type
	var mesh = type_definition["base_scene"].instance()
	get_node("Pivot").add_child(mesh)
	var anim = get_node("Pivot/enemy_fish/AnimationPlayer")
	anim.get_animation("Core|Take 001|BaseLayer").set_loop(true)
	anim.play("Core|Take 001|BaseLayer")
	

func move_towards_player():
	look_at(player.global_transform.origin, Vector3.UP)
	velocity = Vector3.FORWARD * speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	
func move_randomly():
	if time_to_change_direction < 0:
		rotate_object_local(Vector3.UP, rand_range(0,TAU))
		velocity = Vector3.FORWARD * speed
		velocity = velocity.rotated(Vector3.UP, rotation.y)
		time_to_change_direction += rand_range(MIN_TIME_TO_CHANGE_DIRECTION, MAX_TIME_TO_CHANGE_DIRECTION)

func _process(delta):
	if(stop):
		return
	time_to_change_direction -= delta;
	time_to_change_movement_pattern -= delta;
	
	if movement_pattern == MovementPattern.TOWARDS_PLAYER:
		move_towards_player()
	if movement_pattern == MovementPattern.RANDOM_MOVE:
		move_randomly()

	if time_to_shot <= 0:
		if transform.origin.distance_to(player.transform.origin) < MIN_DISTANCE_TO_SHOT:
			time_to_shot = attack_cd
			attack()
			
	time_to_shot -= delta;
		
	if time_to_change_movement_pattern < 0:
		movement_pattern = MovementPattern.values()[randi()%MovementPattern.values().size()]
		time_to_change_movement_pattern = rand_range(1, 5)

func _on_Main_game_start():
	queue_free()

func _on_Main_game_over():
	stop = true

func attack():
	if enemy_type == EnemyType.RANGED:
		spawn_projectile(player.transform.origin)
	elif enemy_type == EnemyType.RANGED_ELITE:
		for n in range(0,360,45):
			spawn_projectile(translation + Vector3.FORWARD.rotated(Vector3.UP, n*TAU/360.0))
	elif enemy_type == EnemyType.MELEE:
		# TODO(Marce): Local attack
		pass
	elif enemy_type == EnemyType.MELEE_ELITE:
		spawn_projectile(player.transform.origin)

func spawn_projectile(target_position):
	var shot = shot_scene.instance()
	get_tree().get_root().add_child(shot)
	shot.initialize(self, translation, target_position, base_damage, projectile_speed, actions)

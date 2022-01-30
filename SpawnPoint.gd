extends Spatial

export(Array, PackedScene) var to_spawn_scene

var rng

func spawn(health_mult = 1, elite_chance = 0):
	var e_type = (randi() % 2) * 2
	if rng.randf_range(0, 1) < elite_chance :
		e_type = e_type + 1
	
	var rand_spawn = to_spawn_scene[0]
	var instance = rand_spawn.instance()
	instance.initialize(transform.origin, get_node("/root/Main/Player"), e_type)
	get_node("/root/Main").add_child(instance)
	
func _ready():
	rng = RandomNumberGenerator.new()

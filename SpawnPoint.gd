extends Spatial

export(Array, PackedScene) var to_spawn_scene

func spawn():
	var rand_spawn = to_spawn_scene[randi() % to_spawn_scene.size()]
	var instance = rand_spawn.instance()
	instance.initialize(transform.origin, get_node("/root/Main/Player"))
	get_node("/root/Main").add_child(instance)

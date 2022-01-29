extends Spatial

export (PackedScene) var to_spawn_scene

func spawn():
	var instance = to_spawn_scene.instance()
	instance.initialize(transform.origin, get_node("/root/Main/Player"))
	get_node("/root/Main").add_child(instance)

extends Spatial

export (PackedScene) var to_spawn_scene

func spawn():
	var instance = to_spawn_scene.instance()
	instance.transform = transform
	get_node("/root/Main").add_child(instance)

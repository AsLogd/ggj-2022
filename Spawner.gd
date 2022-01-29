extends Spatial


func spawn():
	var children = get_children()
	children.shuffle()
	for _i in children:
		if(not _i.get_node("Visibility").is_on_screen()):
			#print("Spawning enemy at spawn " + _i.name)
			_i.spawn()
			return
		#else:
			#print("Can't spawn at " + _i.name + " because it's on screen")

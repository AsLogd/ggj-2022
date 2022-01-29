extends Spatial

export (PackedScene) var mob_scene

var wave_spawned = 0
var timer

export var mobs_per_wave = 10
export var wave_timer = 30

func spawn():
	var children = get_children()
	children.shuffle()
	for _i in children:
		# Nose com filtrar perque no em pilli el timer de cap altra manera
		if(_i.get_class() == "Spatial" && not _i.get_node("Visibility").is_on_screen()):
			#print("Spawning enemy at spawn " + _i.name)
			if wave_spawned < mobs_per_wave:
				_i.spawn()
				wave_spawned = wave_spawned + 1
			return
		#else:
			#print("Can't spawn at " + _i.name + " because it's on screen")
			
func _ready():
	# Sets up timer.
	timer = Timer.new()
	timer.set_one_shot(false)
	timer.set_wait_time(wave_timer)
	
	add_child(timer)
	timer.start()
	timer.connect("timeout", self, "_on_wave_timer")
	

func _on_wave_timer():
	if (wave_spawned < mobs_per_wave):
		# Waits before spawning second wave since it's not yet all spawned
		timer.set_wait_time(2)
	else:
		wave_spawned = 0
		timer.start()
		print("Wave reset")

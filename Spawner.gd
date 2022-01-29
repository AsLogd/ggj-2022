extends Spatial

export (PackedScene) var mob_scene

export var mobs_per_wave = 10
export var wave_interval = 30
export var grace_interval = 5
export var base_elite_chance = 0.1

# Scaling settings
export var health_scaling = 1.5
export var elite_chance_scaling = 0.1

var notice_label

var wave_spawned = 0
var wave_timer
var wave_count = 0

var grace_timer
var is_grace_period = true

func spawn():
	if not is_grace_period and wave_spawned < mobs_per_wave:
		var children = get_children()
		var child = children[randi() % children.size()]
		while child.get_class() != "Spatial":
			child = children[randi() % children.size()]
		child.spawn()
		wave_spawned = wave_spawned + 1
			
func _ready():

	# Sets up wave timer.
	wave_timer = Timer.new()
	wave_timer.set_one_shot(true)
	wave_timer.set_wait_time(wave_interval)
	add_child(wave_timer)
	wave_timer.connect("timeout", self, "_on_wave_timer")
	
	notice_label = get_node("WaveNotice")
	
	# Sets up grace timer.
	grace_timer = Timer.new()
	add_child(grace_timer)
	grace_timer.set_wait_time(grace_interval)
	grace_timer.set_one_shot(true)
	grace_timer.connect("timeout", self, "_on_grace_timer")
	
	next_wave()

func _on_wave_timer():
	if (wave_spawned < mobs_per_wave):
		# Waits before spawning second wave since it's not yet all spawned
		wave_timer.set_wait_time(2)
	else:
		next_wave()

func next_wave():
	is_grace_period = true
	wave_count = wave_count + 1
	wave_spawned = 0
	grace_timer.start()
	notice_label.text = "Get ready for wave " + String(wave_count)
	notice_label.show()

func _on_grace_timer():
	is_grace_period = false
	notice_label.hide()
	wave_timer.set_wait_time(wave_interval)
	wave_timer.start()


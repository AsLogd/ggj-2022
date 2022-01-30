extends KinematicBody

var velocity = Vector3.ZERO
var damage = -99
var speed = 0.3
var stop = false
var shooter
var actions

func _ready():
	add_to_group("BULLETS")
	var main = get_node("/root/Main")
	main.connect("game_over", self, "_on_Main_game_over")
	main.connect("game_start", self, "_on_Main_game_start")

func _physics_process(_delta):
	if(stop):
		return
	var col = move_and_collide(velocity)
	if col != null:
		if "damage" in actions:
			if col.collider.has_method("hit"):
				col.collider.hit(damage)
		if "drag" in actions:
			if col.collider.has_method("drag_to"):
				col.collider.drag_to(shooter)
		queue_free()
	
func initialize(a_shooter, start_position, player_position, a_damage, a_speed, a_actions):
	translation = start_position
	look_at(player_position, Vector3.UP)
	velocity = Vector3.FORWARD * speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	
	if typeof(a_actions) == TYPE_STRING:
		a_actions = [a_actions]
	
	damage = a_damage
	speed = a_speed
	shooter = a_shooter
	actions = a_actions

func _on_Main_game_start():
	queue_free()

func _on_Main_game_over():
	stop = true

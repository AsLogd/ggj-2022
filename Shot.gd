extends KinematicBody

var velocity = Vector3.ZERO
var damage = 20
var speed = 0.3
var stop = false

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
		if col.collider.has_method("hit"):
			col.collider.hit(damage)
		queue_free()
	
func initialize(start_position, player_position, type):
	translation = start_position
	look_at(player_position, Vector3.UP)
	velocity = Vector3.FORWARD * speed
	velocity = velocity.rotated(Vector3.UP, rotation.y)
	
	if type == 0:
		damage = 1
		speed = 0.3
	elif type == 1:
		damage = 5
		speed = 0.5

func _on_Main_game_start():
	queue_free()

func _on_Main_game_over():
	stop = true

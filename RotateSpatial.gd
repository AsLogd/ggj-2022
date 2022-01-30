extends Spatial


# Declare member variables here. Examples:
# var a = 2
# var b = "text"


export var rotation_speed = 4

# Called when the node enters the scene tree for the first time.
func _process(delta):
	rotate_y(delta*rotation_speed)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

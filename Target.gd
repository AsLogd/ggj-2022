extends Sprite3D


# Declare member variables here. Examples:
# var a = 2
# var b = "text"

export var rotation_speed = 4

# Called when the node enters the scene tree for the first time.
func _process(delta):
	transform = transform.rotated(Vector3(0, 0.1,0), rotation_speed*delta)


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass

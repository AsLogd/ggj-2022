extends Spatial


export var type = 1

signal pickup

func _ready():
	connect("pickup", get_node("/root/Main/Player"), "_on_PowerUp_pickup")
	
	
func _on_Area_body_entered(body):
	if body.name == "Player":
		emit_signal("pickup", type)
		queue_free()

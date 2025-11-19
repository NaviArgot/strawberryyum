extends StaticBody3D

var pos: Vector2i = Vector2i(0, 0)

func _input (event):
	if event.is_action_pressed("move_up"):
		print("UP")
		pos.y = pos.y + 1
	elif event.is_action_pressed("move_left"):
		print("LEFT")
		pos.x = pos.x + 1
	elif event.is_action_pressed("move_down"):
		print("DOWN")
		pos.y = pos.y - 1
	elif event.is_action_pressed("move_right"):
		print("RIGHT")
		pos.x = pos.x - 1


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	position.x = pos.x
	position.z = pos.y

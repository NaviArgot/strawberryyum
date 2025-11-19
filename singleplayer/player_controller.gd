extends StaticBody3D

enum States {MOVING, DASHING, TRAPPED, DEAD}

var pos: Vector2i = Vector2i(0, 0)
var state: int
var face: int
var front: int



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
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

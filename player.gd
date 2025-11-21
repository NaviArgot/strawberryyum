extends Node3D

class_name Player

func setPos(x, y):
	position.x = x
	position.z = y
	
func setFace(faceValue):
	var label = get_node("DebugData")
	label.text = "Face: %d" % [faceValue]

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

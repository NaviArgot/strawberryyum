extends Object

class_name CollisionMap

var width: int
var height: int
var collisionMap: Array

func _init() -> void:
	# Load map from JSON file
	width = 8
	height = 8
	collisionMap = [
		0, 0, 0, 1, 1, 0, 0, 0,
		0, 0, 1, 1, 1, 1, 0, 0,
		0, 1, 1, 1, 1, 1, 1, 0,
		1, 1, 1, 1, 1, 1, 1, 1,
		1, 1, 1, 1, 1, 1, 1, 1,
		0, 1, 1, 1, 1, 1, 1, 0,
		0, 0, 1, 1, 1, 1, 0, 0,
		0, 0, 0, 1, 1, 0, 0, 0,
	]
	

func getValue(x, y):
	if x < 0 or x > width or y < 0 or y > height: return 0
	var i = y * width + x
	return collisionMap[i]

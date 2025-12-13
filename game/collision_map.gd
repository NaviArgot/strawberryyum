extends Object

class_name CollisionMap

var origin: Vector2i
var width: int
var height: int
var collisionMap: Array

func _init(height_, width_, origin_ = Vector2i(0, 0)) -> void:
	# Load map from JSON file
	origin = origin_
	width = height_
	height = width_
	collisionMap = [
		1, 0, 0, 1, 1, 0, 0, 0,
		0, 1, 0, 1, 1, 0, 1, 0,
		0, 1, 0, 1, 1, 0, 1, 0,
		1, 0, 1, 1, 1, 1, 0, 1,
		1, 1, 1, 1, 1, 1, 1, 1,
		0, 1, 0, 0, 0, 0, 1, 0,
		0, 0, 1, 1, 1, 1, 0, 0,
		0, 0, 0, 1, 1, 0, 0, 0,
	]
	

func getValue(x, y):
	var tx = x - origin.x
	var ty = y - origin.y
	if tx < 0 or tx >= width or ty < 0 or ty >= height: return 0
	var i = ty * width + tx
	return collisionMap[i]
	#return 1

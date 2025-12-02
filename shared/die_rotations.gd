extends Object

class_name DieRotations

static var trans: Dictionary

static func getTrans(faceFront: String):
	if not trans:
		_initialize()
	return trans[faceFront]

static func _initialize():
	trans = {}
	var key = "%d%d" % [1, 0]
	var rot = Basis.from_euler(Vector3(-PI/2, -PI/2, 0))
	_traverse(key, 1, 0, rot)
	

static func _traverse(key: String, face: int, front: int, rot: Basis,):
	if key in trans: return
	var dirs = [DieSim.NORTH, DieSim.SOUTH, DieSim.EAST, DieSim.WEST]
	var axes = [
		Vector3(1.0, 0.0, 0.0), # NORTH
		Vector3(-1.0, 0.0, 0.0), # SOUTH
		Vector3(0.0, 0.0, -1.0), #EAST
		Vector3(0.0, 0.0, 1.0) #WEST
	]
	var state: Array
	var newkey: String
	var newrot: Basis
	trans[key] = rot.orthonormalized()
	for i in dirs.size():
		state = DieSim.turnDie(face, front, dirs[i])
		newkey = "%d%d" % state
		newrot = Basis(axes[i], PI/2) * rot
		_traverse(newkey, state[0], state[1], newrot)

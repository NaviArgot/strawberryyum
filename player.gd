extends Node3D

class_name Player

var tween: Tween
var _onFinishCallback: Callable

var currPos: Vector3
var currRot: Basis

func setPos(x, y):
	currPos = Vector3(x, 0, y)
	position = currPos

func setFace(face):
	$DebugData.text = "%d" % [face]


func animateState(duration, x, y, dir, state, face, front):
	if tween:
		_onFinishCallback.call()
		pass
	match state:
		GameState.PlayerState.States.MOVING:
			print("MOVING")
			_animateMove(duration, x, y, 1, dir)
		GameState.PlayerState.States.DASH:
			print("DASHING")
		GameState.PlayerState.States.DEAD:
			pass
		

func _animateMove (duration, x, y, steps, dir):
	var axis: Vector3 = Vector3(1.0, 0.0, 0.0)
	match dir:
		GameState.PlayerState.Dir.UP:
			axis = Vector3(1.0, 0.0, 0.0)
		GameState.PlayerState.Dir.DOWN:
			axis = Vector3(-1.0, 0.0, 0.0)
		GameState.PlayerState.Dir.LEFT:
			axis = Vector3(0.0, 0.0, 1.0)
		GameState.PlayerState.Dir.RIGHT:
			axis = Vector3(0.0, 0.0, -1.0)
	var startRot = $Mesh.transform.basis.orthonormalized()
	var endRot = Basis(axis, PI/2) * startRot
	var startPos = position
	var endPos = Vector3(x, 0.0, y)
	_onFinishCallback = _onFinish.bind(endPos, endRot)
	tween = create_tween()
	tween.set_parallel()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(_rotate.bind(startRot, endRot), 0.0, 1.0, duration)
	tween.tween_method(_move.bind(startPos, endPos), 0.0, 1.0, duration)
	tween.chain().tween_callback(_onFinishCallback)
	

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _rotate(weight, start: Basis, end: Basis):
	var rot = start.slerp(end, weight)
	_setRotation(rot)
	#print("Weight: ", weight,"\nStart: ", start, "\nEnd: ", end, "\nUpdate: ", rot)

func _move(weight, start, end):
	position = start.lerp(end, weight)


func _setRotation(rot: Basis):
	$Mesh.rotation = rot.get_euler()

func _onFinish (endPos, endRot):
	currRot = endRot
	position = endPos
	_setRotation(currRot)
	print("FINISHED")

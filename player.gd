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
	var steps = abs(snappedi(currPos.x, 1) - x + snappedi(currPos.z, 1) - y)
	if tween and state != GameState.PlayerState.States.IDLE:
		_onFinishCallback.call()
		tween.kill()
		tween = null
	match state:
		GameState.PlayerState.States.IDLE:
			print("IDLE")
		GameState.PlayerState.States.MOVING:
			print("MOVING Dur: %f x: %d y: %d steps: %d dir: %d" % [duration, x, y, steps, dir])
			_animateMove(duration, x, y, 1, dir)
		GameState.PlayerState.States.DASH:
			_animateMove(duration, x, y, steps, dir)
			print("DASHING Dur: %f x: %d y: %d steps: %d dir: %d" % [duration, x, y, steps, dir])
		GameState.PlayerState.States.DEAD:
			pass
		

func _animateMove (duration, x, y, steps, dir):
	if steps < 1: return
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
	var baseRot =  $Mesh.transform.basis.orthonormalized()
	var startRot: Basis
	var endRot: Basis
	var startPos = position
	var endPos = Vector3(x, 0.0, y)
	# The rotation animation can be fragmented so a subtween is necessary
	var rotSubtween = create_tween()
	rotSubtween.set_ease(Tween.EASE_IN)
	rotSubtween.set_trans(Tween.TRANS_CUBIC)
	for i in steps:
		startRot = Basis(axis, (PI/2) * i) * baseRot
		endRot = Basis(axis, (PI/2) * (i+1)) * baseRot
		rotSubtween.tween_method(_rotate.bind(startRot, endRot), 0.0, 1.0, duration/steps)
	_onFinishCallback = _onFinish.bind(endPos, endRot)
	# Resumes the creation of main tween
	tween = create_tween()
	tween.set_parallel()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(_move.bind(startPos, endPos), 0.0, 1.0, duration)
	tween.tween_subtween(rotSubtween)
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
	currPos = endPos
	position = endPos
	_setRotation(currRot)
	print("FINISH")

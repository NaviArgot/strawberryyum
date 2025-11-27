extends Node3D

class_name Player

var tween: Tween
var _onFinishCallback: Callable

var currPos: Vector3
var currRot: Basis
var face: int
var front: int

func setPos(x, y):
	currPos = Vector3(x, 0, y)
	position = currPos

func setDebug(face, front, state):
	const STATES = {
		GameState.PlayerState.States.IDLE: "IDLE",
		GameState.PlayerState.States.MOVING: "MOVING",
		GameState.PlayerState.States.DASH: "DASH",
		GameState.PlayerState.States.DEAD: "DEAD",
		GameState.PlayerState.States.CRASH: "CRASH",
	}
	$DebugData.text = "F%d f%d\n%s" % [face, front, STATES[state]]


func animateState(duration, x, y, dir, state, newFace, newFront):
	var steps = abs(snappedi(currPos.x, 1) - x + snappedi(currPos.z, 1) - y)
	if tween and state != GameState.PlayerState.States.IDLE:
		_onFinishCallback.call()
		_onFinishCallback = _doNothing
		tween.kill()
		tween = null
	match state:
		GameState.PlayerState.States.IDLE:
			print("IDLE")
		GameState.PlayerState.States.MOVING:
			print("MOVING Dur: %f x: %d y: %d steps: %d dir: %d" % [duration, x, y, steps, dir])
			_animateMove(duration, x, y, steps, dir, newFace, newFront)
		GameState.PlayerState.States.DASH:
			_animateMove(duration, x, y, steps, dir, newFace, newFront)
			print("DASHING Dur: %f x: %d y: %d steps: %d dir: %d" % [duration, x, y, steps, dir])
		GameState.PlayerState.States.DEAD:
			pass
		

func _animateMove (duration, x, y, steps, dir, newFace, newFront):
	if steps < 1: return
	var startRot: Basis
	var endRot: Basis
	var dieState: Array = [face, front]
	var nextDieState: Array
	var startPos = position
	var endPos = Vector3(x, 0.0, y)
	# The rotation animation can be fragmented so a subtween is necessary
	var rotSubtween = create_tween()
	rotSubtween.set_ease(Tween.EASE_IN)
	rotSubtween.set_trans(Tween.TRANS_CUBIC)
	for i in steps:
		nextDieState = DieSim.turnDie(dieState[0], dieState[1], dir)
		startRot = DieRotations.getTrans("%d%d" % dieState)
		endRot = DieRotations.getTrans("%d%d" % nextDieState)
		rotSubtween.tween_method(_rotate.bind(startRot, endRot), 0.0, 1.0, duration/steps)
	_onFinishCallback = _onFinish.bind(
			endPos,
			DieRotations.getTrans("%d%d" % [newFace, newFront]),
			newFace,
			newFront
		)
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
	face = 1
	front = 0

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

func _onFinish (endPos, endRot, newFace, newFront):
	currRot = endRot
	currPos = endPos
	position = endPos
	face = newFace
	front = newFront
	_setRotation(currRot)
	print("FINISH")

func _doNothing() :
	print("NOTHING")
	pass

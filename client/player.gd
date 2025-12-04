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

func setDebug(face_, front_, anim_):
	const ANIMTYPE = {
		PublishableState.ANIM.IDLE: "IDLE",
		PublishableState.ANIM.MOVE: "MOVE",
		PublishableState.ANIM.DASH: "DASH",
		PublishableState.ANIM.DEATH: "DEATH",
		PublishableState.ANIM.CRASH: "CRASH",
		PublishableState.ANIM.PUSHED: "PUSHED",
	}
	$DebugData.text = "F%d f%d\n%s" % [face_, front_, ANIMTYPE[anim_]]


func animateState(duration, x, y, dir, anim, newFace, newFront):
	var steps = abs(snappedi(currPos.x, 1) - x + snappedi(currPos.z, 1) - y)
	if tween and anim != PublishableState.ANIM.IDLE:
		_onFinishCallback.call()
		_onFinishCallback = _doNothing
		tween.kill()
		tween = null
	match anim:
		PublishableState.ANIM.IDLE:
			print("IDLE")
		PublishableState.ANIM.MOVE:
			print("MOVING Dur: %f x: %d y: %d steps: %d dir: %d" % [duration, x, y, steps, dir])
			_animateMove(duration, x, y, steps, dir, newFace, newFront)
		PublishableState.ANIM.DASH:
			_animateMove(duration, x, y, steps, dir, newFace, newFront)
			print("DASHING Dur: %f x: %d y: %d steps: %d dir: %d" % [duration, x, y, steps, dir])
		PublishableState.ANIM.PUSHED:
			_animatePush(duration, x, y, newFace, newFront)
		PublishableState.ANIM.DEATH:
			_animateDeath(duration, x, y, steps, dir, newFace, newFront)

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

func _animatePush(duration, x, y, newFace, newFront):
	var startPos = position
	var endPos = Vector3(x, 0.0, y)
	_onFinishCallback = _onFinish.bind(
			endPos,
			DieRotations.getTrans("%d%d" % [newFace, newFront]),
			newFace,
			newFront
		)
	tween = create_tween()
	tween.set_parallel()
	tween.set_ease(Tween.EASE_IN)
	tween.set_trans(Tween.TRANS_CUBIC)
	tween.tween_method(_move.bind(startPos, endPos), 0.0, 1.0, duration)
	tween.chain().tween_callback(_onFinishCallback)

func _animateDeath (duration, x, y, steps, dir, newFace, newFront):
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
	_onFinishCallback = _onFinishDeath.bind(
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
	tween.chain().tween_method(_dissapear.bind(scale, Vector3(0.0, 0.0, 0.0)), 0.0, 1.0, 1.0)
	tween.chain().tween_callback(_onFinishCallback)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	face = 1
	front = 0
	$Mesh.rotation = DieRotations.getTrans("10").get_euler()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _rotate(weight, start: Basis, end: Basis):
	var rot = start.slerp(end, weight)
	_setRotation(rot)
	#print("Weight: ", weight,"\nStart: ", start, "\nEnd: ", end, "\nUpdate: ", rot)

func _move(weight, start, end):
	position = start.lerp(end, weight)

func _dissapear (weight, start: Vector3, end: Vector3):
	$GPUParticles3D.emitting = true
	scale = start.lerp(end, weight)

func _onFinishDeath (endPos, endRot, newFace, newFront):
	currRot = endRot
	currPos = endPos
	position = endPos
	face = newFace
	front = newFront
	scale = Vector3(0.0, 0.0, 0.0)
	visible = false
	$GPUParticles3D.emitting = false
	_setRotation(currRot)


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

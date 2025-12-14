class_name PlayerController extends Controller

var id: int
var actionBuffer: ActionBuffer

func _init(id_: int, actionBuffer_: ActionBuffer) -> void:
	id = id_
	actionBuffer = actionBuffer_

func perform ():
	if Input.is_action_pressed("move_up"):
		actionBuffer.setAction(id, Constants.ACTION.DOWN)
	elif Input.is_action_pressed("move_left"):
		actionBuffer.setAction(id, Constants.ACTION.LEFT)
	elif Input.is_action_pressed("move_down"):
		actionBuffer.setAction(id, Constants.ACTION.UP)
	elif Input.is_action_pressed("move_right"):
		actionBuffer.setAction(id, Constants.ACTION.RIGHT)
	elif Input.is_action_pressed("dash"):
		actionBuffer.setAction(id, Constants.ACTION.DASH)

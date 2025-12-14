class_name AIController extends Controller

var id: int
var actionBuffer: ActionBuffer
var perceivedState: PerceivedState

func _init(
		id_: int,
		actionBuffer_: ActionBuffer,
		perceivedState_: PerceivedState
	) -> void:
	id = id_
	actionBuffer = actionBuffer_
	perceivedState = perceivedState_


func perform():
	var action = randi() % (Constants.ACTION.DASH + 1)
	actionBuffer.setAction(id, action)

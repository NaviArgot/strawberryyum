class_name AIController extends Controller

const moveTrans = {
	Constants.DIR.UP: [0,1],
	Constants.DIR.LEFT: [-1,0],
	Constants.DIR.DOWN: [0,-1],
	Constants.DIR.RIGHT: [1,0],
}

const MULTI_MOVE = 20
const MULTI_DASH = 10

var id: int
var actionBuffer: ActionBuffer
var perceivedState: PerceivedState
var actionScore: Array[int]
var following: int

func _init(
		id_: int,
		actionBuffer_: ActionBuffer,
		perceivedState_: PerceivedState
	) -> void:
	id = id_
	actionBuffer = actionBuffer_
	perceivedState = perceivedState_
	actionScore = []
	actionScore.resize(Constants.ACTION._MAX_INDEX_)


func perform():
	var player = perceivedState.players[id]
	var pos = perceivedState.getPlayerPos(id)
	# Initialize scores
	for i in range(Constants.ACTION._MAX_INDEX_):
		actionScore[i] = 0
		if i == Constants.ACTION.NONE:
			actionScore[i] = 0
		
	# Add score w.r.t pythagorean distance
	var targetID = perceivedState.findClosestPlayer(pos.x, pos.y)
	if targetID != -1:
		var target = perceivedState.getPlayerPos(targetID)
		var delta = Vector2(target.x - pos.x, target.y - pos.y)
		delta = delta.normalized()
		if delta.x > 0:
			actionScore[Constants.ACTION.RIGHT] += int(abs(delta.x * MULTI_MOVE))
		else:
			actionScore[Constants.ACTION.LEFT] += int(abs(delta.x * MULTI_MOVE))
		if delta.y > 0:
			actionScore[Constants.ACTION.UP] += int(abs(delta.y * MULTI_MOVE))
		else:
			actionScore[Constants.ACTION.DOWN] += int(abs(delta.y * MULTI_MOVE))
		# Dash score
		var targetDir = Constants.DIR.UP
		if abs(snappedi(delta.x,1)) == 1 and snappedi(delta.y, 1) == 0:
			if snapped(delta.x, 1) > 0: targetDir = Constants.DIR.RIGHT
			else: targetDir = Constants.DIR.LEFT
		elif abs(snappedi(delta.y,1)) == 1 and snappedi(delta.x, 1) == 0:
			if snapped(delta.y, 1) > 0: targetDir = Constants.DIR.UP
			else: targetDir = Constants.DIR.DOWN
		if targetDir == player.dir:
			actionScore[Constants.ACTION.DASH] *= MULTI_DASH
	# Check for falls
	for act in Constants.ACTION._MAX_INDEX_:
		match act:
			Constants.ACTION.UP:
				if _willFall(pos, Constants.DIR.UP, 1):
					actionScore[Constants.ACTION.UP] = 0
			Constants.ACTION.LEFT:
				if _willFall(pos, Constants.DIR.LEFT, 1):
					actionScore[Constants.ACTION.LEFT] = 0
			Constants.ACTION.DOWN:
				if _willFall(pos, Constants.DIR.DOWN, 1):
					actionScore[Constants.ACTION.DOWN] = 0
			Constants.ACTION.RIGHT:
				if _willFall(pos, Constants.DIR.RIGHT, 1):
					actionScore[Constants.ACTION.RIGHT] = 0
			Constants.ACTION.DASH:
				if _willFall(pos, player.dir, player.face):
					actionScore[Constants.ACTION.DASH] = 0
	var action = _weightedDecision()
	#print(pos, actionScore, action)
	actionBuffer.setAction(id, action)
	
	
func _willFall(pos : Vector2i, dir: int, steps: int) -> bool:
	var x = pos.x + (moveTrans[dir][0] * steps)
	var y = pos.y + (moveTrans[dir][1] * steps)
	var col = perceivedState.gamemap.getCellCollision(x, y)
	#print(" x: ",x, " y: ", y, " steps: ", steps, " col: ", col)
	return col == 0


func _weightedDecision():
	var chosen = Constants.ACTION.NONE
	# Choose action with weightghedt randomenesses
	var boundary : int = 0
	for i in actionScore.size():
		boundary += actionScore[i]
	if boundary > 0:
		var individuation = randi() % boundary
		var accum = 0
		for act in Constants.ACTION._MAX_INDEX_:
			if actionScore[act] == 0: continue
			accum += actionScore[act]
			if individuation < accum:
				chosen = act as Constants.ACTION
				break
	return chosen

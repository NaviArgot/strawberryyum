extends Object

class_name GameLogic

enum ACTION {NONE, UP, DOWN, LEFT, RIGHT, DASH}
enum STATE {MOVING, DASHING, PUSHED, DEAD}

const moveTrans = {
	Constants.DIR.UP: [0,1],
	Constants.DIR.LEFT: [-1,0],
	Constants.DIR.DOWN: [0,-1],
	Constants.DIR.RIGHT: [1,0],
}

class PlayerState:
	var x
	var y
	var dir
	var steps
	var count
	var state
	var action
	var front
	var face
	var changed
	
	func _init(x_, y_, dir_, steps_, state_, face_ = 1, front_ = 1) -> void:
		reset(x_, y_, dir_, steps_, state_, face_, front_)
	
	
	func reset(x_, y_, dir_, steps_, state_, face_, front_) -> void:
		x = x_
		y = y_
		dir = dir_
		steps = steps_
		state = state_
		face = face_
		front = front_
		count = 0

var collisionMap: CollisionMap
var pubstate : PublishableState
var playerActions: Dictionary
var playerStates : Dictionary

func _init (playerIDs, pubstate_, collisionMap_) -> void:
	# Expects an initialized gamestate
	collisionMap = collisionMap_
	pubstate = pubstate_
	playerActions = {}
	playerStates = {}
	# Initializes players action buffer
	for id in playerIDs:
		playerActions[id] = ACTION.NONE
		playerStates[id] = PlayerState.new(0, 0, 0, 0, STATE.MOVING)


func queueAction (playerId: int, action: ACTION):
	if not self.playerActions.has(playerId): return
	self.playerActions[playerId] = action

func perform ():
	_preparePlayerState()
	_simulate()
	_checkForDeath()
	_publishState()
	return

func _preparePlayerState ():
	var ids = self.playerActions.keys()
	for id in ids:
		var player = playerStates[id]
		if player.state == STATE.DEAD:
			player.steps = 0
			player.action = ACTION.NONE
			return
		player.changed = false
		player.count = 0
		match self.playerActions[id]:
			ACTION.NONE:
				player.steps = 0
			ACTION.UP:
				player.dir = Constants.DIR.UP
				player.steps = 1
				player.action = ACTION.UP
			ACTION.DOWN:
				player.dir = Constants.DIR.DOWN
				player.steps = 1
				player.action = ACTION.DOWN
			ACTION.LEFT:
				player.dir = Constants.DIR.LEFT
				player.steps = 1
				player.action = ACTION.LEFT
			ACTION.RIGHT:
				player.dir = Constants.DIR.RIGHT
				player.steps = 1
				player.action = ACTION.RIGHT
			ACTION.DASH:
				player.steps = player.face
				player.action = ACTION.DASH
		self.playerActions[id] = ACTION.NONE

func _simulate ():
	var player : PlayerState
	var noMoreMoves: bool = false
	while not noMoreMoves:
		noMoreMoves = true
		for id in self.playerStates.keys():
			player = self.playerStates[id]
			if player.count < player.steps:
				noMoreMoves = false
				if player.action == ACTION.DASH:
					_pushPlayer(id, player.dir)
				else:
					_movePlayer(id, player.dir)
				player.count += 1

func _pushPlayer (id, dir: Constants.DIR):
	var player = self.playerStates[id]
	var targetX = player.x + self.moveTrans[dir][0]
	var targetY = player.y + self.moveTrans[dir][1]
	var collision = _collidesWithPlayer(targetX, targetY)
	if collision != -1 and \
	self.playerStates[collision].state != STATE.DASHING:
		_pushPlayer(collision, dir)
	_movePlayer(id, dir)

func _movePlayer (id, dir: Constants.DIR):
	var moved = false
	var player = self.playerStates[id]
	var targetX = player.x + self.moveTrans[dir][0]
	var targetY = player.y + self.moveTrans[dir][1]
	var collision = _collidesWithPlayer(targetX, targetY)
	if collision == -1:
		player.x = targetX
		player.y = targetY
		player.dir = dir
		var newDie = DieSim.turnDie(player.face, player.front, dir)
		player.face = newDie[0]
		player.front = newDie[1]
		player.changed = true
		moved = true
	return moved

func _checkForDeath ():
	for player in self.playerStates.values():
		if self.collisionMap.getValue(player.x, player.y) == 0:
			print("PLAYER DIED: ")
			player.state = STATE.DEAD

func _publishState():
	for id in self.playerStates.keys():
		var player = self.playerStates[id]
		var anim: PublishableState.ANIM
		if player.changed:
			self.pubstate.publishState(
				id,
				player.x,
				player.y,
				player.dir,
				player.steps,
				player.face,
				player.front,
				PublishableState.ANIM.MOVE,
				0
			)

func _collidesWithPlayer (nextX, nextY):
	for id in self.playerStates.keys():
		var player = self.playerStates[id]
		if player.x == nextX \
			and player.y == nextY \
			and player.state != STATE.DEAD:
			return id
	return -1

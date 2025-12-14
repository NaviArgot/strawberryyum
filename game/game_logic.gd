extends Object

class_name GameLogic

enum STATE {MOVING, DASHING, PUSHED, DEAD}

const moveTrans = {
	Constants.DIR.UP: [0,1],
	Constants.DIR.LEFT: [-1,0],
	Constants.DIR.DOWN: [0,-1],
	Constants.DIR.RIGHT: [1,0],
}

class Cooldown:
	var move : TimedCount
	var dash : TimedCount
	
	func _init(move_ : float, dash_ : float):
		move = TimedCount.new(move_)
		dash = TimedCount.new(dash_)
	
	func update(delta : float):
		move.update(delta)
		dash.update(delta)
	
	func reset():
		move.reset()
		dash.reset()

const COOLDOWN_MOVE : float = 5.0
const COOLDOWN_DASH : float = 3.0

class PlayerState:
	var x : int
	var y : int
	var dir : Constants.DIR
	var steps : int
	var count : int
	var state :  STATE
	var action : Constants.ACTION
	var front : int
	var face : int
	var changed : bool
	var cooldown : Cooldown
	
	func _init(x_, y_, dir_, steps_, state_, face_ = 1, front_ = 1) -> void:
		x = x_
		y = y_
		dir = dir_
		steps = steps_
		state = state_
		face = face_
		front = front_
		count = 0
		cooldown = Cooldown.new(COOLDOWN_MOVE, COOLDOWN_DASH)

var playerIDs : Array[int]
var gamemap: GameMap
var pubstate : PublishableState
var actionBuffer :  ActionBuffer
var playerStates : Dictionary[int, PlayerState]

func _init (playerIDs_, pubstate_, gamemap_, actionBuffer_) -> void:
	playerIDs = playerIDs_
	gamemap = gamemap_
	pubstate = pubstate_
	actionBuffer = actionBuffer_
	playerStates = {}
	# Initializes players action buffer
	for id in playerIDs:
		playerStates[id] = PlayerState.new(0, 0, 0, 0, STATE.MOVING)

func perform (delta : float):
	_preparePlayerState(delta)
	_simulate()
	_checkForDeath()
	_publishState()
	return

func _preparePlayerState (delta):
	for id in playerIDs:
		var player := playerStates[id]
		player.cooldown.update(delta)
		if id == 0:
			print("READY: ", player.cooldown.move.amount)
		if player.state == STATE.DEAD:
			player.cooldown.reset()
			player.steps = 0
			player.action = Constants.ACTION.NONE
			player.changed = false
			return
		player.changed = false
		player.count = 0
		match actionBuffer.getAction(id):
			Constants.ACTION.NONE:
				player.steps = 0
			Constants.ACTION.UP:
				if player.cooldown.move.isReady():
					player.dir = Constants.DIR.UP
					player.steps = 1
					player.action = Constants.ACTION.UP
					player.cooldown.move.reset()
			Constants.ACTION.DOWN:
				if player.cooldown.move.isReady():
					player.dir = Constants.DIR.DOWN
					player.steps = 1
					player.action = Constants.ACTION.DOWN
					player.cooldown.move.reset()
			Constants.ACTION.LEFT:
				if player.cooldown.move.isReady():
					player.dir = Constants.DIR.LEFT
					player.steps = 1
					player.action = Constants.ACTION.LEFT
					player.cooldown.move.reset()
			Constants.ACTION.RIGHT:
				if player.cooldown.move.isReady():
					player.dir = Constants.DIR.RIGHT
					player.steps = 1
					player.action = Constants.ACTION.RIGHT
					player.cooldown.move.reset()
			Constants.ACTION.DASH:
				if player.cooldown.dash.isReady():
					player.steps = player.face
					player.action = Constants.ACTION.DASH
					player.cooldown.dash.reset()
	actionBuffer.reset()

func _simulate ():
	var player : PlayerState
	var noMoreMoves: bool = false
	while not noMoreMoves:
		noMoreMoves = true
		for id in playerStates.keys():
			player = playerStates[id]
			if player.count < player.steps:
				noMoreMoves = false
				if player.action == Constants.ACTION.DASH:
					_pushPlayer(id, player.dir)
				else:
					_movePlayer(id, player.dir)
				player.count += 1

func _pushPlayer (id, dir: Constants.DIR):
	var player = playerStates[id]
	var targetX = player.x + moveTrans[dir][0]
	var targetY = player.y + moveTrans[dir][1]
	var collision = _collidesWithPlayer(targetX, targetY)
	if collision != -1 and \
	playerStates[collision].state != STATE.DASHING:
		_pushPlayer(collision, dir)
	_movePlayer(id, dir)

func _movePlayer (id, dir: Constants.DIR):
	var moved = false
	var player = playerStates[id]
	var targetX = player.x + moveTrans[dir][0]
	var targetY = player.y + moveTrans[dir][1]
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
	for player in playerStates.values():
		if gamemap.getCellCollision(player.x, player.y) == 0:
			player.state = STATE.DEAD

func _publishState():
	for id in playerStates.keys():
		var player = playerStates[id]
		var anim = _getAnimType(id)
		if player.changed:
			pubstate.publishState(
				id,
				player.x,
				player.y,
				player.dir,
				player.steps,
				player.face,
				player.front,
				anim,
				0
			)
			player.changed  = false

func _getAnimType (id):
	var player = playerStates[id]
	var anim: PublishableState.ANIM
	anim = PublishableState.ANIM.MOVE
	if player.state == STATE.DEAD:
		anim = PublishableState.ANIM.DEATH
	elif player.action == Constants.ACTION.DASH:
		anim = PublishableState.ANIM.DASH
	return anim
	

func _collidesWithPlayer (nextX, nextY):
	for id in playerStates.keys():
		var player = playerStates[id]
		if player.x == nextX \
			and player.y == nextY \
			and player.state != STATE.DEAD:
			return id
	return -1

func free() -> void:
	for player in playerStates.values():
		player.free()

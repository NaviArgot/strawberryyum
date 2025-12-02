extends Object

class_name GameLogic

class PlayerProc:
	var x
	var y
	var dir
	var steps
	var count
	var state
	var front
	var face
	
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

class PlayerAction:
	var command: Actions
	var dir: GameState.PlayerState.Dir
	var steps: int
	
	func _init(
		command_: Actions,
		dir_: GameState.PlayerState.Dir,
		steps_
	) -> void:
		reset(command_, dir_, steps_)
	
	func reset(
		command_: Actions,
		dir_: GameState.PlayerState.Dir,
		steps_: int
	) -> void:
		command = command_
		dir = dir_
		steps = steps_
	

enum Actions {NONE, UP, DOWN, LEFT, RIGHT, DASH}
const moveTrans = {
	GameState.PlayerState.Dir.UP: [0,1],
	GameState.PlayerState.Dir.LEFT: [-1,0],
	GameState.PlayerState.Dir.DOWN: [0,-1],
	GameState.PlayerState.Dir.RIGHT: [1,0],
}


var collisionMap: CollisionMap
var gamestate : GameState
var playerActions: Dictionary
var playerProc : Dictionary

func _init (gamestate_, collisionMap_) -> void:
	# Expects an initialized gamestate
	self.collisionMap = collisionMap_
	self.gamestate = gamestate_
	self.playerActions = {}
	self.playerProc = {}
	# Initializes players action buffer
	for id in self.gamestate.getPlayerIds():
		self.playerActions[id] = PlayerAction.new(
			Actions.NONE,
			GameState.PlayerState.Dir.UP,
			0
		)
		self.playerProc[id] = PlayerProc.new(0, 0, 0, 0, 0, 0)


func queueAction (playerId: int, action: Actions):
	if not self.playerActions.has(playerId): return
	var playerAction = self.playerActions[playerId]
	match action:
		Actions.UP:
			playerAction.reset(
				action,
				GameState.PlayerState.Dir.UP,
				1
			)
		Actions.RIGHT:
			playerAction.reset(
				action,
				GameState.PlayerState.Dir.RIGHT,
				1
			)
		Actions.DOWN:
			playerAction.reset(
				action,
				GameState.PlayerState.Dir.DOWN,
				1
			)
		Actions.LEFT:
			playerAction.reset(
				action,
				GameState.PlayerState.Dir.LEFT,
				1
			)
		Actions.DASH:
			var state = self.gamestate.getPlayerState(playerId)
			playerAction.reset(
				action,
				state[3],
				state[5]
			)

func perform ():
	var ids = self.playerActions.keys()
	var steps: int
	var state: Array
	var playerAction: PlayerAction
	var playerState : GameState.PlayerState.States
	# Initialize the data structure to perform the simulation
	for id in ids:
		steps = 0
		state = self.gamestate.getPlayerState(id)
		playerAction = self.playerActions[id]
		playerState = GameState.PlayerState.States.IDLE
		
		self.playerProc[id].reset(
			state[1],
			state[2],
			playerAction.dir,
			playerActions.steps,
			playerAction.dir,
			playerState
		)
		self.playerActions[id].reset(
			Actions.NONE,
			playerAction.dir
		)
	# Perform the simulation
	_simulate()
	# Update state
	_updateState()
	return

func _simulate ():
	var noMoreMoves: bool = false
	var nextX: int
	var nextY: int
	var collision: int
	while not noMoreMoves:
		noMoreMoves = true
		for player in self.playerProc.values():
			if not (player.count < player.steps) \
			or player.state == GameState.PlayerState.States.DEAD: continue
			noMoreMoves = false
			nextX = player.x + self.moveTrans[player.dir][0]
			nextY = player.y + self.moveTrans[player.dir][1]
			collision = _collidesWith(nextX, nextY)
			# If players collide
			if collision != -1:
				var target = self.playerProc[collision]
				if player.action == Actions.DASH:
					# Both players are dashing, stop them both
					if target.action == Actions.DASH:
						player.steps = player.count
						target.steps = target.count
						# TODO play hit sound + animation or something
					# Otherwise push the target
					else:
						target.count = 0
						target.x += self.moveTrans[player.dir][0]
						target.y += self.moveTrans[player.dir][1]
						target.state = GameState.PlayerState.States.PUSHED
				# If it's not dashing stop the player
				else:
					player.state = GameState.PlayerState.States.IDLE
					player.steps = player.count
					nextX = player.x
					nextY = player.y
			if _pushedOut(player.x, player.y):
				player.x = -1000
				player.y = -1000
				player.state = GameState.PlayerState.States.DEAD
			# Update players position
			player.x = nextX
			player.y = nextY
			player.count += 1

func _updateState():
	for id in self.playerProc.keys():
		var player = self.playerProc[id]
		var state = self.gamestate.getPlayerState(id)
		var newFace: int = state[5]
		var newFront: int = state[6]
		# Update face value
		for i in player.steps:
			#print("Face %d front %d" % [newFace, newFront])
			var value = DieSim.turnDie(newFace, newFront, player.dir)
			newFace = value[0]
			newFront = value[1]
		self.gamestate.setPlayerState(
			id,
			player.x,
			player.y,
			player.dir,
			player.state,
			newFace,
			newFront
		)

func _collidesWith (nextX, nextY):
	for id in self.playerProc.keys():
		var player = self.playerProc[id]
		if player.x == nextX and player.y == nextY:
			return id
	return -1

func _pushedOut (x, y):
	if collisionMap.getValue(x, y) == 0: return true
	return false

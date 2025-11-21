extends Object

class_name GameLogic

class PlayerProc:
	var x
	var y
	var dir
	var steps
	var action
	var count
	
	func _init(x_, y_, dir_, steps_, state_) -> void:
		reset(x_, y_, dir_, steps_, state_)
	
	
	func reset(x_, y_, dir_, steps_, action_) -> void:
		x = x_
		y = y_
		dir = dir_
		steps = steps_
		action = action_
		count = 0

enum Actions {NONE, UP, DOWN, LEFT, RIGHT, DASH}
const moveTrans = {
	GameState.PlayerState.Dir.UP: [0,1],
	GameState.PlayerState.Dir.LEFT: [-1,0],
	GameState.PlayerState.Dir.DOWN: [0,-1],
	GameState.PlayerState.Dir.RIGHT: [1,0],
}


var gamestate : GameState
var playerActions: Dictionary
var playerProc : Dictionary

func _init (gamestate_) -> void:
	# Expects an initialized gamestate
	self.gamestate = gamestate_
	self.playerActions = {}
	self.playerProc = {}
	# Initializes players action buffer
	for id in self.gamestate.getPlayerIds():
		self.playerActions[id] = Actions.NONE
		self.playerProc[id] = PlayerProc.new(0, 0, 0, 0, 0)


func queueAction (playerId: int, action: Actions):
	if not self.playerActions.has(playerId): return
	self.playerActions[playerId] = action


func perform ():
	var ids = self.playerActions.keys()
	var direction: int = 0
	var steps: int
	var state: Array
	var action: Actions
	# Initialize the data structure to perform the simulation
	for id in ids:
		direction = 0
		steps = 0
		state = self.gamestate.getPlayerState(id)
		action = self.playerActions[id]
		match action:
			Actions.UP:
				direction = GameState.PlayerState.Dir.UP
				steps = 1
			Actions.RIGHT:
				direction = GameState.PlayerState.Dir.RIGHT
				steps = 1
			Actions.DOWN:
				direction = GameState.PlayerState.Dir.DOWN
				steps = 1
			Actions.LEFT:
				direction = GameState.PlayerState.Dir.LEFT
				steps = 1
			Actions.DASH:
				direction = state[3]
				steps = state[5]
				
		self.playerProc[id].reset(state[1], state[2], direction, steps, action)
		self.playerActions[id] = Actions.NONE
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
			if not (player.count < player.steps): continue
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
						target.x = nextX
						target.y = nextY
				# If it's not dashing stop the player
				else:
					player.steps = player.count
					nextX = player.x
					nextY = player.y
			# TODO check for death conditions
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
			print("Face %d front %d" % [newFace, newFront])
			var value = DieSim.turnDie(newFace, newFront, player.dir)
			newFace = value[0]
			newFront = value[1]
		self.gamestate.setPlayerState(
			id,
			player.x,
			player.y,
			player.dir,
			null,
			newFace,
			newFront
		)

func _collidesWith (nextX, nextY):
	for id in self.playerProc.keys():
		var player = self.playerProc[id]
		if player.x == nextX and player.y == nextY:
			return id
	return -1

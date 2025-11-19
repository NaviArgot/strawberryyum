extends Object

class_name GameLogic

enum Actions {NONE, UP, DOWN, LEFT, RIGHT, DASH}

var gamestate : GameState
var playerActions: Dictionary

func _init (gamestate_) -> void:
	# Expects an initialized gamestate
	self.gamestate = gamestate_
	self.playerActions = {}
	# Initializes players action buffer
	for id in self.gamestate.getPlayerIds():
		self.playerActions[id] = Actions.NONE


func queueAction (playerId: int, action: Actions):
	if not self.playerActions.has(playerId): return
	self.playerActions[playerId] = action


func perform ():
	var ids = self.playerActions.keys()
	# Process action inputs from players
	for id in ids:
		match self.playerActions[id]:
			Actions.UP:
				_move(id, 0, 1)
			Actions.DOWN:
				_move(id, 0, -1)
			Actions.LEFT:
				_move(id, -1, 0)
			Actions.RIGHT:
				_move(id, 1, 0)
		self.playerActions[id] = Actions.NONE
	return
	

func _move(id: int, dx: int, dy: int):
	var state = self.gamestate.getPlayerState(id)
	print("%d %d %d %d %d" % [state[0], state[1], state[2], dx, dy])
	self.gamestate.setPlayerState(
		id,
		(state[1] + dx),
		(state[2] + dy)
	)

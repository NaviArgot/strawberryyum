extends Object

class_name GameState

signal state_changed(id, x, y, dir, state, face, front)

# Signal stuff when changes
class PlayerState:
	enum Dir {
		UP = DieSim.NORTH,
		DOWN = DieSim.SOUTH,
		RIGHT = DieSim.EAST,
		LEFT = DieSim.WEST,
	}
	enum States {IDLE, MOVING, DASH, CRASH, PUSHED, DEAD}
	var id: int
	var x: int
	var y: int
	var dir: int
	var face: int
	var front: int
	var state: int

	func _init(id_, x_, y_, dir_):
		self.id = id_
		self.x = x_
		self.y = y_
		self.dir = dir_
		self.state = States.MOVING
		self.face = 1
		self.front = 0


var players: Array

func _init():
	self.players = []


func getPlayerIds () -> Array:
	var ids = []
	for player in self.players:
		ids.push_back(player.id)
	return ids

func createPlayer(x_, y_, dir_):
	var id = self.players.size()
	var newPlayer = PlayerState.new(id, x_, y_, dir_)
	self.players.push_back(newPlayer)
	return id

func getPlayer(id):
	return self.players[id]


func setPlayerState(
		id: int, 
		x = null,
		y = null,
		dir = null,
		state = null,
		face = null,
		front = null
	):
	var p = self.players[id]
	var properties = ["x", "y", "dir", "state", "face", "front"]
	var values = [x, y, dir, state, face, front]
	var changed: bool = false
	for i in properties.size():
		changed = _updateState(p, properties[i], values[i]) or changed
	if changed:
		state_changed.emit(id, p.x, p.y, p.dir, p.state, p.face, p.front)

func _updateState (player, property, value) -> bool:
	var changed: bool = false
	if value != null and player[property] != value:
		changed = true
		player[property] = value
	return changed
	

## Returns player state, introduce the player id to query it!
## Returns an array as: [br]
## [code] [id, x, y, dir, state, face, front] [/code]
func getPlayerState(id):
	var p = self.players[id]
	return [p.id, p.x, p.y, p.dir, p.state, p.face, p.front]

func print():
	print("CURRENT STATE")
	for p in self.players:
		print("%d) x: %d	y: %d	s: %d	face: %d	front: %d"\
			% [p.id, p.x, p.y, p.state, p.face, p.front]
		)

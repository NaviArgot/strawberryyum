class_name PerceivedState extends RefCounted

class PerceivedPlayer extends RefCounted:
	var pos: Vector2i
	var dir: Constants.DIR
	var face: int
	var alive: bool
	
	func _init(pos_, dir_, face_) -> void:
		pos = pos_
		dir = dir_
		face = face_
		alive = true

var gamemap : GameMap
var players : Dictionary[int, PerceivedPlayer]

func _init(playerIDs : Array[int], gamemap_ : GameMap, pubstate : PublishableState) -> void:
	gamemap = gamemap_
	players = {}
	for id in playerIDs:
		players[id] = PerceivedPlayer.new(
			Vector2i(0,0),
			Constants.DIR.UP,
			1
		)
	pubstate.player_state_changed.connect(_on_player_state_changed)

func getPlayerPos(id : int) -> Vector2i:
	if id == -1: return Vector2i(0,0)
	return players[id].pos

func findClosestPlayer(x: int, y: int) -> int:
	if players.size() == 0: return -1
	var closestID : int = -1
	var closestScore : float = INF
	for id in players.keys():
		var p = players[id]
		var score = pow(x - p.pos.x, 2) + pow(y - p.pos.y, 2)
		if score < closestScore and p.alive:
			closestID = id
			closestScore = score
	return closestID

func _on_player_state_changed(
	id,
	x,
	y,
	dir,
	steps,
	face,
	front,
	anim,
	offsetAnim
):
	var player = players[id]
	player.pos.x = x
	player.pos.y = y
	player.dir = dir
	player.face = face
	if anim == PublishableState.ANIM.DEATH:
		player.alive = false

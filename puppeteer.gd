extends Node

class_name Puppeteer

var playerScene = preload("res://player.tscn")

var gamestate: GameState
var visuals: Dictionary

func _init(gamestate_) -> void:
	self.gamestate = gamestate_
	self.visuals = {}
	var ids = self.gamestate.getPlayerIds()
	# Initializes data representation
	for id in ids:
		var state = self.gamestate.getPlayerState(id)
		var player = playerScene.instantiate()
		self.visuals[id] = player
		player.setPos(state[1], state[2])
		# Don't forget to append your child to the tree!
		add_child(player)
	self.gamestate.state_changed.connect(_on_state_changed)

func _on_state_changed(id, x, y, dir, state, face, front):
	#print("X: %d Y: %d Dir: %d State: %d" % [x, y, dir, state])
	print("ID: %d STATE CHANGED %d" % [id, state])
	self.visuals[id].setDebug(face, front, state)
	self.visuals[id].animateState(0.1, x, y, dir, state, face, front)

extends Node

class_name Puppeteer

var playerScene = preload("res://client/player.tscn")

var playerIDs: Array
var pubstate: PublishableState
var visuals: Dictionary

func _init(playerIDs_, pubstate_) -> void:
	self.playerIDs = playerIDs_
	self.pubstate = pubstate_
	self.visuals = {}
	# Initializes data representation
	for id in self.playerIDs:
		var player = playerScene.instantiate()
		self.visuals[id] = player
		# Don't forget to append your child to the tree!
		add_child(player)
	self.pubstate.state_changed.connect(_on_state_changed)

func _on_state_changed(
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
	print("X: %d Y: %d Dir: %d Anim: %d" % [x, y, dir, anim])
	#print("ID: %d STATE CHANGED %d" % [id, anim])
	self.visuals[id].setDebug(face, front, anim)
	self.visuals[id].animateState(0.1, x, y, dir, anim, face, front)

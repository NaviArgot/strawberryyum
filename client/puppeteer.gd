extends Node

class_name Puppeteer

var playerScene = preload("res://client/visuals/player.tscn")

var playerIDs: Array
var pubstate: PublishableState
var visuals: Dictionary

func _init(playerIDs_, pubstate_) -> void:
	playerIDs = playerIDs_
	pubstate = pubstate_
	visuals = {}
	# Initializes data representation
	for id in playerIDs:
		var player = playerScene.instantiate()
		visuals[id] = player
		# Don't forget to append your child to the tree!
		add_child(player)
	pubstate.player_state_changed.connect(_on_player_state_changed)

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
	print("ID: %d X: %d Y: %d Dir: %d Anim: %d" % [id, x, y, dir, anim])
	#print("ID: %d STATE CHANGED %d" % [id, anim])
	visuals[id].setDebug(id, x, y, face, front, anim)
	visuals[id].animateState(0.1, x, y, dir, anim, face, front)

func reset():
	for vis in visuals.values():
		vis.reset()

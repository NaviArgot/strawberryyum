class_name ActionBuffer extends RefCounted

var playerAction: Dictionary[int, Constants.ACTION]

func _init(playerIDs):
	for id in playerIDs:
		playerAction[id] = Constants.ACTION.NONE

func setAction(id: int, action: Constants.ACTION):
	if not playerAction.has(id): return
	playerAction[id] = action

func getAction (id: int):
	return playerAction[id]

func reset():
	for id in playerAction.keys():
		playerAction[id] = Constants.ACTION.NONE

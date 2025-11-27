extends Node3D

var gamestate: GameState
var playerIds: Array[int]
var controllerToPlayer: Dictionary[int, int]
var gamelogic: GameLogic
var puppeteer: Puppeteer

var counter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	counter = 0
	self.gamestate = GameState.new()
	self.playerIds = []
	self.controllerToPlayer = {}
	for i in 2:
		var id = self.gamestate.createPlayer(i,i,0)
		self.playerIds.push_back(id)
	self.gamelogic = GameLogic.new(self.gamestate)
	self.puppeteer = Puppeteer.new(self.gamestate)
	add_child(self.puppeteer)

func _receiveInput ():
	if counter > 0:
		counter -= 1
		return
	counter = 3
	if Input.is_action_pressed("move_up"):
		self.gamelogic.queueAction(
			self.playerIds[0],
			GameLogic.Actions.DOWN
		)
	elif Input.is_action_pressed("move_left"):
		self.gamelogic.queueAction(
			self.playerIds[0],
			GameLogic.Actions.LEFT
		)
	elif Input.is_action_pressed("move_down"):
		self.gamelogic.queueAction(
			self.playerIds[0],
			GameLogic.Actions.UP
		)
	elif Input.is_action_pressed("move_right"):
		self.gamelogic.queueAction(
			self.playerIds[0],
			GameLogic.Actions.RIGHT
		)
	elif Input.is_action_pressed("dash"):
		self.gamelogic.queueAction(
			self.playerIds[0],
			GameLogic.Actions.DASH
		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.gamelogic.perform()
	_receiveInput()
	#self.gamestate.print()
	

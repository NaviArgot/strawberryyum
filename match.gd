extends Node3D

var gamestate: GameState
var playerIds: Array[int]
var controllerToPlayer: Dictionary[int, int]
var gamelogic: GameLogic
var puppeteer: Puppeteer

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	self.gamestate = GameState.new()
	self.playerIds = []
	self.controllerToPlayer = {}
	for i in 2:
		var id = self.gamestate.createPlayer(0,0)
		self.playerIds.push_back(id)
	self.gamelogic = GameLogic.new(self.gamestate)
	self.puppeteer = Puppeteer.new(self.gamestate)
	add_child(self.puppeteer)

func _receiveInput ():
	if Input.is_action_pressed("move_up"):
		self.gamelogic.queueAction(
			self.playerIds[0],
			GameLogic.Actions.UP
		)
	elif Input.is_action_pressed("move_left"):
		self.gamelogic.queueAction(
			self.playerIds[0],
			GameLogic.Actions.LEFT
		)
	elif Input.is_action_pressed("move_down"):
		self.gamelogic.queueAction(
			self.playerIds[0],
			GameLogic.Actions.DOWN
		)
	elif Input.is_action_pressed("move_right"):
		self.gamelogic.queueAction(
			self.playerIds[0],
			GameLogic.Actions.RIGHT
		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.gamelogic.perform()
	_receiveInput()
	#self.gamestate.print()
	

extends Node3D

var pubstate: PublishableState
var playerIDs: Array[int]
var controllerToPlayer: Dictionary[int, int]
var gamelogic: GameLogic
var puppeteer: Puppeteer
var collisionMap: CollisionMap

var counter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	counter = 0
	self.pubstate = PublishableState.new()
	self.playerIDs = []
	self.controllerToPlayer = {}
	for i in 2:
		self.playerIDs.push_back(i)
	self.gamelogic = GameLogic.new(
		self.playerIDs,
		self.pubstate,
		CollisionMap.new(Vector2i(-2, -2))
	)
	self.puppeteer = Puppeteer.new(self.playerIDs, self.pubstate)
	add_child(self.puppeteer)

func _receiveInput ():
	if counter > 0:
		counter -= 1
		return
	counter = 5
	if Input.is_action_pressed("move_up"):
		self.gamelogic.queueAction(
			self.playerIDs[0],
			GameLogic.ACTION.DOWN
		)
	elif Input.is_action_pressed("move_left"):
		self.gamelogic.queueAction(
			self.playerIDs[0],
			GameLogic.ACTION.LEFT
		)
	elif Input.is_action_pressed("move_down"):
		self.gamelogic.queueAction(
			self.playerIDs[0],
			GameLogic.ACTION.UP
		)
	elif Input.is_action_pressed("move_right"):
		self.gamelogic.queueAction(
			self.playerIDs[0],
			GameLogic.ACTION.RIGHT
		)
	elif Input.is_action_pressed("dash"):
		self.gamelogic.queueAction(
			self.playerIDs[0],
			GameLogic.ACTION.DASH
		)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.gamelogic.perform()
	_receiveInput()
	#self.gamestate.print()
	

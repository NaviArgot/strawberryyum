extends Node3D

var pubstate: PublishableState
var playerIDs: Array[int]
var controllerToPlayer: Dictionary[int, int]
var gamelogic: GameLogic
var puppeteer: Puppeteer
var collisionMap: CollisionMap
var debugMap: DebugMap


var counter

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	counter = 0
	self.pubstate = PublishableState.new()
	self.playerIDs = []
	self.controllerToPlayer = {}
	self.collisionMap = CollisionMap.new(8, 8, Vector2i(-4, -4))
	self.debugMap = DebugMap.new($GameMap)
	for i in 2:
		self.playerIDs.push_back(i)
	self.puppeteer = Puppeteer.new(self.playerIDs, self.pubstate)
	_initGameLogic()
	add_child(self.puppeteer)
	#add_child(self.debugMap)
	self.pubstate.state_changed.connect(_on_state_changed)

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
	elif Input.is_action_pressed("debug_reset"):
		_initGameLogic()
		self.puppeteer.reset()
		

func _initGameLogic():
	if self.gamelogic: self.gamelogic.free()
	self.gamelogic = GameLogic.new(
		self.playerIDs,
		self.pubstate,
		$GameMap
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	self.gamelogic.perform()
	_receiveInput()
	#self.gamestate.print()
	

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
	if id == 0:
		$Camera3D.setTarget(Vector3(x, 0.0, y))

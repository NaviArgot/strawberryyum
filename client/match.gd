extends Node3D

var playerIDs: Array[int]
var controllers: Array[Controller]
var actionBuffer: ActionBuffer
var pubstate: PublishableState
var gamelogic: GameLogic
var puppeteer: Puppeteer

var nPlayers = 2

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	playerIDs = []
	for id in nPlayers: playerIDs.push_back(id)
	actionBuffer = ActionBuffer.new(playerIDs)
	controllers = []
	for id in nPlayers:
		print(id)
		if id == 0:
			controllers.push_back(PlayerController.new(id, actionBuffer))
		else:
			controllers.push_back(AIController.new(id, actionBuffer, PerceivedState.new()))
	pubstate = PublishableState.new()
	puppeteer = Puppeteer.new(playerIDs, pubstate)
	_initGameLogic()
	add_child(puppeteer)
	pubstate.state_changed.connect(_on_state_changed)

func _receiveInput ():
	if Input.is_action_pressed("debug_reset"):
		_initGameLogic()
		puppeteer.reset()
		

func _initGameLogic():
	if gamelogic: gamelogic.free()
	gamelogic = GameLogic.new(
		playerIDs,
		pubstate,
		$GameMap,
		actionBuffer
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for controller in controllers:
		controller.perform()
	gamelogic.perform(delta)
	_receiveInput()
	#gamestate.print()
	

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

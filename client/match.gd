extends Node3D

enum GAMESTATES {TITLE, GAMEPLAY, RETRY}

const MAPS = [
	preload("res://assets/maps/basic.tscn")
]

var playerIDs: Array[int]
var controllers: Array[Controller]
var actionBuffer: ActionBuffer
var pubstate: PublishableState
var gamelogic: GameLogic
var puppeteer: Puppeteer
var perceivedState : PerceivedState
var map : Node

var gamestate : GAMESTATES

# Called when  the node enters the scene tree for the first time.
func _ready() -> void:
	var mapTree = MAPS[0].instantiate()
	map = mapTree.get_node("GameMap")
	add_child(mapTree)
	playerIDs = []
	var spawnPoints = map.getSpawnPoints()
	for id in spawnPoints.size():
		playerIDs.push_back(id)
	actionBuffer = ActionBuffer.new(playerIDs)
	pubstate = PublishableState.new()
	perceivedState = PerceivedState.new(playerIDs, map, pubstate)
	puppeteer = Puppeteer.new(playerIDs, pubstate)
	add_child(puppeteer)
	pubstate.player_state_changed.connect(_on_player_state_changed)
	gamestate = GAMESTATES.TITLE
	$Timer.timeout.connect(_on_timer_timeout)
	startNoPlayer()

func startNoPlayer():
	controllers = []
	for id in playerIDs.size():
		controllers.push_back(
			AIController.new(
				id,
				actionBuffer,
				perceivedState
			)
		)
	_initGameLogic()
	puppeteer.reset()
	

func startWithPlayer():
	controllers = []
	for id in playerIDs.size():
		if id == 0:
			controllers.push_back(PlayerController.new(id, actionBuffer))
		else:
			controllers.push_back(
				AIController.new(
					id,
					actionBuffer,
					perceivedState
				)
			)
	_initGameLogic()
	puppeteer.reset() 
	$UI.visible = true
	$Timer.neoStart(get_node("UI/TimerLabel"))

func showRetryScreen():
	gamestate = GAMESTATES.RETRY
	$Retry.visible = true
	$RetryTimer.start()
	$UI.visible = false

func _receiveInput ():
	match gamestate:
		GAMESTATES.TITLE:
			if  Input.is_action_pressed("any"):
				gamestate = GAMESTATES.GAMEPLAY
				startWithPlayer()
				$Title.visible = false
		GAMESTATES.RETRY:
			if  Input.is_action_pressed("any") and $RetryTimer.time_left == 0.0:
				gamestate = GAMESTATES.GAMEPLAY
				startWithPlayer()
				$Title.visible = false
				$Retry.visible = false
	if Input.is_action_pressed("debug_reset"):
		_initGameLogic()
		puppeteer.reset()
	elif Input.is_action_pressed("debug_publish"):
		gamelogic.forcePublish()

func _initGameLogic():
	if gamelogic: gamelogic.free()
	gamelogic = GameLogic.new(
		playerIDs,
		map.getSpawnPoints(),
		pubstate,
		map,
		actionBuffer
	)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	for controller in controllers:
		controller.perform()
	gamelogic.perform(delta)
	_receiveInput()
	#gamestate.print()
	

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
	if id == 0 and gamestate == GAMESTATES.GAMEPLAY:
		if anim == PublishableState.ANIM.DEATH:
			showRetryScreen()
		$Camera3D.setTarget(Vector3(x, 0.0, y))

func _on_timer_timeout():
	showRetryScreen()

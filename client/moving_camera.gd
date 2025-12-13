class_name MovingCamera
extends Camera3D

@export var speed: float = 1.0
@export var offset: Vector3 =  Vector3(0.0, 0.0, 0.0)
@export var transType := Tween.TransitionType.TRANS_CUBIC
@export var easeType := Tween.EaseType.EASE_OUT

var time: float
var pos: Vector3
var start: Vector3
var target: Vector3

func setTarget (target_: Vector3):
	time = 0.0
	start = pos
	target = target_
	print("CHANFEDS")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pos = Vector3(0.0, 0.0, 0.0)
	start = Vector3(0.0, 0.0, 0.0)
	target = Vector3(0.0, 0.0, 0.0)
	position = pos + offset


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	time = min(time + delta * speed, 1.0)
	var weight = Tween.interpolate_value(
		0.0,
		1.0,
		time,
		1.0,
		transType,
		easeType
	)
	pos = lerp(start, target, weight)
	position = pos + offset

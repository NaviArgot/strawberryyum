class_name TimedCount extends RefCounted

var threshold: float
var amount: float

func _init(threshold_) -> void:
	threshold = threshold_
	amount = 0

func isReady() -> bool:
	return amount <= 0.0

func update(delta : float):
	amount = amount - delta if amount > 0.0 else 0.0

func reset():
	amount = threshold

class_name GameMap
extends GridMap

@export var spawnPoints: Array[Vector2i]
@export var collisions: Dictionary [String, int]
var _fastColl: Array [int]

func _ready ():
	_computeFastCollisions()

func _computeFastCollisions():
	var meshItems: PackedInt32Array = mesh_library.get_item_list()
	_fastColl = []
	_fastColl.resize(meshItems.size())
	for item in meshItems:
		var theNAME = mesh_library.get_item_name(item)
		assert(
			collisions.has(theNAME),
			"Dictionary doesn't contain a collision id for %s cell type" % [
				theNAME
			]
		)
		_fastColl[item] = collisions.get(theNAME)
	
func getCellCollision(x: int, y: int):
	var item = get_cell_item(Vector3i(x, 0, y))
	return 0 if item == INVALID_CELL_ITEM else _fastColl[item]

func getSpawnPoints():
	return spawnPoints

func print():
	print(collisions)

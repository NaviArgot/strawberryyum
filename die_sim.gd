extends Object

class_name DieSim

static var transitions = {
	1: {
		0: {'face': 2, 'addToFront': 0},
		1: {'face': 5, 'addToFront': 0},
		2: {'face': 4, 'addToFront': 0},
		3: {'face': 6, 'addToFront': 0}
	},
	2: {
		0: {'face': 3, 'addToFront': 0},
		1: {'face': 5, 'addToFront': 1},
		2: {'face': 1, 'addToFront': 0},
		3: {'face': 6, 'addToFront': 1}
	},
	3: {
		0: {'face': 4, 'addToFront': 0},
		1: {'face': 5, 'addToFront': 2},
		2: {'face': 2, 'addToFront': 0},
		3: {'face': 6, 'addToFront': 2}
	},
	4: {
		0: {'face': 1, 'addToFront': 0},
		1: {'face': 5, 'addToFront': 3},
		2: {'face': 3, 'addToFront': 0},
		3: {'face': 6, 'addToFront': 3}
	},
	5: {
		0: {'face': 2, 'addToFront': 1},
		1: {'face': 3, 'addToFront': 2},
		2: {'face': 4, 'addToFront': 3},
		3: {'face': 1, 'addToFront': 0}
	},
	6: {
		0: {'face': 2, 'addToFront': 1},
		1: {'face': 1, 'addToFront': 0},
		2: {'face': 4, 'addToFront': 3},
		3: {'face': 3, 'addToFront': 2}
	}
}


static func turnDie (currFace: int, currFront: int, direction: int):
	var targetEdge := (currFront + direction) % 4
	var nextFace = transitions[currFace][targetEdge].face
	var nextFront = currFront + transitions[currFace][targetEdge].addToFront
	return [nextFace, nextFront]

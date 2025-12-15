extends Object

class_name PublishableState

signal player_state_changed(
	id,
	x,
	y,
	dir,
	steps,
	face,
	front,
	anim,
	offsetAnim
)

enum ANIM {IDLE, MOVE, DASH, CRASH, PUSHED, DEATH}

func publishState(
		id: int, 
		x: int,
		y: int,
		dir: Constants.DIR,
		steps: int,
		face: int,
		front: int,
		anim: ANIM,
		offsetAnim: int
	):
		player_state_changed.emit(
			id,
			x,
			y,
			dir,
			steps,
			face,
			front,
			anim,
			offsetAnim
		)

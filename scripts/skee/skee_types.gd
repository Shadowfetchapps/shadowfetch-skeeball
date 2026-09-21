class_name SkeeTypes
extends RefCounted

enum Mode { CLASSIC, HIGH_SCORE, TIMED, PRECISION }
enum Phase { THROWING, SETTLING, OVER }

const HOLES := [
	{"pts": 100, "x": 0.0, "y": 0.22, "r": 0.038},
	{"pts": 50, "x": 0.0, "y": 0.08, "r": 0.052},
	{"pts": 40, "x": -0.12, "y": 0.015, "r": 0.058},
	{"pts": 30, "x": 0.12, "y": 0.015, "r": 0.058},
	{"pts": 20, "x": 0.0, "y": -0.085, "r": 0.068},
]
const BOARD_HALF_X := 0.28
const BOARD_MIN_Y := -0.22
const BOARD_MAX_Y := 0.30
const BALLS_CLASSIC := 9
const TIMED_SECONDS := 60.0


static func mode_name(mode: Mode) -> String:
	match mode:
		Mode.HIGH_SCORE:
			return "High Score"
		Mode.TIMED:
			return "Timed"
		Mode.PRECISION:
			return "Precision"
		_:
			return "Classic"

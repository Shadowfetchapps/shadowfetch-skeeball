class_name SkeeBoard
extends RefCounted

const Types = preload("res://scripts/skee/skee_types.gd")


static func score_m(x: float, y: float) -> Dictionary:
	if not is_finite(x) or not is_finite(y):
		return {"points": 0, "label": "Miss", "hole": 0}
	if absf(x) > Types.BOARD_HALF_X or y < Types.BOARD_MIN_Y or y > Types.BOARD_MAX_Y:
		return {"points": 0, "label": "Miss", "hole": 0}
	for hole in Types.HOLES:
		var dx: float = x - float(hole["x"])
		var dy: float = y - float(hole["y"])
		if dx * dx + dy * dy < float(hole["r"]) * float(hole["r"]):
			var pts: int = int(hole["pts"])
			return {"points": pts, "label": str(pts), "hole": pts}
	return {"points": 10, "label": "10", "hole": 10}


static func hole_center(pts: int) -> Vector2:
	for hole in Types.HOLES:
		if int(hole["pts"]) == pts:
			return Vector2(float(hole["x"]), float(hole["y"]))
	return Vector2(0, -0.16)

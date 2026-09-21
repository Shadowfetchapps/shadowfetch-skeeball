extends RefCounted

const Types = preload("res://scripts/skee/skee_types.gd")
const Board = preload("res://scripts/skee/skee_board.gd")
const Rules = preload("res://scripts/skee/skee_engine.gd")

var _failures: Array[String] = []
var _checks := 0


func run_all() -> bool:
	_holes()
	_borders()
	_one_score()
	_modes()
	_random(12000)
	print("Skee checks: %d  failures: %d" % [_checks, _failures.size()])
	for m in _failures:
		print("FAIL: ", m)
	return _failures.is_empty()


func _holes() -> void:
	_eq(0, 0.22, 100)
	_eq(0, 0.08, 50)
	_eq(-0.12, 0.015, 40)
	_eq(0.12, 0.015, 30)
	_eq(0, -0.085, 20)
	_eq(0, -0.18, 10)
	_eq(0.4, 0.0, 0)
	_eq(0, 0.5, 0)
	var nan_hit: Dictionary = Board.score_m(INF, NAN)
	_ok(int(nan_hit["points"]) == 0, "nan miss")


func _borders() -> void:
	for hole in Types.HOLES:
		var c := Vector2(float(hole["x"]), float(hole["y"]))
		var r: float = float(hole["r"])
		var pts: int = int(hole["pts"])
		_eq(c.x, c.y, pts)
		var inside := c + Vector2(r * 0.92, 0)
		_eq(inside.x, inside.y, pts)
		var outside := c + Vector2(r + 0.01, 0)
		var oh: Dictionary = Board.score_m(outside.x, outside.y)
		_ok(int(oh["points"]) != pts, "outside %d" % pts)


func _one_score() -> void:
	var e := Rules.new()
	e.reset(Types.Mode.CLASSIC)
	var id := e.new_ball()
	var a: Dictionary = e.apply_landing(id, 0.0, 0.22)
	var b: Dictionary = e.apply_landing(id, 0.0, 0.22)
	_ok(a["accepted"] == true and b["duplicate"] == true, "one ball one score")
	_ok(e.score == 100, "100 once")


func _modes() -> void:
	var e := Rules.new()
	e.reset(Types.Mode.CLASSIC)
	for i in Types.BALLS_CLASSIC:
		e.apply_landing(e.new_ball(), 0.0, -0.18)
	_ok(e.phase == Types.Phase.OVER and e.score == 90, "classic nine tens")
	e.reset(Types.Mode.HIGH_SCORE)
	e.apply_landing(e.new_ball(), 0.0, 0.08)
	e.apply_landing(e.new_ball(), 0.0, 0.08)
	_ok(e.score == 50 + 100, "combo second 50 x2")
	e.reset(Types.Mode.TIMED)
	e.tick_clock(Types.TIMED_SECONDS)
	_ok(e.phase == Types.Phase.OVER, "timed ends")
	e.reset(Types.Mode.PRECISION)
	e.target_hole = 50
	e.apply_landing(e.new_ball(), 0.0, 0.08)
	_ok(e.score == 50, "precision hit")


func _random(n: int) -> void:
	var rng := RandomNumberGenerator.new()
	rng.seed = 20260920
	var scored := 0
	for i in n:
		var x := rng.randf_range(-0.4, 0.4)
		var y := rng.randf_range(-0.35, 0.4)
		var a: Dictionary = Board.score_m(x, y)
		var b: Dictionary = Board.score_m(x, y)
		_ok(int(a["points"]) == int(b["points"]), "deterministic %d" % i)
		_ok(int(a["points"]) in [0, 10, 20, 30, 40, 50, 100], "legal pts %d" % i)
		if absf(x) > Types.BOARD_HALF_X or y < Types.BOARD_MIN_Y or y > Types.BOARD_MAX_Y:
			_ok(int(a["points"]) == 0, "outside miss %d" % i)
		if int(a["points"]) > 0:
			scored += 1
	_ok(scored > 100, "many in-play")
	_ok(n == 12000, "12000 throws")


func _eq(x: float, y: float, pts: int) -> void:
	var h: Dictionary = Board.score_m(x, y)
	_ok(int(h["points"]) == pts, "(%s,%s) expect %d got %s" % [x, y, pts, h["points"]])


func _ok(cond: bool, msg: String) -> void:
	_checks += 1
	if not cond:
		_failures.append(msg)

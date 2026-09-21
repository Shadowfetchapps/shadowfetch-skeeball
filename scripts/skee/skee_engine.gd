class_name SkeeEngine
extends RefCounted

const Types = preload("res://scripts/skee/skee_types.gd")
const Board = preload("res://scripts/skee/skee_board.gd")

var mode: Types.Mode = Types.Mode.CLASSIC
var phase: Types.Phase = Types.Phase.THROWING
var score: int = 0
var balls_left: int = Types.BALLS_CLASSIC
var combo: int = 0
var time_left: float = Types.TIMED_SECONDS
var target_hole: int = 50
var last_points: int = 0
var last_message: String = "Roll."
var _ball_id: int = 0
var _scored_ids: Dictionary = {}


func reset(p_mode: Types.Mode) -> void:
	mode = p_mode
	phase = Types.Phase.THROWING
	score = 0
	balls_left = 99 if mode == Types.Mode.TIMED else Types.BALLS_CLASSIC
	combo = 0
	time_left = Types.TIMED_SECONDS
	target_hole = 50
	last_points = 0
	last_message = "Roll."
	_ball_id = 0
	_scored_ids.clear()


func new_ball() -> int:
	_ball_id += 1
	return _ball_id


func apply_landing(ball_id: int, x: float, y: float) -> Dictionary:
	if _scored_ids.has(ball_id):
		return {"accepted": false, "duplicate": true, "points": 0}
	var hit: Dictionary = Board.score_m(x, y)
	_scored_ids[ball_id] = true
	var pts: int = int(hit["points"])
	last_points = pts
	if mode == Types.Mode.PRECISION:
		if pts == target_hole:
			score += pts * (1 + mini(combo, 4))
			combo += 1
			last_message = "Precision %d" % pts
			_next_target()
		else:
			combo = 0
			last_message = "Need %d" % target_hole
	elif mode == Types.Mode.HIGH_SCORE:
		var mult := 1 + mini(combo, 4)
		score += pts * mult
		last_message = "%d  ×%d" % [pts, mult]
		if pts >= 30:
			combo += 1
		else:
			combo = 0
	else:
		score += pts
		last_message = str(pts) if pts > 0 else "Miss"
	if mode != Types.Mode.TIMED:
		balls_left = maxi(balls_left - 1, 0)
		if balls_left <= 0:
			phase = Types.Phase.OVER
	return {"accepted": true, "duplicate": false, "points": pts, "total": score}


func tick_clock(dt: float) -> void:
	if mode != Types.Mode.TIMED or phase == Types.Phase.OVER:
		return
	time_left = maxf(time_left - dt, 0.0)
	if time_left <= 0.0:
		phase = Types.Phase.OVER


func _next_target() -> void:
	var opts: Array[int] = [20, 30, 40, 50, 100]
	target_hole = opts[_ball_id % opts.size()]

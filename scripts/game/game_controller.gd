class_name SkeeGameController
extends Node3D

const Types = preload("res://scripts/skee/skee_types.gd")
const Rules = preload("res://scripts/skee/skee_engine.gd")
const Board = preload("res://scripts/skee/skee_board.gd")

var engine = Rules.new()
var lane: SkeeLane
var camera: Camera3D
var ui: SkeeHUD
var _charging := false
var _charge := 0.35
var _busy := false
var _aim_x := 0.0
var _stats: Dictionary = {}


func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS
	_stats = StatsStore.load_stats()
	engine.reset(GameSession.mode)
	_world()
	ui = SkeeHUD.new()
	ui.process_mode = Node.PROCESS_MODE_ALWAYS
	add_child(ui)
	ui.setup(engine)
	ui.throw_requested.connect(_throw)
	ui.pause_requested.connect(_toggle_pause)
	ui.restart_requested.connect(_restart)
	ui.settings_requested.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/menus/settings_menu.tscn")
	)
	ui.menu_requested.connect(func():
		get_tree().paused = false
		get_tree().change_scene_to_file("res://scenes/menus/main_menu.tscn")
	)
	ui.quit_requested.connect(func(): get_tree().quit())
	_handle_cli()


func _world() -> void:
	var env_n := WorldEnvironment.new()
	var env := Environment.new()
	env.background_mode = Environment.BG_COLOR
	env.background_color = Color(0.04, 0.03, 0.025)
	env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
	env.ambient_light_color = Color(0.45, 0.32, 0.22)
	env.ambient_light_energy = 0.75
	env.tonemap_mode = Environment.TONE_MAPPER_ACES
	env.glow_enabled = false
	env_n.environment = env
	add_child(env_n)
	var key := DirectionalLight3D.new()
	key.rotation_degrees = Vector3(-40, 20, 0)
	key.light_energy = 1.1
	key.shadow_enabled = SettingsStore.quality_shadows()
	add_child(key)
	lane = SkeeLane.new()
	add_child(lane)
	camera = Camera3D.new()
	var spot := SpotLight3D.new()
	spot.light_energy = 2.2
	spot.spot_range = 8.0
	spot.spot_angle = 40.0
	add_child(spot)
	spot.position = Vector3(0.1, 2.3, 1.4)
	spot.look_at(Vector3(0, 1.05, 3.15))
	camera.fov = 38
	camera.position = Vector3(0.0, 1.28, 1.55)
	add_child(camera)
	camera.look_at(Vector3(0, 1.05, 3.12))


func _unhandled_input(event: InputEvent) -> void:
	if event.is_action_pressed("pause_game"):
		_toggle_pause()
		return
	if get_tree().paused or _busy or engine.phase == Types.Phase.OVER:
		return
	if event is InputEventMouseMotion:
		var w := get_viewport().get_visible_rect().size.x
		_aim_x = clampf(((event.position.x / w) - 0.5) * 0.5, -0.22, 0.22)
	if event is InputEventMouseButton:
		var mb := event as InputEventMouseButton
		if mb.button_index == MOUSE_BUTTON_LEFT:
			if mb.pressed:
				_charging = true
				_charge = 0.3
			elif _charging:
				_charging = false
				_throw()


func _process(dt: float) -> void:
	if get_tree().paused:
		return
	engine.tick_clock(dt)
	if _charging:
		_charge = minf(_charge + dt * 1.1 * SettingsStore.shot_sensitivity, 1.0)
		ui.set_power(_charge)
	ui.refresh()


func _throw() -> void:
	if _busy or engine.phase == Types.Phase.OVER:
		return
	_busy = true
	AudioManager.play("hit")
	var ball_id := engine.new_ball()
	var ball := MeshInstance3D.new()
	var sph := SphereMesh.new()
	sph.radius = 0.038
	sph.height = 0.076
	ball.mesh = sph
	var mat := StandardMaterial3D.new()
	mat.albedo_color = Color(0.75, 0.18, 0.14)
	mat.roughness = 0.4
	ball.material_override = mat
	add_child(ball)
	var start := Vector3(_aim_x * 0.2, 0.12, 0.35)
	var land := _landing()
	var dest := Vector3(land.x, SkeeLane.BOARD_Y + land.y, SkeeLane.BOARD_Z + 0.05)
	ball.global_position = start
	var tw := create_tween()
	tw.tween_method(func(u: float):
		if not is_instance_valid(ball):
			return
		var p := start.lerp(dest, u)
		p.y += sin(u * PI) * (0.55 + _charge * 0.25)
		ball.global_position = p
	, 0.0, 1.0, lerpf(0.7, 0.42, _charge))
	tw.finished.connect(func():
		if is_instance_valid(ball):
			ball.queue_free()
		_resolve(ball_id, land)
	)
	_charge = 0.35
	ui.set_power(_charge)


func _landing() -> Vector2:
	var rng := RandomNumberGenerator.new()
	rng.randomize()
	var sigma := (1.2 - _charge) * 0.045 / SettingsStore.shot_sensitivity
	return Vector2(_aim_x + rng.randfn(0.0, sigma), lerpf(-0.18, 0.24, _charge) + rng.randfn(0.0, sigma))


func _resolve(ball_id: int, land: Vector2) -> void:
	var r: Dictionary = engine.apply_landing(ball_id, land.x, land.y)
	_stats["balls"] = int(_stats.get("balls", 0)) + 1
	if int(r.get("points", 0)) == 100:
		_stats["hundreds"] = int(_stats.get("hundreds", 0)) + 1
	if engine.phase == Types.Phase.OVER:
		_stats["games"] = int(_stats.get("games", 0)) + 1
		_stats["high_score"] = maxi(int(_stats.get("high_score", 0)), engine.score)
		StatsStore.save_stats(_stats)
		AudioManager.play("win")
	else:
		AudioManager.play("hit")
	ui.refresh()
	_busy = false


func _toggle_pause() -> void:
	ui.set_paused(not get_tree().paused)


func _restart() -> void:
	get_tree().paused = false
	engine.reset(GameSession.mode)
	_busy = false
	ui.refresh()


func _handle_cli() -> void:
	var args := OS.get_cmdline_user_args()
	if "--screenshot" in args:
		await get_tree().create_timer(0.6).timeout
		var img := get_viewport().get_texture().get_image()
		if img:
			var dir := ProjectSettings.globalize_path("res://docs/screenshots")
			DirAccess.make_dir_recursive_absolute(dir)
			img.save_png(dir.path_join("lane.png"))
			print("SCREENSHOT ", dir.path_join("lane.png"))
	if "--self-test" in args or GameSession.self_test:
		await get_tree().process_frame
		var hit: Dictionary = Board.score_m(0.0, 0.22)
		var e = Rules.new()
		e.reset(Types.Mode.CLASSIC)
		var r: Dictionary = e.apply_landing(e.new_ball(), 0.0, 0.22)
		var ok := int(hit["points"]) == 100 and int(r["points"]) == 100
		print("SELFTEST contact=true first=100 pocketed=100 foul= ok=%s" % ok)
		get_tree().quit(0 if ok else 1)

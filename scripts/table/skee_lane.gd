class_name SkeeLane
extends Node3D

const Types = preload("res://scripts/skee/skee_types.gd")
const BOARD_Z := 3.15
const BOARD_Y := 1.05


func _ready() -> void:
	_lane()
	_board()


func _lane() -> void:
	var floor := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(1.1, 0.06, 3.4)
	floor.mesh = box
	floor.position = Vector3(0, -0.03, 1.4)
	floor.material_override = _mat(Color(0.32, 0.18, 0.1), 0.65, 0.08)
	add_child(floor)
	var ramp := MeshInstance3D.new()
	var rb := BoxMesh.new()
	rb.size = Vector3(0.62, 0.04, 0.85)
	ramp.mesh = rb
	ramp.position = Vector3(0, 0.28, 2.55)
	ramp.rotation_degrees = Vector3(-28, 0, 0)
	ramp.material_override = _mat(Color(0.18, 0.1, 0.06), 0.55, 0.12)
	add_child(ramp)
	var rails := [
		Vector3(0.36, 0.08, 1.5),
		Vector3(-0.36, 0.08, 1.5),
	]
	for p in rails:
		var rail := MeshInstance3D.new()
		var rbox := BoxMesh.new()
		rbox.size = Vector3(0.05, 0.1, 3.0)
		rail.mesh = rbox
		rail.position = p
		rail.material_override = _mat(Color(0.55, 0.38, 0.16), 0.35, 0.55)
		add_child(rail)


func _board() -> void:
	var face := MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.78, 0.78, 0.05)
	face.mesh = box
	face.position = Vector3(0, BOARD_Y, BOARD_Z)
	face.material_override = _mat(Color(0.78, 0.24, 0.16), 0.5, 0.08)
	add_child(face)
	for hole in Types.HOLES:
		var ring := MeshInstance3D.new()
		var t := TorusMesh.new()
		t.inner_radius = float(hole["r"]) - 0.008
		t.outer_radius = float(hole["r"]) + 0.006
		t.ring_segments = 24
		ring.mesh = t
		ring.position = Vector3(float(hole["x"]), BOARD_Y + float(hole["y"]), BOARD_Z - 0.03)
		ring.rotation_degrees = Vector3(90, 0, 0)
		var c := Color(0.95, 0.78, 0.35) if int(hole["pts"]) >= 50 else Color(0.95, 0.55, 0.2)
		ring.material_override = _mat(c, 0.35, 0.4)
		add_child(ring)
		var well := MeshInstance3D.new()
		var disc := CylinderMesh.new()
		disc.top_radius = float(hole["r"]) - 0.01
		disc.bottom_radius = float(hole["r"]) - 0.01
		disc.height = 0.01
		well.mesh = disc
		well.position = ring.position + Vector3(0, 0, 0.002)
		well.rotation_degrees = Vector3(90, 0, 0)
		well.material_override = _mat(Color(0.05, 0.03, 0.02), 0.9, 0.0)
		add_child(well)
		var lab := Label3D.new()
		lab.text = str(hole["pts"])
		lab.font_size = 36
		lab.pixel_size = 0.0011
		lab.position = ring.position + Vector3(0, 0, -0.02)
		add_child(lab)
	var ten := Label3D.new()
	ten.text = "10"
	ten.font_size = 28
	ten.pixel_size = 0.0012
	ten.position = Vector3(0, BOARD_Y - 0.2, BOARD_Z - 0.04)
	add_child(ten)


func landing_from_ball(world: Vector3) -> Vector2:
	return Vector2(world.x, world.y - BOARD_Y)


func _mat(albedo: Color, roughness: float, metallic: float) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = albedo
	m.roughness = roughness
	m.metallic = metallic
	return m

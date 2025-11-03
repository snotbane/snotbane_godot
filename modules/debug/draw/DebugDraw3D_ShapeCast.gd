
@tool class_name DebugDraw3D_ShapeCast extends DebugDraw3D

var cast : ShapeCast3D
@export_range(0.0, 100.0, 1.0, "or_greater") var point_radius : float = 10.0

var points_multimesh : MultiMeshInstance3D
var clear_line : MeshInstance3D
var block_line : MeshInstance3D
var shape_mesh : MeshInstance3D
var target_mesh : MeshInstance3D
var result_mesh : MeshInstance3D

func _init(__cast__: ShapeCast3D = null, __point_radius__: float = 10) -> void:
	cast = __cast__
	point_radius = __point_radius__

	points_multimesh = MultiMeshInstance3D.new()
	points_multimesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	points_multimesh.multimesh = MultiMesh.new()
	points_multimesh.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	points_multimesh.multimesh.mesh = DebugDraw3D.ARROW_MESH
	add_child.call_deferred(points_multimesh, false, INTERNAL_MODE_BACK)

	clear_line = MeshInstance3D.new()
	clear_line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	clear_line.mesh = ImmediateMesh.new()
	clear_line.set_instance_shader_parameter(&"color", Color.GREEN)
	add_child.call_deferred(clear_line, false, INTERNAL_MODE_BACK)

	block_line = MeshInstance3D.new()
	block_line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	block_line.mesh = ImmediateMesh.new()
	block_line.set_instance_shader_parameter(&"color", Color.RED)
	add_child.call_deferred(block_line, false, INTERNAL_MODE_BACK)

	shape_mesh = MeshInstance3D.new()
	shape_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	shape_mesh.set_instance_shader_parameter(&"color", Color(0, 1, 0, 0.05))
	shape_mesh.material_override = MESH_MATERIAL
	add_child.call_deferred(shape_mesh, false, INTERNAL_MODE_BACK)

	super._init(true)


func _ready() -> void:
	super._ready()

	if cast == null:
		cast = get_parent()
	shape_mesh.mesh = cast.shape.get_debug_mesh()

func _process(delta: float) -> void:
	points_multimesh.multimesh.instance_count = cast.get_collision_count()
	for i in points_multimesh.multimesh.instance_count:
		var point_position := cast.get_collision_point(i)
		var point_normal := cast.get_collision_normal(i)
		var point_scale := point_radius
		points_multimesh.multimesh.set_instance_transform(i, Transform3D(
				Basis.looking_at(point_normal,
					Vector3.FORWARD if abs(point_normal.y) == 1.0 else Vector3.UP
				) * Basis(Vector3.RIGHT, deg_to_rad(-90)) \
				.scaled_local(Vector3.ONE * point_scale),
				point_position + point_normal * point_scale
			)
		)

	var is_colliding := points_multimesh.multimesh.instance_count > 0
	points_multimesh.set_instance_shader_parameter(&"color", Color.RED if is_colliding else Color.GREEN)

	var midpoint := cast.global_position.lerp(cast.global_position + cast.target_position, cast.get_closest_collision_unsafe_fraction() if is_colliding else 1.0)

	shape_mesh.global_position = midpoint
	shape_mesh.set_instance_shader_parameter(&"color", Color(1, 0, 0, 0.25) if is_colliding else Color(0, 1, 0, 0.05))

	_refresh(is_colliding, midpoint, cast.global_position, cast.target_position)

func _refresh(is_colliding: bool, collision_point: Vector3, global_origin: Vector3, target_position: Vector3) -> void:
	var length := target_position.length()
	var normal := target_position.normalized()
	var clear_distance := collision_point.distance_to(global_origin) if is_colliding else length

	clear_line.mesh.clear_surfaces()
	if clear_distance > 0.0:
		clear_line.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, DebugDraw3D.MESH_MATERIAL)
		clear_line.mesh.surface_add_vertex(global_origin + Vector3.ZERO)
		clear_line.mesh.surface_add_vertex(global_origin + normal * clear_distance)
		clear_line.mesh.surface_end()

	block_line.mesh.clear_surfaces()
	if clear_distance < length:
		block_line.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, DebugDraw3D.MESH_MATERIAL)
		block_line.mesh.surface_add_vertex(global_origin + normal * clear_distance)
		block_line.mesh.surface_add_vertex(global_origin + target_position)
		block_line.mesh.surface_end()

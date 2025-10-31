
class_name DebugDraw3D_RayCast extends DebugDraw3D

var cast : RayCast3D
var point_radius : float

var point_node : Node3D
var point_mesh : MeshInstance3D
var clear_line : MeshInstance3D
var block_line : MeshInstance3D

func _init(__raycast__: RayCast3D, __point_radius__: float = 10) -> void:
	cast = __raycast__

	point_node = Node3D.new()
	add_child(point_node)

	point_mesh = MeshInstance3D.new()
	point_mesh.rotation_degrees.x = -90.0
	point_mesh.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	point_mesh.mesh = DebugDraw3D.ARROW_MESH
	point_node.add_child(point_mesh)

	clear_line = MeshInstance3D.new()
	clear_line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	clear_line.mesh = ImmediateMesh.new()
	clear_line.material_override = DebugDraw3D.MESH_MATERIAL.duplicate()
	clear_line.material_override.albedo_color = Color.GREEN
	add_child(clear_line)

	block_line = MeshInstance3D.new()
	block_line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	block_line.mesh = ImmediateMesh.new()
	block_line.material_override = DebugDraw3D.MESH_MATERIAL.duplicate()
	block_line.material_override.albedo_color = Color.RED
	add_child(block_line)

	super._init(true)

	point_mesh.material_override = material

	point_radius = __point_radius__

func _process(delta: float) -> void:
	var point_scale := DebugDraw3D.get_fixed_scale(get_viewport().get_camera_3d(), point_node.global_position, point_radius)
	point_mesh.position.z = -point_scale
	point_mesh.scale = Vector3.ONE * point_scale

	_refresh(cast.is_colliding(), cast.get_collision_point(), cast.get_collision_normal(), cast.global_position, cast.target_position)

func _refresh(is_colliding: bool, collision_point: Vector3, collision_normal: Vector3, global_origin: Vector3, target_position: Vector3) -> void:
	material.albedo_color = block_line.material_override.albedo_color if is_colliding else clear_line.material_override.albedo_color
	point_node.position = collision_point if is_colliding else (global_origin + target_position)
	var look_direction := collision_normal if is_colliding else target_position.normalized()
	point_node.look_at(
		point_node.global_position + look_direction,
		Vector3.FORWARD if abs(look_direction.y) == 1.0 else Vector3.UP
	)

	var length := target_position.length()
	var normal := target_position.normalized()
	var clear_distance := collision_point.distance_to(global_origin) if is_colliding else length

	clear_line.mesh.clear_surfaces()
	if clear_distance > 0.0:
		clear_line.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
		clear_line.mesh.surface_add_vertex(global_origin + Vector3.ZERO)
		clear_line.mesh.surface_add_vertex(global_origin + normal * clear_distance)
		clear_line.mesh.surface_end()

	block_line.mesh.clear_surfaces()
	if clear_distance < length:
		block_line.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
		block_line.mesh.surface_add_vertex(global_origin + normal * clear_distance)
		block_line.mesh.surface_add_vertex(global_origin + target_position)
		block_line.mesh.surface_end()

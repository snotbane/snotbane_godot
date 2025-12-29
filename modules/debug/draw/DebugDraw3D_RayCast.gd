
@tool class_name DebugDraw3D_RayCast extends _DebugDraw3D_Mesh

var cast : RayCast3D

var _point_radius : float
@export var point_radius : float = 0.25 :
	get: return _point_radius
	set(value):
		_point_radius = value


var clear_line : MeshInstance3D
var block_line : MeshInstance3D

func _init(__raycast__: RayCast3D = null, __point_radius__: float = 0.25) -> void:
	cast = __raycast__

	clear_line = MeshInstance3D.new()
	clear_line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	clear_line.mesh = ImmediateMesh.new()
	clear_line.material_override = DebugDraw3D.MESH_MATERIAL
	clear_line.set_instance_shader_parameter(&"color", Color.GREEN)
	add_child.call_deferred(clear_line, false, INTERNAL_MODE_BACK)

	block_line = MeshInstance3D.new()
	block_line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	block_line.mesh = ImmediateMesh.new()
	block_line.material_override = DebugDraw3D.MESH_MATERIAL
	block_line.set_instance_shader_parameter(&"color", Color.RED)
	add_child.call_deferred(block_line, false, INTERNAL_MODE_BACK)

	super._init(ARROW_MESH)

	point_radius = __point_radius__

func _ready() -> void:
	super._ready()

	if cast == null:
		cast = get_parent()

func _process(delta: float) -> void:
	if Engine.is_editor_hint():
		_refresh(false, cast.to_global(cast.target_position), Vector3.ZERO, cast.global_position, cast.target_position)
	else:
		_refresh(cast.is_colliding(), cast.get_collision_point(), cast.get_collision_normal(), cast.global_position, cast.target_position)

func _refresh(is_colliding: bool, collision_point: Vector3, collision_normal: Vector3, global_origin: Vector3, target_position: Vector3) -> void:
	var point_scale := point_radius
	mesh_inst.set_instance_shader_parameter(&"color", Color.RED if is_colliding else Color.GREEN)

	if not is_colliding:
		collision_point = cast.to_global(target_position)

	var target_length := target_position.length()
	var target_normal := target_position.normalized()
	var clear_distance := collision_point.distance_to(global_origin) if is_colliding else target_length

	var look_direction := collision_normal if is_colliding else target_normal
	mesh_inst.basis = (Basis.looking_at(
		look_direction,
		Vector3.FORWARD if abs(look_direction.y) == 1.0 else Vector3.UP
	) * Basis(Vector3.RIGHT, deg_to_rad(-90))) \
		.scaled_local(Vector3.ONE * point_scale)
	mesh_inst.position = collision_point - target_normal * point_scale

	clear_line.mesh.clear_surfaces()
	if clear_distance > 0.0:
		clear_line.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, DebugDraw3D.MESH_MATERIAL)
		clear_line.mesh.surface_add_vertex(global_origin + Vector3.ZERO)
		clear_line.mesh.surface_add_vertex(global_origin + target_normal * clear_distance)
		clear_line.mesh.surface_end()

	block_line.mesh.clear_surfaces()
	if clear_distance < target_length:
		block_line.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, DebugDraw3D.MESH_MATERIAL)
		block_line.mesh.surface_add_vertex(global_origin + target_normal * clear_distance)
		block_line.mesh.surface_add_vertex(global_origin + target_position)
		block_line.mesh.surface_end()

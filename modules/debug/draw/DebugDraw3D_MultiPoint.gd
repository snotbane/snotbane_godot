
class_name DebugDraw3D_MultiPoint extends _DebugDraw3D_MultiMesh

var _points_radius : float = 0.05
## The radius size of each point in the array.
@export_range(0.0, 1.0, 0.01, "or_greater") var points_radius : float = 0.05 :
	get: return _points_radius
	set(value):
		value = maxf(value, 0.0)
		if _points_radius == value: return
		_points_radius = value

		_refresh()

var _points : PackedVector3Array
var points : PackedVector3Array :
	get: return _points
	set(value):
		_points = value

		_refresh()

var visible_points : bool :
	get: return multimesh_inst.visible
	set(value): multimesh_inst.visible = false

var visible_line : bool :
	get: return line.visible
	set(value): line.visible = value


var line : MeshInstance3D


func _refresh() -> void:
	_refresh_points()
	_refresh_line()
func _refresh_points() -> void:
	multimesh_inst.multimesh.instance_count = _points.size() if _points_radius > 0.0 else 0
	for i in multimesh_inst.multimesh.instance_count:
		multimesh_inst.multimesh.set_instance_transform(i, Transform3D(Basis.from_scale(Vector3.ONE * points_radius), _points[i]))
func _refresh_line() -> void:
	line.mesh.clear_surfaces()
	if  points.size() == 0: return
	line.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP)
	for i in points.size():
		line.mesh.surface_add_vertex(points[i])
	line.mesh.surface_end()


func _init(__top_level__: bool = true, __points__: PackedVector3Array = [], __points_radius__: float = 0.125) -> void:
	super._init(__top_level__, POINT_MESH)

	line = MeshInstance3D.new()
	line.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	line.mesh = ImmediateMesh.new()
	line.material_override = material
	add_child(line)

	_points_radius = __points_radius__
	_points = __points__

	_refresh()


@tool class_name Draw3D_MultiMesh extends Draw3D

var multimesh_inst : MultiMeshInstance3D

var _color := Color.WHITE_SMOKE
@export var color := Color.WHITE_SMOKE :
	get: return _color
	set(value):
		_color = value
		_refresh()

var _mesh : Mesh
@export var mesh : Mesh :
	get: return _mesh
	set(value):
		_mesh = value
		multimesh_inst.multimesh.mesh = _mesh

var _points : PackedVector3Array
@export var points : PackedVector3Array :
	get: return _points
	set(value):
		_points = value
		_refresh()

func _init() -> void:
	super._init()

	multimesh_inst = MultiMeshInstance3D.new()
	multimesh_inst.multimesh = MultiMesh.new()
	multimesh_inst.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh_inst.material_override = DEFAULT_MATERIAL
	multimesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	add_child(multimesh_inst, false, INTERNAL_MODE_BACK)

	mesh = mesh

func _refresh() -> void:
	multimesh_inst.set_instance_shader_parameter(&"color", _color)
	multimesh_inst.multimesh.instance_count = _points.size()
	for i in multimesh_inst.multimesh.instance_count:
		multimesh_inst.multimesh.set_instance_transform(i, Transform3D(
			Basis.IDENTITY,
			_points[i]
		))

@tool class_name Draw3D_Line extends Draw3D_Mesh

var _size : float = 0.0
@export_range(0.0, 1.0, 0.01, "or_greater") var size : float = 0.0 :
	get: return _size
	set(value):
		_size = value
		multimesh_inst.size = _size

var _points : PackedVector3Array
@export var points : PackedVector3Array :
	get: return _points
	set(value):
		_points = value
		multimesh_inst.points = _points
		_refresh()

var multimesh_inst : Draw3D_MultiPoint

func _init() -> void:
	super._init(ImmediateMesh.new())

	multimesh_inst = Draw3D_MultiPoint.new()
	add_child(multimesh_inst)

	size = size

func _ready() -> void:
	points = points

func _refresh() -> void:
	super._refresh()
	multimesh_inst.color = color
	mesh_inst.mesh.clear_surfaces()
	if _points.size() <= 1: return
	mesh_inst.mesh.surface_begin(Mesh.PRIMITIVE_LINE_STRIP, Draw3D.DEFAULT_MATERIAL)
	for i in _points.size():
		mesh_inst.mesh.surface_add_vertex(_points[i])
	mesh_inst.mesh.surface_end()
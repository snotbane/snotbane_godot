
@tool class_name Draw3D_Mesh extends Draw3D

var mesh_inst : MeshInstance3D

var _color := Color.WHITE_SMOKE
@export var color := Color.WHITE_SMOKE :
	get: return _color
	set(value):
		_color = value
		_refresh()

var _mesh : Mesh = null
@export var mesh : Mesh = null :
	get: return _mesh
	set(value):
		_mesh = value
		mesh_inst.mesh = _mesh

func _init(__mesh__: Mesh = mesh) -> void:
	super._init()

	mesh_inst = MeshInstance3D.new()
	mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_inst.material_override = DEFAULT_MATERIAL
	add_child(mesh_inst, false, INTERNAL_MODE_BACK)

	color = color
	mesh = __mesh__

func _ready() -> void:
	super._ready()

	_refresh()

func _refresh() -> void:
	mesh_inst.set_instance_shader_parameter(&"color", _color)

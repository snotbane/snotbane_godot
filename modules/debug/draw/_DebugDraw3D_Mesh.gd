
@tool class_name _DebugDraw3D_Mesh extends DebugDraw3D

var mesh_inst : MeshInstance3D

var _color := Color.WHITE_SMOKE
@export var color := Color.WHITE_SMOKE :
	get: return _color
	set(value):
		_color = value
		mesh_inst.set_instance_shader_parameter(&"color", value)
		_on_color_set()
func _on_color_set() -> void: pass

func _init(__mesh__: Mesh) -> void:
	super._init()

	mesh_inst = MeshInstance3D.new()
	mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_inst.mesh = __mesh__
	add_child.call_deferred(mesh_inst, false, INTERNAL_MODE_BACK)

	color = color

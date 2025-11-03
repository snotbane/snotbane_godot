
@tool class_name _DebugDraw3D_Mesh extends DebugDraw3D

var mesh_inst : MeshInstance3D

func _init(__top_level__: bool, __mesh__: Mesh) -> void:
	super._init(__top_level__)

	mesh_inst = MeshInstance3D.new()
	mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_inst.mesh = __mesh__
	add_child.call_deferred(mesh_inst, false, INTERNAL_MODE_BACK)

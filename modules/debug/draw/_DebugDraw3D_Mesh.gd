
class_name _DebugDraw3D_Mesh extends DebugDraw3D

var mesh_inst : MeshInstance3D

func _init(__top_level__: bool, __mesh__: Mesh) -> void:
	super._init(__top_level__)

	mesh_inst = MeshInstance3D.new()
	mesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	mesh_inst.material_override = material
	mesh_inst.mesh = __mesh__


func _ready() -> void:
	super._ready()

	add_child(mesh_inst)

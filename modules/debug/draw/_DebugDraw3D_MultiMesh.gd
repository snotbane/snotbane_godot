
class_name _DebugDraw3D_MultiMesh extends DebugDraw3D

var multimesh_inst : MultiMeshInstance3D

func _init(__top_level__: bool, __mesh__: Mesh) -> void:
	super._init(__top_level__)

	multimesh_inst = MultiMeshInstance3D.new()
	multimesh_inst.multimesh = MultiMesh.new()
	multimesh_inst.multimesh.transform_format = MultiMesh.TRANSFORM_3D
	multimesh_inst.multimesh.mesh = __mesh__
	multimesh_inst.cast_shadow = GeometryInstance3D.SHADOW_CASTING_SETTING_OFF
	multimesh_inst.material_override = material


func _ready() -> void:
	super._ready()

	add_child(multimesh_inst)

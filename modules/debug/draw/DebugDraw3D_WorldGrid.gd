
@tool class_name DebugDraw3D_WorldGrid extends _DebugDraw3D_Mesh

const WORLD_MESH := preload("uid://pqjfvxv40wmq")

func _init() -> void:
	super._init(true, WORLD_MESH)

	mesh_inst.material_override = null


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint(): return
	if event.is_action_pressed(Snotbane.INPUT_DEBUG_GRID_TOGGLE):
		visible = not visible

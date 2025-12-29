
@tool class_name DebugDraw3D_ShapeCastQuery extends DebugDraw3D

# var clear_line : MeshInstance3D
# var block_line

func update(query: PhysicsShapeQueryParameters3D, response: Dictionary) -> void:
	if not visible: return

	# shape_mesh.mesh = query.shape

	pass

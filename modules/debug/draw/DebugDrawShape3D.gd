extends Node3D

@onready var parent := get_parent()

func _physics_process(delta: float) -> void:
	DebugDraw3D.shape(name, parent.global_transform, parent.shape)


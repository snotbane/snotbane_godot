class_name BrainTarget extends Timer

signal updated

var host : Node

var _target_pos : Variant
var _target_node : Node
## The position or Node which the Brain will try to reach.
var target : Variant :
	get: return _target_node
	set(value):
		assert(value == null or value is Node2D or value is Node3D or value is Vector2 or value is Vector3, "Assigned target must be a Node2D or Node3D, or a Vector2 or Vector3s.")
		if _target_node == value: return
		var value_is_node : bool = value is Node3D or value is Node2D

		if _target_node is Node3D or _target_node is Node2D:
			_target_node.tree_exiting.disconnect(recall)

		_target_node = value if value_is_node else null
		_target_pos = Vector3.ZERO if _target_node is Node3D else Vector2.ZERO

		if _target_node is Node3D or _target_node is Node2D:
			_target_node.tree_exiting.connect(recall)

		var new_parent : Node = (_target_node if _target_node is Node2D or _target_node is Node3D else host)
		if get_parent() != new_parent:
			reparent(new_parent, false)

## The global position of the target.
var target_position : Variant :
	get:
		assert(is_assigned, "BrainTarget must be assigned in order to get the target position.")
		var parent := get_parent()
		if parent is Node2D or parent is Node3D:
			return parent.to_global(_target_pos)
		else:
			return _target_pos

## Returns true if the target is currently assigned.
var is_assigned : bool :
	get: return target != null


func _init(__wait_time__: float) -> void:
	process_callback = Timer.TIMER_PROCESS_PHYSICS
	wait_time = __wait_time__
	autostart = true
	timeout.connect(try_update)

func _enter_tree() -> void:
	var parent := get_parent()
	if parent is NavigationAgent3D or parent is NavigationAgent2D:
		host = parent

func try_update() -> void:
	if not is_assigned: return
	updated.emit()

func recall() -> void:
	target = null

func assign(__target__: Variant, relative: Variant = null) -> void:
	target = __target__

	if relative != null:
		_target_pos = relative

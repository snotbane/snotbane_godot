
class_name InputNode extends Node

static func is_input_restricted(node: Node) -> bool:
	var focus := node.get_viewport().gui_get_focus_owner()
	return focus != null


func _unhandled_input(event: InputEvent) -> void:
	if InputNode.is_input_restricted(self):	_blocked_input()
	else:									_restricted_input(event)
func _restricted_input(event: InputEvent) -> void: pass
func _blocked_input() -> void: pass

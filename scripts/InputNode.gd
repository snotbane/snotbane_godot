class_name InputNode extends Node

@export var _enabled : bool = true
var enabled : bool :
	get:
		if get_parent() is InputNode:
			return _enabled and get_parent().enabled
		return _enabled

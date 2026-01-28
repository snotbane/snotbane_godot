
class_name DebugGhostAutoload extends Node

## Use this to control if the default input can be used in non-debug builds.
const ALLOW_INPUT_IN_RELEASE_BUILD : bool = false

static var GHOST_2D_SCENE : PackedScene = preload("uid://cv3vrsaxhhhkb")
static var GHOST_3D_SCENE : PackedScene = preload("uid://cwcqawp5x05vt")

static var inst : DebugGhostAutoload


var ghost : Node


func _init():
	inst = self


func _input(event: InputEvent):
	if not (OS.is_debug_build() or ALLOW_INPUT_IN_RELEASE_BUILD) or ghost != null: return
	if event.is_action_pressed(Snotbane.INPUT_GHOST_TOGGLE):
		create_ghost()
		get_viewport().set_input_as_handled()


func create_ghost(parent: Node = get_tree().root) -> void:
	if ghost: printerr("Ghost %s already exists. Can't spawn a new one." % ghost); return
	if self.get_tree().current_scene is Node2D:
		ghost = GHOST_2D_SCENE.instantiate()
		self.get_tree().root.add_child(ghost)
	elif self.get_tree().current_scene is Node3D:
		ghost = DebugGhost3D.instantiate_from_camera(parent)
	ghost.tree_exited.connect(clear_ghost)


func clear_ghost() -> void:
	if ghost:
		ghost.queue_free()
	ghost = null

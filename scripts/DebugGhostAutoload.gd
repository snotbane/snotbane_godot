extends Node
class_name DebugGhostAutoload

static var GHOST_2D_SCENE : PackedScene = preload("uid://cv3vrsaxhhhkb")
static var GHOST_3D_SCENE : PackedScene = preload("uid://cwcqawp5x05vt")

static var inst : DebugGhostAutoload

static var debug_ghost_exists : bool :
	get: return inst.get_tree().get_node_count_in_group(Mincuz.GHOST_GROUP) > 0


var ghost : Node
var previous_camera : Node


func _ready():
	inst = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent):
	if event.is_action_pressed(Mincuz.INPUT_GHOST_TOGGLE):
		toggle_ghost()


func create_ghost_2d() -> void:
	if ghost: printerr("Ghost %s already exists. Can't spawn a new one." % ghost); return
	ghost = GHOST_2D_SCENE.instantiate()
	self.get_tree().root.add_child(ghost)


func create_ghost_3d() -> void:
	if ghost: printerr("Ghost %s already exists. Can't spawn a new one." % ghost); return
	ghost = GHOST_3D_SCENE.instantiate()
	self.get_tree().root.add_child(ghost)


func toggle_ghost() -> void:
	if ghost:
		ghost.queue_free()
		ghost = null
		return

	if self.get_tree().current_scene is Node2D:
		create_ghost_2d()
		ghost.populate_from_camera(self.get_viewport().get_camera_2d())
	elif self.get_tree().current_scene is Node3D:
		create_ghost_3d()
		ghost.populate_from_camera(self.get_viewport().get_camera_3d())
	else:
		return

class_name DebugGhostAutoload extends Node

static var GHOST_2D_SCENE_PATH := "res://addons/tools_mincuz/scenes/debug_ghost_2d.tscn"
static var GHOST_2D_SCENE : PackedScene :
	get: return load(GHOST_2D_SCENE_PATH)

static var GHOST_3D_SCENE_PATH := "res://addons/tools_mincuz/scenes/debug_ghost_3d.tscn"
static var GHOST_3D_SCENE : PackedScene :
	get: return load(GHOST_3D_SCENE_PATH)

static var inst : DebugGhostAutoload

static var debug_ghost_exists : bool :
	get: return inst.get_tree().get_node_count_in_group(&"debug_ghost") > 0


var ghost : Node
var previous_camera : Node


func _ready():
	inst = self
	Input.mouse_mode = Input.MOUSE_MODE_CAPTURED


func _input(event: InputEvent):
	if event.is_action_pressed(&"ghost_toggle"):
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


## Moves a node (i.e. the player) to match the editor's view on game start. Only works once and in an editor build. Also passes some controls along to debug ghost cameras.
@tool extends Node3D


static var can_be_activated : bool :
	get: return OS.has_feature("editor") and Time.get_ticks_msec() < 1000


## If enabled, this node will always activate. Otherwise, only activate when visible.
@export var activate_if_invisible : bool = false

## If enabled, this node will spawn a [DebugGhost3D] node on startup.
@export var start_in_debug_ghost_mode : bool = false

## If enabled, [member position_node] will be moved to this node on [method _ready] (i.e. the editor viewport center).
@export var move_pawn_node : bool = true

## If set, this node will move to the editor view transform on [methos _ready]. Set this to your player's base node.
@export var position_node : Node3D

## If set, this node will match the editor's view pitch.
@export var rotation_node_x : Node3D

## If set, this node will match the editor's view yaw. It is very common to set this to the same node as position_node.
@export var rotation_node_y : Node3D


var visible_or_always : bool :
	get: return self.visible or activate_if_invisible


func _ready() -> void:
	if not can_be_activated: return

	if move_pawn_node and visible_or_always:
		self.activate()

	if start_in_debug_ghost_mode and visible_or_always and DebugGhostAutoload.inst.ghost == null:
		create_ghost.call_deferred()


func _process(_delta: float) -> void:
	if not Engine.is_editor_hint(): return

	var editor_camera := EditorInterface.get_editor_viewport_3d().get_camera_3d()
	self.global_transform = editor_camera.global_transform


func activate(to: Node3D = self) -> void:
	if position_node: position_node.global_position = self.global_position
	if rotation_node_x: rotation_node_x.global_rotation.x = self.global_rotation.x
	if rotation_node_y: rotation_node_y.global_rotation.y = self.global_rotation.y


func create_ghost() -> void:
	DebugGhostAutoload.inst.create_ghost_3d()
	DebugGhostAutoload.inst.ghost.populate_from_camera(self.get_viewport().get_camera_3d())

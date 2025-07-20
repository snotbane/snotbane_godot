
## Moves a node (i.e. the player) to match the editor's view on game start. Only works once and in an editor build. Also passes some controls along to debug ghost cameras.
@tool extends Node2D


static var can_be_activated : bool :
	get: return OS.has_feature("editor") and Time.get_ticks_msec() < 1000


## If enabled, this node will always activate. Otherwise, only activate when visible.
@export var activate_if_invisible : bool = false

## If enabled, this node will spawn a [DebugGhost2D] node on startup.
@export var start_in_debug_ghost_mode : bool = false

## If enabled, [member position_node] will be moved to this node on [method _ready] (i.e. the editor viewport center).
@export var move_pawn_node : bool = true

## If set, this node will move to the editor view transform on [methos _ready]. Set this to your player's base node.
@export var position_node : Node2D

## If set, this node will match the editor's view rotation.
@export var rotation_node : Node2D


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

	self.global_transform = EditorInterface.get_editor_viewport_2d().global_canvas_transform
	self.global_position = (-self.global_transform.origin / self.global_transform.get_scale()) + Vector2(EditorInterface.get_editor_viewport_2d().size) / (self.global_transform.get_scale() * 2.0)


func activate(to: Node2D = self) -> void:
	if position_node: position_node.global_position = to.global_position
	if rotation_node: rotation_node.global_rotation = to.global_rotation


func create_ghost() -> void:
	DebugGhostAutoload.inst.create_ghost_2d()
	DebugGhostAutoload.inst.ghost.populate_from_transform(self.global_transform)

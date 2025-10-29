## Allows the user to freely move around 2D scenes for debugging purposes.
extends Node2D

## If enabled, the [member Input.mouse_mode] will be set to [member Input.MOUSE_MODE_VISIBLE] when this node is created (and reverted on deletion).
@export var unlock_mouse_mode : bool = false

## Movement speed via keyboard/gamepad.
@export var speed : float = 500.0
## Movement speed via mouse.
@export var speed_mouse : float = 50.0
## Speed multiplier while sprinting.
@export var sprint_multiplier : float = 5.0

## Turn speed (degrees per second). Has no effect if [member turn_interval_degrees] is greater than 0.0
@export var turn_speed_degrees : float = 90.0
## If greater than 0.0, rotation will be locked to a turn this many degrees on each distinct input (rather than continuously rotating)
@export_range(0.0, 90.0, 5.0, "or_greater") var turn_interval_degrees : float = 0.0


var revert_mouse_mode : Input.MouseMode
var move_input_vector_mouse : Vector2
var pawn : Node2D


var use_turn_interval : bool :
	get: return not is_zero_approx(turn_interval_degrees)

var is_sprinting : bool :
	get: return Input.is_action_pressed(Snotbane.INPUT_GHOST_SPRINT)


func populate(__pawn: Node2D) -> void:
	pawn = __pawn


func populate_from_camera(camera: Camera2D) -> void:
	change_mouse_mode()
	self.global_transform = camera.global_transform
	var node : Camera2D = camera.duplicate(0)
	node.transform = Transform2D.IDENTITY
	self.add_child(node)
	node.make_current()


func populate_from_transform(__transform__: Transform2D) -> void:
	change_mouse_mode()
	self.global_transform = __transform__
	var node := Camera2D.new()
	self.add_child(node)
	node.make_current()


func change_mouse_mode() -> void:
	revert_mouse_mode = Input.mouse_mode
	if unlock_mouse_mode:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _exit_tree() -> void:
	if unlock_mouse_mode and revert_mouse_mode != -1:
		Input.mouse_mode = revert_mouse_mode


func _process(delta: float) -> void:
	if not use_turn_interval:
		var turn_axis := Input.get_axis(Snotbane.INPUT_GHOST_MOVE_UP, Snotbane.INPUT_GHOST_MOVE_DOWN)
		self.global_rotation_degrees += turn_axis * turn_speed_degrees * delta

	var move_vector := Vector2.ZERO
	move_vector += (Input.get_vector(Snotbane.INPUT_GHOST_MOVE_LEFT, Snotbane.INPUT_GHOST_MOVE_RIGHT, Snotbane.INPUT_GHOST_MOVE_FORWARD, Snotbane.INPUT_GHOST_MOVE_BACK) + Input.get_vector(Snotbane.INPUT_GHOST_CAMERA_LEFT, Snotbane.INPUT_GHOST_CAMERA_RIGHT, Snotbane.INPUT_GHOST_CAMERA_UP, Snotbane.INPUT_GHOST_CAMERA_DOWN)) * speed

	if Input.mouse_mode == Input.MOUSE_MODE_CAPTURED:
		move_vector += move_input_vector_mouse * speed_mouse
	move_input_vector_mouse = Vector2.ZERO

	self.global_position += move_vector.rotated(self.global_rotation) * (sprint_multiplier if is_sprinting else 1.0) * delta



func _input(event: InputEvent) -> void:
	if use_turn_interval:
		if event.is_action_pressed(Snotbane.INPUT_GHOST_MOVE_UP):
			self.global_rotation_degrees += turn_interval_degrees
		elif event.is_action_pressed(Snotbane.INPUT_GHOST_MOVE_DOWN):
			self.global_rotation_degrees -= turn_interval_degrees
	if event is InputEventMouseMotion:
		move_input_vector_mouse += event.relative

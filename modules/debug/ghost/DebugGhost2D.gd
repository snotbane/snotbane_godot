## Allows the user to freely move around 2D scenes for debugging purposes.
class_name DebugGhost2D extends Node2D

static var inst : DebugGhost2D


static func instantiate_from_camera(parent: Node, camera: Camera2D = parent.get_viewport().get_camera_2d()) -> DebugGhost2D:
	var result : DebugGhost2D = DebugGhostAutoload.GHOST_2D_SCENE.instantiate()
	parent.add_child(result)

	result.global_transform = camera.global_transform
	var new_camera : Camera2D = camera.duplicate(0)
	new_camera.transform = Transform2D.IDENTITY
	result.add_child(new_camera)
	new_camera.make_current()

	return result


static func instantiate_from_transform(parent: Node, tform: Transform2D) -> DebugGhost2D:
	var result : DebugGhost2D = DebugGhostAutoload.GHOST_2D_SCENE.instantiate()
	parent.add_child(result)

	result.global_transform = tform
	var node := Camera2D.new()
	result.add_child(node)
	node.make_current()

	return result


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


var move_input_vector_mouse : Vector2


var use_turn_interval : bool :
	get: return not is_zero_approx(turn_interval_degrees)

var is_sprinting : bool :
	get: return Input.is_action_pressed(Snotbane.INPUT_GHOST_SPRINT)


func _init() -> void:
	if inst: inst.queue_free()

	inst = self


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		move_input_vector_mouse += event.screen_relative
	elif event.is_action_pressed(Snotbane.INPUT_GHOST_TOGGLE):
		queue_free()

	if use_turn_interval:
		if event.is_action_pressed(Snotbane.INPUT_GHOST_MOVE_UP):
			self.global_rotation_degrees += turn_interval_degrees
		elif event.is_action_pressed(Snotbane.INPUT_GHOST_MOVE_DOWN):
			self.global_rotation_degrees -= turn_interval_degrees

	get_viewport().set_input_as_handled()


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

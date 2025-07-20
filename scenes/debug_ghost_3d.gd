
## Allows the user to freely move around 3D scenes for debugging purposes.
extends Node3D


## If enabled, the [member Input.mouse_mode] will be set to [member Input.MOUSE_MODE_VISIBLE] when this node is created (and reverted on deletion).
@export var unlock_mouse_mode : bool = false

## Movement speed.
@export var speed : float = 1.0
## Speed multiplier while sprinting.
@export var sprint_multiplier : float = 5.0

## If enabled, camera will always move up along the global gravity up vector and laterally relative to that (Minecraft creative flight controls).
@export var global_move_axis := true

## If enabled, the camera will always stay right side up. Otherwise, the camera may be turned upside down.
@export var turn_clamp_pitch : bool = true
## Turn speed (degrees per second) via keyboard/gamepad.
@export var turn_speed : float = 90.0
## Turn speed via mouse.
@export var turn_speed_mouse : float = 10.0


var revert_mouse_mode : Input.MouseMode
var turn_input_vector_mouse : Vector2


var is_sprinting : bool :
	get: return Input.is_action_pressed(&"ghost_sprint")


func populate_from_camera(camera: Camera3D) -> void:
	change_mouse_mode()
	self.global_transform = camera.global_transform
	var node := camera.duplicate(0)
	node.transform = Transform3D.IDENTITY
	self.add_child(node)
	node.make_current()


func change_mouse_mode() -> void:
	revert_mouse_mode = Input.mouse_mode
	if unlock_mouse_mode:
		Input.mouse_mode = Input.MOUSE_MODE_VISIBLE


func _exit_tree() -> void:
	if unlock_mouse_mode:
		Input.mouse_mode = revert_mouse_mode


func _process(delta: float) -> void:
	var gravity_up : Vector3 = -ProjectSettings.get_setting("physics/3d/default_gravity_vector")
	var is_upsidedown := not turn_clamp_pitch and self.global_basis.y.dot(gravity_up) < 0.0

	#region Rotation

	var turn_rotation_degrees := Vector3.ZERO

	var turn_input_vector := Input.get_vector(&"ghost_camera_left", &"ghost_camera_right", &"ghost_camera_down", &"ghost_camera_up")
	var turn_vector := Vector3(turn_input_vector.y, -turn_input_vector.x, 0.0)
	turn_rotation_degrees += turn_vector * turn_speed


	var turn_vector_mouse := Vector3(-turn_input_vector_mouse.y, -turn_input_vector_mouse.x, 0.0)
	turn_rotation_degrees += turn_vector_mouse * turn_speed_mouse

	if is_upsidedown:
		turn_rotation_degrees *= -1.0

	turn_rotation_degrees *= delta
	turn_rotation_degrees += self.global_rotation_degrees

	if turn_clamp_pitch:
		turn_rotation_degrees.x = clamp(turn_rotation_degrees.x, -90.0, +90.0)

	self.global_rotation_degrees = turn_rotation_degrees

	turn_input_vector_mouse = Vector2.ZERO

	#endregion
	#region Movement

	var move_vector := Vector3(Input.get_axis(&"ghost_move_left", &"ghost_move_right"), Input.get_axis(&"ghost_move_down", &"ghost_move_up"), Input.get_axis(&"ghost_move_forward", &"ghost_move_back"))

	var move_quat : Quaternion
	if global_move_axis:
		var forward := gravity_up.cross(self.global_basis.x)
		move_quat = Basis(-gravity_up.cross(forward), gravity_up, -forward).get_rotation_quaternion()
		if is_upsidedown:
			move_vector *= Vector3(1, -1, -1)
	else:
		move_quat = self.global_basis.get_rotation_quaternion()


	self.global_position += move_quat * move_vector * speed * (sprint_multiplier if is_sprinting else 1.0) * delta

	#endregion

func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		turn_input_vector_mouse += event.relative

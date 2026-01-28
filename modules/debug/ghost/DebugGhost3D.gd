## Allows the user to freely move around 3D scenes for debugging purposes.
class_name DebugGhost3D extends Node3D

static var inst : DebugGhost3D


static func instantiate_from_camera(parent: Node, camera: Camera3D = parent.get_viewport().get_camera_3d()) -> DebugGhost3D:
	var result : DebugGhost3D = DebugGhostAutoload.GHOST_3D_SCENE.instantiate()
	parent.add_child(result)

	result.global_transform = camera.global_transform
	var new_camera := camera.duplicate(0)
	new_camera.transform = Transform3D.IDENTITY
	result.add_child(new_camera)
	new_camera.make_current()

	return result


## Movement speed.
@export var speed : float = 5.0
## Speed multiplier while sprinting.
@export var sprint_multiplier : float = 5.0

## If enabled, camera will always move up along the global gravity up vector and laterally relative to that (Minecraft creative controls).
@export var global_move_axis : bool = false

## If enabled, the camera will always stay right side up. Otherwise, the camera may be turned upside down.
@export var turn_clamp_pitch : bool = true
## Turn speed (degrees per second) via keyboard/gamepad.
@export var turn_speed : float = 90.0
## Turn speed via mouse.
@export var turn_speed_mouse : float = 10.0


var turn_input_vector_mouse : Vector2


var is_sprinting : bool :
	get: return Input.is_action_pressed(Snotbane.INPUT_GHOST_SPRINT)


func _init() -> void:
	if inst: inst.queue_free()

	inst = self


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		turn_input_vector_mouse += event.screen_relative
	elif event.is_action_pressed(Snotbane.INPUT_GHOST_TOGGLE):
		queue_free()

	get_viewport().set_input_as_handled()


func _process(delta: float) -> void:
	var gravity_up : Vector3 = -ProjectSettings.get_setting("physics/3d/default_gravity_vector")
	var is_upsidedown := not turn_clamp_pitch and self.global_basis.y.dot(gravity_up) < 0.0

	#region Rotation

	var turn_rotation_degrees := Vector3.ZERO

	var turn_input_vector := Input.get_vector(Snotbane.INPUT_GHOST_CAMERA_LEFT, Snotbane.INPUT_GHOST_CAMERA_RIGHT, Snotbane.INPUT_GHOST_CAMERA_DOWN, Snotbane.INPUT_GHOST_CAMERA_UP)
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

	var move_vector := Vector3(Input.get_axis(Snotbane.INPUT_GHOST_MOVE_LEFT, Snotbane.INPUT_GHOST_MOVE_RIGHT), Input.get_axis(Snotbane.INPUT_GHOST_MOVE_DOWN, Snotbane.INPUT_GHOST_MOVE_UP), Input.get_axis(Snotbane.INPUT_GHOST_MOVE_FORWARD, Snotbane.INPUT_GHOST_MOVE_BACK))

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

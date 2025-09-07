@tool
extends EditorPlugin

const DEBUG_GHOST_AUTOLOAD_NAME := "mincuz_debug_ghost"
const DEBUG_GHOST_AUTOLOAD_PATH := "scripts/DebugGhostAutoload.gd"

func _enable_plugin() -> void:
	self.add_autoload_singleton(DEBUG_GHOST_AUTOLOAD_NAME, DEBUG_GHOST_AUTOLOAD_PATH)

	configure_input()

func _disable_plugin() -> void:
	self.remove_autoload_singleton(DEBUG_GHOST_AUTOLOAD_NAME)

func configure_input() -> void:
	var quit_0 := InputEventKey.new()
	quit_0.physical_keycode = KEY_Q
	quit_0.ctrl_pressed = true
	Snotbane.add_default_input_binding(Snotbane.SETTING_INPUT_QUIT, [
		quit_0,
	])

	var fullscreen_0 := InputEventKey.new()
	fullscreen_0.physical_keycode = KEY_F11
	var fullscreen_1 := InputEventKey.new()
	fullscreen_1.physical_keycode = KEY_F
	fullscreen_1.ctrl_pressed = true
	fullscreen_1.command_or_control_autoremap = true
	Snotbane.add_default_input_binding(Snotbane.SETTING_INPUT_FULLSCREEN, [
		fullscreen_0,
		fullscreen_1,
	])


	var fullscreen_exclusive_0 := InputEventKey.new()
	fullscreen_exclusive_0.physical_keycode = KEY_F11
	fullscreen_exclusive_0.shift_pressed = true
	var fullscreen_exclusive_1 := InputEventKey.new()
	fullscreen_exclusive_1.physical_keycode = KEY_F
	fullscreen_exclusive_1.shift_pressed = true
	fullscreen_exclusive_1.ctrl_pressed = true
	fullscreen_exclusive_1.command_or_control_autoremap = true
	Snotbane.add_default_input_binding(Snotbane.SETTING_INPUT_FULLSCREEN_EXCLUSIVE, [
		fullscreen_exclusive_0,
		fullscreen_exclusive_1,
	])


	var ghost_toggle_0 := InputEventKey.new()
	ghost_toggle_0.physical_keycode = KEY_V
	Snotbane.add_default_input_binding(Snotbane.SETTING_INPUT_GHOST_TOGGLE, [
		ghost_toggle_0,
	])


	var ghost_teleport_0 := InputEventKey.new()
	ghost_teleport_0.physical_keycode = KEY_V
	ghost_teleport_0.shift_pressed = true
	var ghost_teleport_1 := InputEventKey.new()
	ghost_teleport_1.physical_keycode = KEY_ENTER
	Snotbane.add_default_input_binding(Snotbane.SETTING_INPUT_GHOST_TELEPORT, [
		ghost_teleport_0,
		ghost_teleport_1,
	])


	var ghost_sprint_0 := InputEventKey.new()
	ghost_sprint_0.physical_keycode = KEY_SHIFT
	var ghost_sprint_1 := InputEventJoypadButton.new()
	ghost_sprint_1.button_index = JOY_BUTTON_LEFT_STICK
	Snotbane.add_default_input_binding(Snotbane.SETTING_INPUT_GHOST_SPRINT, [
		ghost_sprint_0,
		ghost_sprint_1,
	])


	var ghost_move_left_0 := InputEventKey.new()
	ghost_move_left_0.physical_keycode = KEY_A
	var ghost_move_left_1 := InputEventJoypadMotion.new()
	ghost_move_left_1.axis = JOY_AXIS_LEFT_X
	ghost_move_left_1.axis_value = -1.0
	Snotbane.add_default_input_binding(Snotbane.SETTING_INPUT_GHOST_MOVE_LEFT, [
		ghost_move_left_0,
		ghost_move_left_1,
	])


	var ghost_move_right_0 := InputEventKey.new()
	ghost_move_right_0.physical_keycode = KEY_D
	var ghost_move_right_1 := InputEventJoypadMotion.new()
	ghost_move_right_1.axis = JOY_AXIS_LEFT_X
	ghost_move_right_1.axis_value = +1.0
	Snotbane.add_default_input_binding(Snotbane.SETTING_INPUT_GHOST_MOVE_RIGHT, [
		ghost_move_right_0,
		ghost_move_right_1,
	])


	var ghost_move_down_0 := InputEventKey.new()
	ghost_move_down_0.physical_keycode = KEY_Q
	Snotbane.add_default_input_binding(Snotbane.SETTING_INPUT_GHOST_MOVE_DOWN, [
		ghost_move_down_0,
	])


	var ghost_move_up_0 := InputEventKey.new()
	ghost_move_up_0.physical_keycode = KEY_E
	Snotbane.add_default_input_binding(Snotbane.SETTING_INPUT_GHOST_MOVE_UP, [
		ghost_move_up_0,
	])


	var ghost_move_back_0 := InputEventKey.new()
	ghost_move_back_0.physical_keycode = KEY_S
	var ghost_move_back_1 := InputEventJoypadMotion.new()
	ghost_move_back_1.axis = JOY_AXIS_LEFT_Y
	ghost_move_back_1.axis_value = -1.0
	Snotbane.add_default_input_binding(Snotbane.SETTING_INPUT_GHOST_MOVE_BACK, [
		ghost_move_back_0,
		ghost_move_back_1,
	])


	var ghost_move_forward_0 := InputEventKey.new()
	ghost_move_forward_0.physical_keycode = KEY_W
	var ghost_move_forward_1 := InputEventJoypadMotion.new()
	ghost_move_forward_1.axis = JOY_AXIS_LEFT_Y
	ghost_move_forward_1.axis_value = +1.0
	Snotbane.add_default_input_binding(Snotbane.SETTING_INPUT_GHOST_MOVE_FORWARD, [
		ghost_move_forward_0,
		ghost_move_forward_1,
	])


	var ghost_camera_left_0 := InputEventKey.new()
	ghost_camera_left_0.physical_keycode = KEY_LEFT
	var ghost_camera_left_1 := InputEventJoypadMotion.new()
	ghost_camera_left_1.axis = JOY_AXIS_RIGHT_X
	ghost_camera_left_1.axis_value = -1.0
	Snotbane.add_default_input_binding(Snotbane.SETTING_INPUT_GHOST_CAMERA_LEFT, [
		ghost_camera_left_0,
		ghost_camera_left_1,
	])


	var ghost_camera_right_0 := InputEventKey.new()
	ghost_camera_right_0.physical_keycode = KEY_RIGHT
	var ghost_camera_right_1 := InputEventJoypadMotion.new()
	ghost_camera_right_1.axis = JOY_AXIS_RIGHT_X
	ghost_camera_right_1.axis_value = +1.0
	Snotbane.add_default_input_binding(Snotbane.SETTING_INPUT_GHOST_CAMERA_RIGHT, [
		ghost_camera_right_0,
		ghost_camera_right_1,
	])


	var ghost_camera_down_0 := InputEventKey.new()
	ghost_camera_down_0.physical_keycode = KEY_DOWN
	var ghost_camera_down_1 := InputEventJoypadMotion.new()
	ghost_camera_down_1.axis = JOY_AXIS_RIGHT_Y
	ghost_camera_down_1.axis_value = -1.0
	Snotbane.add_default_input_binding(Snotbane.SETTING_INPUT_GHOST_CAMERA_DOWN, [
		ghost_camera_down_0,
		ghost_camera_down_1,
	])


	var ghost_camera_up_0 := InputEventKey.new()
	ghost_camera_up_0.physical_keycode = KEY_UP
	var ghost_camera_up_1 := InputEventJoypadMotion.new()
	ghost_camera_up_1.axis = JOY_AXIS_RIGHT_Y
	ghost_camera_up_1.axis_value = +1.0
	Snotbane.add_default_input_binding(Snotbane.SETTING_INPUT_GHOST_CAMERA_UP, [
		ghost_camera_up_0,
		ghost_camera_up_1,
	])


	var debug_grid_toggle_0 := InputEventKey.new()
	debug_grid_toggle_0.physical_keycode = KEY_PERIOD
	Snotbane.add_default_input_binding(Snotbane.SETTING_INPUT_DEBUG_GRID_TOGGLE, [
		debug_grid_toggle_0,
	])

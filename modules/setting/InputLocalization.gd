
@tool class_name InputLocalization extends Resource

enum {
	PLATFORM_GENERIC,
	PLATFORM_NINTENDO,
	PLATFORM_SONY,
	PLATFORM_XBOX,
	PLATFORM_OTHER,
}

static var inst : InputLocalization

@export var auto_translate_key_events : bool = true

@export var unbound : String = "(Unbound)"
@export var unknown : String = "???"

var platform : int :
	get: return PLATFORM_XBOX

@export var joypad_buttons_generic : PackedStringArray = [
	"A",
	"B",
	"X",
	"Y",
	"Back",
	"Guide",
	"Start",
	"Left Stick",
	"Right Stick",
	"Left Shoulder",
	"Right Shoulder",
	"D-Pad Up",
	"D-Pad Down",
	"D-Pad Left",
	"D-Pad Right",
	"Misc 1",
	"Paddle 1",
	"Paddle 2",
	"Paddle 3",
	"Paddle 4",
	"Touchpad"
]
@export var joypad_buttons_nintendo : PackedStringArray = [
	"B",
	"A",
	"Y",
	"X",
	"-",
	"",
	"+",
	"LS",
	"RS",
	"L",
	"R",
	"",
	"",
	"",
	"",
	"Capture",
	"",
	"",
	"",
	"",
	""
]
@export var joypad_buttons_sony : PackedStringArray = [
	"Cross",
	"Circle",
	"Square",
	"Triangle",
	"Select",
	"PS",
	"Options",
	"L3",
	"R3",
	"L1",
	"R1",
	"D-Pad Up",
	"D-Pad Down",
	"D-Pad Left",
	"D-Pad Right",
	"Microphone",
	"",
	"",
	"",
	"",
	""
]
@export var joypad_buttons_xbox : PackedStringArray = [
	"",
	"",
	"",
	"",
	"",
	"Home",
	"Menu",
	"LS",
	"RS",
	"LB",
	"RB",
	"D-Pad Up",
	"D-Pad Down",
	"D-Pad Left",
	"D-Pad Right",
	"Share",
	"",
	"",
	"",
	"",
	""
]
@export var joypad_buttons_other : PackedStringArray = []


@export var joypad_axes_generic : PackedStringArray = [
	"Left Stick X",
	"Left Stick Y",
	"Right Stick X",
	"Right Stick Y",
	"Trigger L",
	"Trigger R",
]
@export var joypad_axes_nintendo : PackedStringArray = [
	"L JoyCon X",
	"L JoyCon Y",
	"R JoyCon X",
	"R JoyCon Y",
	"ZL",
	"ZR",
]
@export var joypad_axes_sony : PackedStringArray = [
	"L Stick X",
	"L Stick Y",
	"R Stick X",
	"R Stick Y",
	"L2",
	"R2",
]
@export var joypad_axes_xbox : PackedStringArray = [
	"LS X Axis",
	"LS Y Axis",
	"RS X Axis",
	"RS Y Axis",
	"LT",
	"RT",
]
@export var joypad_axes_other : PackedStringArray = []

func _init() -> void:
	inst = self

func translate(event: InputEvent) -> String:
	if event == null:
		return unbound
	elif event is InputEventKey and auto_translate_key_events:
		return OS.get_keycode_string(event.keycode)
	elif event is InputEventJoypadButton:
		return get_joypad_button_translation(event)
	else:
		return unknown

func translate_tooltip(event: InputEvent) -> String:
	if event == null:
		return ""
	elif event is InputEventKey and auto_translate_key_events:
		return ""
	else:
		return event.as_text()


func get_joypad_button_translation(event: InputEventJoypadButton, __platform__ : int = platform) -> String:
	var lut : PackedStringArray
	match __platform__:
		PLATFORM_GENERIC:	lut = joypad_buttons_generic
		PLATFORM_NINTENDO:	lut = joypad_buttons_nintendo
		PLATFORM_SONY:		lut = joypad_buttons_sony
		PLATFORM_XBOX:		lut = joypad_buttons_xbox
		_:					lut = joypad_buttons_other

	var result : String = \
		lut[event.button_index] \
		if	event.button_index >= 0 and event.button_index < lut.size() \
		else ""

	return result if not result.is_empty() \
		else unknown if __platform__ == PLATFORM_GENERIC \
		else get_joypad_button_translation(event, PLATFORM_GENERIC)


func get_joypad_motion_translation(event: InputEventJoypadMotion, __platform__ := platform) -> String:
	var lut : PackedStringArray
	match __platform__:
		PLATFORM_GENERIC:	lut = joypad_axes_generic
		PLATFORM_NINTENDO:	lut = joypad_axes_nintendo
		PLATFORM_SONY:		lut = joypad_axes_sony
		PLATFORM_XBOX:		lut = joypad_axes_xbox
		_:					lut = joypad_axes_other

	var result : String = \
		lut[event.axis] \
		if 	event.axis >= 0 and event.axis < lut.size() \
		else ""

	return result if not result.is_empty() \
		else unknown if __platform__ == PLATFORM_GENERIC \
		else get_joypad_motion_translation(event, PLATFORM_GENERIC)

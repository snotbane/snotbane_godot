
@tool class_name InputBindingButton extends Button

const ICON_JOYPAD_BUTTON := preload("uid://cnw8afrmuctgm")
var icon_joypad_button : Texture2D :
	get: return get_theme_icon(&"joypad_button", &"InputBindingButton") if has_theme_icon(&"joypad_button", &"InputBindingButton") else ICON_JOYPAD_BUTTON

const ICON_JOYPAD_MOTION := preload("uid://c0hk26wraga6n")
var icon_joypad_motion : Texture2D :
	get: return get_theme_icon(&"joypad_motion", &"InputBindingButton") if has_theme_icon(&"joypad_motion", &"InputBindingButton") else ICON_JOYPAD_MOTION

const ICON_KEY := preload("uid://bydr61cd6aanv")
var icon_key : Texture2D :
	get: return get_theme_icon(&"key", &"InputBindingButton") if has_theme_icon(&"key", &"InputBindingButton") else ICON_KEY

const ICON_MOUSE_BUTTON := preload("uid://3q8l8boe0yao")
var icon_mouse_button : Texture2D :
	get: return get_theme_icon(&"mouse_button", &"InputBindingButton") if has_theme_icon(&"mouse_button", &"InputBindingButton") else ICON_MOUSE_BUTTON

const ICON_MOUSE_MOTION := preload("uid://b2ipsnkiinyci")
var icon_mouse_motion : Texture2D :
	get: return get_theme_icon(&"mouse_motion", &"InputBindingButton") if has_theme_icon(&"mouse_motion", &"InputBindingButton") else ICON_MOUSE_MOTION

const ICON_OTHER := preload("uid://6m538tjp0de3")
var icon_other : Texture2D :
	get: return get_theme_icon(&"other", &"InputBindingButton") if has_theme_icon(&"other", &"InputBindingButton") else ICON_OTHER


var event : InputEvent

var filter_category : int :
	get:
		if event is InputEventJoypadButton:		return SettingInputBinding.FILTER_JOYPAD
		elif event is InputEventJoypadMotion:	return SettingInputBinding.FILTER_JOYPAD
		elif event is InputEventKey:			return SettingInputBinding.FILTER_KEYBOARD
		elif event is InputEventMouseButton:	return SettingInputBinding.FILTER_MOUSE
		elif event is InputEventMouseMotion:	return SettingInputBinding.FILTER_MOUSE
		else:									return SettingInputBinding.FILTER_OTHER

func _init(__event__: InputEvent = null, begin_remap : bool = false) -> void:
	size_flags_horizontal = Control.SIZE_EXPAND_FILL
	toggle_mode = true

	event = __event__

	if event:
		event.changed.connect(refresh)

	refresh()

func refresh() -> void:
	text = InputLocalization.inst.translate(event)
	tooltip_text = InputLocalization.inst.translate_tooltip(event)

	if event == null:
		icon = null
	elif event is InputEventJoypadButton:
		icon = icon_joypad_button
	elif event is InputEventJoypadMotion:
		icon = icon_joypad_motion
	elif event is InputEventKey:
		icon = icon_key
	elif event is InputEventMouseButton:
		icon = icon_mouse_button
	elif event is InputEventMouseMotion:
		icon = icon_mouse_motion
	else:
		icon = icon_other


func remove_if_unbound() -> void:
	if event != null: return

	queue_free()


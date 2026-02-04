
@tool class_name SettingCheck extends Setting

var button : BaseButton

func _init() -> void:
	super._init()

	button = CheckBox.new()
	button.size_flags_vertical = Control.SIZE_SHRINK_CENTER
	hbox_panel.add_child(button)

	button.add_child(tracker)


@export_enum("Check Box", "Check Button") var button_type : int = 0 :
	get:
		if button is CheckBox:		return 0
		if button is CheckButton:	return 1
		return -1

	set(value):
		if button_type == value: return

		var new_button : BaseButton
		match value:
			0: new_button = CheckBox.new()
			1: new_button = CheckButton.new()
			_: return

		new_button.size_flags_vertical = button.size_flags_vertical
		new_button.button_pressed = button.button_pressed
		if button.toggled.is_connected(tracker._parent_value_changed):
			new_button.toggled.connect(tracker._parent_value_changed.unbind(1))

		hbox_panel.add_child(new_button)
		tracker.reparent(new_button)
		button.queue_free()
		button = new_button


@export var button_pressed : bool :
	get: return button.button_pressed
	set(value): button.button_pressed = value


extends LineEdit

func _init() -> void:
	visibility_changed.connect(_visibility_changed)
	text_submitted.connect(_text_submitted)


func _visibility_changed() -> void:
	if not visible: return

	grab_focus()


func _text_submitted(new_text: String) -> void:
	text = String()

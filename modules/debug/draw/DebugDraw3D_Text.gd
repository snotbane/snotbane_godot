
class_name DebugDraw3D_Text extends DebugDraw3D_Point

func _on_color_set() -> void:
	label.modulate = color

var text : String :
	get: return label.text
	set(value):
		if text == value: return
		label.text = value

var label : Label3D

func _init(__top_level__: bool = true, __position__: Vector3 = Vector3.ZERO, __text__: String = "") -> void:
	super._init(__top_level__, __position__, 0.125)

	label = Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.double_sided = false
	label.fixed_size = true
	label.pixel_size = 0.0005
	label.modulate = color
	label.position = Vector3.UP * radius * 1.25
	text = __text__

	add_child(label)

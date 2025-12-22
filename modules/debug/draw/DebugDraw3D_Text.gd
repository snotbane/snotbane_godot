
@tool class_name DebugDraw3D_Text extends DebugDraw3D_Point

func _on_color_set() -> void:
	label.modulate = color

func _on_radius_set() -> void:
	# label.position = Vector3.UP * radius * 1.25 # Crashes game.
	pass

@export var text : String :
	get: return label.text
	set(value):	label.text = value

@export var pixel_size : float = 0.001 :
	get: return label.pixel_size
	set(value): label.pixel_size = value


var label : Label3D

func _init(__top_level__: bool = false, __text__: String = "", __radius__: float = 0.125) -> void:
	super._init(__top_level__, __radius__)

	label = Label3D.new()
	label.billboard = BaseMaterial3D.BILLBOARD_ENABLED
	label.double_sided = false
	label.fixed_size = true
	label.pixel_size = 0.001
	label.modulate = color
	label.position = Vector3.UP * radius * 1.25
	text = __text__

	add_child.call_deferred(label, false, INTERNAL_MODE_BACK)

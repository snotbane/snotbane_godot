@tool extends SettingSlider

@export var bus_name : StringName


var bus_index : int :
	get: return AudioServer.get_bus_index(bus_name)


func _on_value_changed(val:Variant) -> void:
	AudioServer.set_bus_volume_linear(bus_index, val)

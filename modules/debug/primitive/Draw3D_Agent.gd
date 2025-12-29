
@tool class_name Draw3D_Agent extends Draw3D

@onready var _agent : NavigationAgent3D = get_parent()
@onready var _host : Node3D = _agent.get_parent()

var _host_size : float = 0.1
@export_range(0.0, 1.0, 0.01, "or_greater") var host_size : float = 0.1 :
	get: return _host_size
	set(value):
		_host_size = value
		host_point.size = _host_size

var line : Draw3D_Line
var host_point : Draw3D_Point

func _init() -> void:
	super._init()

	line = Draw3D_Line.new()
	add_child(line, false, INTERNAL_MODE_BACK)

	host_point = Draw3D_Point.new()
	add_child(host_point, false, INTERNAL_MODE_BACK)

	host_size = host_size


func _ready() -> void:
	super._ready()

	if not OS.is_debug_build(): return
	if not Engine.is_editor_hint():
		reparent.call_deferred(_host)

func _physics_process(delta: float) -> void:
	host_point.global_position = _host.global_position

	if Engine.is_editor_hint(): return

	var c : Color
	if _agent.is_target_reached():
		if _agent is Brain3D:
			if _agent._travel_state == Brain3D.STOPPED:
				c = Color.BLUE
			else:
				c = Color.AQUAMARINE
		else:
			c = Color.BLUE
	elif _agent.is_navigation_finished():
		c = Color.RED
	else:
		c = Color.YELLOW

	line.color = c
	line.points = _agent.get_current_navigation_path()


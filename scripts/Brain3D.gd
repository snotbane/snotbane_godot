
class_name Brain3D extends NavigationAgent3D

signal desired_move(direction: Vector3)

@export_range(0.01, 1.0, 0.01, "or_greater") var nav_refresh_duration : float = 0.2
@export var continuous_update : bool = false

var nav_target : BrainTarget
var travelling : bool :
	get: return nav_target.is_assigned and not is_target_reached()

func _ready() -> void:
	nav_target = BrainTarget.new(nav_refresh_duration)
	if continuous_update:
		nav_target.updated.connect(refresh_target_position)
	add_child(nav_target)

	# target_reached.connect(print.bind("Target reached"))

	sequence()

func sequence() -> void:
	if not has_method(&"_sequence"): return
	await get_tree().process_frame
	while is_instance_valid(self): await call(&"_sequence")

func _physics_process(delta: float) -> void:
	if travelling:
		var displacement = (get_next_path_position() - get_parent().global_position) * Vector3(1, 0, 1)
		desired_move.emit(displacement.normalized())
	else:
		desired_move.emit(Vector3.ZERO)


func refresh_target_position() -> void:
	target_position = nav_target.target_position

func travel(target: Variant) :
	if target != null:
		var was_travelling := travelling
		nav_target.target = target
		refresh_target_position()
		if not was_travelling:
			await wait(nav_refresh_duration)
			if not is_target_reached():
				await target_reached
	stop()

func stop() -> void:
	nav_target.target = null

func wait(duration_seconds: float) :
	await get_tree().create_timer(duration_seconds).timeout


class_name Brain3D extends NavigationAgent3D

signal desired_move(direction: Vector3)

@export_subgroup("Navigation")

var _refresh_duration : float = 0.1
## If greater than 0.0, [member target_position] will be continuously updated after this many seconds. If 0.0, this will only occur when [member target] is manually changed or [member refresh_target_position] is manually called.
@export_range(0.0, 1.0, 0.01, "or_greater") var refresh_duration : float = 0.1 :
	get: return _refresh_duration
	set(value):
		if _refresh_duration == value: return
		_refresh_duration = value

		if target != null:
			target.refresh_duration = _refresh_duration




## If enabled, [member target_position] will be updated once every [member refresh_duration] seconds.
var continuous_update : bool :
	get: return refresh_duration > 0.0



var target : BrainTarget

var _move_vector_prev : Vector3


var travelling : bool :
	get: return target.is_assigned and not is_navigation_finished()


func _ready() -> void:
	target = BrainTarget.new(refresh_duration)
	target.changed.connect(refresh_target_position)
	target.updated.connect(refresh_target_position)

	sequence()

func sequence() -> void:
	if not has_method(&"_sequence"): return
	await get_tree().process_frame
	while is_instance_valid(self): await call(&"_sequence")

func _physics_process(delta: float) -> void:
	var move_vector : Vector3
	if travelling:
		move_vector = ((get_next_path_position() - get_parent().global_position) * Vector3(1, 0, 1)).normalized()
	else:
		move_vector = Vector3.ZERO

	if move_vector != _move_vector_prev:
		desired_move.emit(move_vector)
		_move_vector_prev = move_vector


func refresh_target_position() -> void:
	target_position = target.target_position

func travel(target: Variant) :
	if target != null:
		var was_travelling := travelling
		target.target = target
		refresh_target_position()
		if not was_travelling:
			await wait(refresh_duration)
			if not is_target_reached():
				await target_reached
	stop()

func stop() -> void:
	target.target = null

func wait(duration_seconds: float) :
	await get_tree().create_timer(duration_seconds).timeout

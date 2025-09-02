class_name MincuzMath

static func random_sign(random: RandomNumberGenerator = null) -> int:
	return +1 if random.randi() % 2 else -1


static func random_float(__range__: Vector2, random: RandomNumberGenerator = null) -> float:
	if random:
		return random.randf_range(__range__.x, __range__.y)
	else:
		return randf_range(__range__.x, __range__.y)


static func random_unit_vector1(random: RandomNumberGenerator = null) -> float:
	return randf_range(-1.0, +1.0)


static func random_unit_vector2(random: RandomNumberGenerator = null) -> Vector2:
	return Vector2.RIGHT.rotated(random_float(Vector2(-PI, +PI), random))


## https://math.stackexchange.com/a/44691
static func random_unit_vector3(random: RandomNumberGenerator = null) -> Vector3:
	var t := random_float(Vector2(0, 2 * PI))
	var z := random_float(Vector2(-1, +1))
	var s := sqrt(1.0 - (z * z))
	return Vector3(s * cos(t), s * sin(t), z)


## Returns a [float] with a random sign within the specified [range]
static func random_vector1(__range__: Vector2, random: RandomNumberGenerator = null) -> float:
	return random_float(__range__, random) * random_sign(random)


## Returns a [Vector2] in a random direction with a length within the specified [Vector2] range.
static func random_vector2(__range__: Vector2, random: RandomNumberGenerator = null) -> Vector2:
	return random_unit_vector2(random) * random_float(__range__, random)


## Returns a [Vector3] in a random direction with a length within the specified [Vector2] range.
static func random_vector3(__range__: Vector2, random: RandomNumberGenerator = null) -> Vector3:
	return random_unit_vector3(random) * random_float(__range__, random)


static func is_in_range(x: float, __range__: Vector2) -> bool:
	return x >= __range__.x and x <= __range__.y


static func xy(v: Vector3) -> Vector2:
	return Vector2(v.x, v.y)
static func xz(v: Vector3) -> Vector2:
	return Vector2(v.x, v.z)
static func yz(v: Vector3) -> Vector2:
	return Vector2(v.y, v.z)

static func x_y(v: Vector2, y: float = 0.0) -> Vector3:
	return Vector3(v.x, y, v.y)
static func xy_(v: Vector2, z: float = 0.0) -> Vector3:
	return Vector3(v.x, v.y, z)


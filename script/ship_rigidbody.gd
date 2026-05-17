extends RigidBody3D

var station_col: Area3D
var shuttle_col: Area3D

var integral: Vector3 = Vector3(0, 0, 0)
var prev_distance: Vector3 = Vector3(0, 0, 0)

const Kp = 5.0
const Ki = 0.01
const Kd = 8.0
const Kall = 10000

var cam_mode: int = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	station_col = $"../station/station_dock_col"
	shuttle_col = $shuttle/dock/shuttle_dock_col
	
	$cam_back.current = true

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var distance = station_col.global_position - shuttle_col.global_position
	
	# take the numerial integrals and derivative of the distance
	integral += distance * delta
	# integral = integral.clamp(Vector3(-10, -10, -10), Vector3(10, 10, 10))
	var derivative = (distance - prev_distance)/delta
	
	constant_force = Kall*(Kp * distance + Ki * integral + Kd * derivative)

	# save the current distance to be used in the next frame
	prev_distance = distance

func _input(event: InputEvent) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_C:
			cam_mode += 1
			$cam_back.current = (cam_mode % 3 == 0)
			$cam_dock.current = (cam_mode % 3 == 1)
			$cam_top.current  = (cam_mode % 3 == 2)
			

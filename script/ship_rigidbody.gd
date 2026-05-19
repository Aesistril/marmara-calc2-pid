extends RigidBody3D

var station_col: Area3D
var shuttle_col: Area3D

var integral_abs_err: Vector3 = Vector3(0, 0, 0)

var integral: Vector3 = Vector3(0, 0, 0)
var integral_zvel: float
var prev_distance: Vector3 = Vector3(0, 0, 0)
var prev_error_zvel: float

const Kp = 650
const Ki = 0.001
const Kd = 5000
const Kall = 1

const engineLimit = 10000

const KZp =650
const KZi = 0.001
const KZd = 45
const KZall = 1

const ship_randpos_mult = 50
const ship_randvel_mult = 25
const station_randpos_mult = 50

var cam_mode: int = 0
var camera_speed = 0.02

var station_target_pos = Vector3(0, 0, -21)

var z_overshoot: float = 0

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	station_col = $"../station/station_dock_col"
	shuttle_col = $shuttle/dock/shuttle_dock_col
	
	$cam_back_anchor/cam_back.current = true
	
	# place the ship in a random position
	global_position = ship_randpos_mult*Vector3(randf()-0.5, randf()-0.5, randf())

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	var distance = station_col.global_position - shuttle_col.global_position
	
	################## Space Station Placement ##################
	$"../station".global_position += \
		((station_target_pos - $"../station".position)*1*delta).clamp(
		Vector3(-1, -1, -1), Vector3(1, 1, 1))
		
	###################### Detect Overshoot #####################
	if distance.z > z_overshoot:
		z_overshoot = distance.z
		$"../CanvasLayer/z_overshoot".text = \
			"Approach Overshoot: " + str(z_overshoot)
			
	##################### Integral Abs Err ######################
	integral_abs_err += abs(distance)*delta
	$"../CanvasLayer/int_abs_err".text = \
		"Integral Absolute Error: " + str(integral_abs_err)
	
	######################  Space Ship PID ######################
	# take the numerial integrals and derivative of the distance
	var derivative = (distance - prev_distance)/delta
	integral += distance * delta
	constant_force = Kall*(Kp * distance + Ki * integral + Kd * derivative)
	
	#var target_velocity_z = distance.z * 0.5	
	#
	#var error_zvel = target_velocity_z - linear_velocity.z
	#var derivative_zvel = (error_zvel - prev_error_zvel)/delta
	#integral_zvel += error_zvel * delta
	#constant_force.z = KZall* \
		#(KZp * error_zvel + KZi * integral_zvel + KZd * derivative_zvel)
	#
	#constant_force = constant_force.clamp(
		#-Vector3(engineLimit,engineLimit,engineLimit), 
		#Vector3(engineLimit,engineLimit,engineLimit))

	# save the current distance and z velocity to be used in the next frame
	prev_distance = distance
	#prev_error_zvel = error_zvel
	
	$"../CanvasLayer/distance".text = "Distance: " + str(distance)
	$"../CanvasLayer/shuttle_forces".text = "Forces on Shuttle: " + str(constant_force)

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_C && event.pressed:
			cam_mode += 1
			$cam_back_anchor/cam_back.current = (cam_mode % 3 == 0)
			$cam_dock_anchor/cam_dock.current = (cam_mode % 3 == 1)
			$cam_top_anchor/cam_top.current = (cam_mode % 3 == 2)
		if event.keycode == KEY_M && event.pressed:
			station_target_pos += station_randpos_mult*Vector3(randf()-0.5, randf()-0.5, -randf()/2)
		if event.keycode == KEY_R && event.pressed:
			linear_velocity += ship_randvel_mult* \
				Vector3(randf()-0.5, randf()-0.5, randf()/2)
			
func _process(delta):
	if Input.is_anything_pressed():
		var camera_anchor = get_viewport().get_camera_3d().get_parent_node_3d()

		if Input.is_action_pressed("ui_left"):
			camera_anchor.rotate_y(camera_speed)
		if Input.is_action_pressed("ui_right"):
			camera_anchor.rotate_y(-camera_speed)
		if Input.is_action_pressed("ui_up"):
			camera_anchor.rotate_z(camera_speed)
		if Input.is_action_pressed("ui_down"):
			camera_anchor.rotate_z(-camera_speed)

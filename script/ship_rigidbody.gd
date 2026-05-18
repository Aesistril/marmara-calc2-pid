extends RigidBody3D

var station_col: Area3D
var shuttle_col: Area3D

var integral: Vector3 = Vector3(0, 0, 0)
var prev_distance: Vector3 = Vector3(0, 0, 0)

const Kp = 5.0
const Ki = 0.01
const Kd = 8.0
const Kall = 10000

const KZp = 5.0
const KZi = 0.01
const KZd = 8.0
const KZall = 10000

const randpos_mult = 50
const station_randpos_mult = 50

var cam_mode: int = 0
var camera_speed = 0.03

var station_target_pos = Vector3(0, 0, -21)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	station_col = $"../station/station_dock_col"
	shuttle_col = $shuttle/dock/shuttle_dock_col
	
	$cam_back_anchor/cam_back.current = true
	
	# place the ship in a random position
	global_position = Vector3((randf()-0.5)*randpos_mult, 
		(randf()-0.5)*randpos_mult, randf()*randpos_mult)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _physics_process(delta: float) -> void:
	################## Space Station Placement ##################
	$"../station".position += \
		((station_target_pos - $"../station".position)*1*delta).clamp(
		Vector3(-1, -1, 0), Vector3(1, 1, 0))
	
	######################  Space Ship PID ######################
	var distance = station_col.global_position - shuttle_col.global_position

	# take the numerial integrals and derivative of the distance
	var derivative = (distance - prev_distance)/delta
	integral += distance * delta	
	
	constant_force = Kall*(Kp * distance + Ki * integral + Kd * derivative)
	constant_force.z = 0
	
	# Only start approaching once the x-y plane is stable, ignore z otherwise
	if abs(constant_force.x) < 10 && abs(constant_force.y) < 10:
		constant_force.z = KZall*(KZp * distance + KZi * integral + KZd * derivative).z
	print(constant_force)

	constant_force = constant_force.clamp(
		-Vector3(100000,100000,100000), Vector3(100000,100000,10000))

	# save the current distance to be used in the next frame
	prev_distance = distance

func _input(event: InputEvent) -> void:
	if event is InputEventKey:
		if event.keycode == KEY_C && event.pressed:
			cam_mode += 1
			$cam_back_anchor/cam_back.current = (cam_mode % 3 == 0)
			$cam_dock_anchor/cam_dock.current = (cam_mode % 3 == 1)
			$cam_top_anchor/cam_top.current = (cam_mode % 3 == 2)
			
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
			
		if Input.is_key_pressed(KEY_M):
			station_target_pos.x = (randf()-0.5)*station_randpos_mult
			station_target_pos.y = (randf()-0.5)*station_randpos_mult

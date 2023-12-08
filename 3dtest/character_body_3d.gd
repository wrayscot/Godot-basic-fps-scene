extends CharacterBody3D

@onready var head = $"head"
@onready var slideTimer = $"timers/slide_timer"
@onready var doorDetector = $"doorDetector"

var cam_x = 0.0
var cam_y = 0.0
#highest you can look up or down
var cam_x_max = 75.0
var cam_x_min = -70.0

#mouse sens, higher equals faster mouse turns
var y_sensitivity = 10.0
var x_sensitivity = 3.0
var y_acceleration = 10
var x_acceleration = 10

#controller settings
var right_joy_deadzone = .1
var right_joy_ysens = 2.5
var right_joy_xsens = 5

var input_dir = Vector2(0, 0)

#region player settings
const GROUND_RESISTANCE = 0.7
const AIR_RESISTANCE = .2
const SPEED = 5.0
const JUMP_speed = 4.5
#endregion

# Get the gravity from the project settings to be synced with RigidBody nodes.
var gravity = ProjectSettings.get_setting("physics/3d/default_gravity")
var speed = Vector3(0, 0, 0)

var doors = []

func _ready():
	#Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	pass

func _input(event):
	if event is InputEventMouseMotion:
		cam_y += -event.relative.x * y_sensitivity
		cam_x += -event.relative.y * x_sensitivity

func _physics_process(delta):
	
	doorHandler()
	
	if Input.get_connected_joypads() != []:
		cam_x = -Input.get_joy_axis(0, JOY_AXIS_RIGHT_Y)
		cam_y = -Input.get_joy_axis(0, JOY_AXIS_RIGHT_X)
		
		if abs(cam_y) <= right_joy_deadzone:
			cam_y = 0
		if abs(cam_x) <= right_joy_deadzone:
			cam_x = 0

		rotation_degrees.y += (cam_y * right_joy_xsens)
		head.rotation_degrees.x += (cam_x * right_joy_ysens)

	else:
		#highest you can look up or down
		cam_x = clamp(cam_x, cam_x_min, cam_x_max)
		
		#changes the player's rotation which by extension rotates the camera
		rotation_degrees.y = lerp(head.rotation_degrees.y, cam_y, delta * y_acceleration)
		#changes camera position so the player doesn't change height or tilt weird
		head.rotation_degrees.x = lerp(head.rotation_degrees.x, cam_x, delta * x_acceleration)
	
	# Add the gravity.
	if not is_on_floor():
		speed.y -= gravity * delta

	# Handle Jump.
	if Input.is_action_pressed("jump") and is_on_floor():
		speed.y = JUMP_speed

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	input_dir = Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var direction = (transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	
	if not is_on_floor():
		direction /= Vector3(1.1, 1, 1.1)
		
	if direction:
		speed.x += direction.x * SPEED
		speed.z += direction.z * SPEED
	else:
		speed.x += move_toward(speed.x, 0, SPEED)
		speed.z += move_toward(speed.z, 0, SPEED)

	if Input.get_action_raw_strength("slide") and slideTimer.is_stopped():
		speed *= Vector3(3, 1, 3)
		slideTimer.start()

	velocity = speed
	
	speed.x = lerp(speed.x, 0.0, GROUND_RESISTANCE)
	speed.z = lerp(speed.z, 0.0, GROUND_RESISTANCE)


	move_and_slide()

func doorHandler():
	for area in doorDetector.get_overlapping_areas():
		if doors.has(area) == false:
			if area.get_parent().is_in_group("door"):
				area.get_parent().open()
				doors.append(area)
		
	var removeDoors = []
	for door in doors:
		if doorDetector.overlaps_area(door):
			pass
		else:
			door.get_parent().close()
			removeDoors.append(door)
			
	for door in removeDoors:
		doors.erase(door)
			
	
	doorDetector.area_exited
	#for area in doorDetector:
		#if area.get_parent().is_in_group("door"):
			#area.get_parent().position.y -= 2

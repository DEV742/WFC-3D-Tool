extends Node3D

var camera_rotation = Vector2(0.0, 0.0)
var camera_shift = Vector3(0.0, 0.0, 0.0)
var free_look_shift = Vector3(0.0, 0.0, 0.0)
var free_look_rotation = Vector2(0.0, 0.0)
var sensitivity = Vector2(0.5, 0.5)
var free_look_speed = 1

var cam_vertical_max = 75.0
var cam_vertical_min = -55.0
var lerp_smoothness = 10
var zoom = 0.0
var free_look = false
var translatedRoot = Vector3(0,0,0)
var freeLookTranslatedRoot = Vector3(0,0,0)

@onready var cam_col = $h/v/camcollider
@onready var camera = $h/v/Camera
@onready var camorigin = $h/v/camorigin
@onready var freelookcam = $freelook_h/freelook_v/FreeLookCam

func translateVector(localNode: Node3D, targetNode: Node3D, shift_vector: Vector3):
	var translatedVector = Vector3.ZERO
	var originA = Vector3(0,0,0)
	var originB = Vector3(0,0,0)
	var diffC = Vector3(0,0,0)
	originA = localNode.transform.origin
	originB = originA + Vector3(shift_vector.x, shift_vector.y, shift_vector.z)
	
	originA = localNode.to_global(originA)
	originB = localNode.to_global(originB)
	
	diffC = originB - originA
	translatedVector = targetNode.transform.translated(diffC).origin
	return translatedVector

func _input(event):
	#Camera rotation around origin
	if event is InputEventMouseMotion and Input.is_action_pressed("Left_Mouse"):
		camera_rotation.x += -event.relative.x * sensitivity.x
		camera_rotation.y += -event.relative.y * sensitivity.y
	
	if Input.is_action_pressed("Right_Mouse"):
		free_look = true
		camera.current = false
		freelookcam.visible = true
		freelookcam.current = true
	elif Input.is_action_just_released("Right_Mouse"):
		print("Exiting free look mode")
		free_look = false
		camera.current = true
		freelookcam.visible = false
		freelookcam.current = false
	
	if free_look:
		if event is InputEventMouseMotion:
			free_look_rotation.x += -event.relative.x * sensitivity.x
			free_look_rotation.y += -event.relative.y * sensitivity.y
		
	#Camera shift on local XY plane
	if event is InputEventMouseMotion and Input.is_action_pressed("Middle_Mouse") and not free_look:
		camera_shift.x = -event.relative.x * sensitivity.x/5
		camera_shift.y = event.relative.y * sensitivity.y/5
		translatedRoot = translateVector(camorigin, $h, camera_shift)
	
	#Camera zoom
	if Input.is_action_pressed("Mouse_Wheel_Up"):
		zoom += 1
		camorigin.transform.origin.z -= 1
		cam_col.target_position.z -= 1
	elif Input.is_action_pressed("Mouse_Wheel_Down"):
		zoom -= 1
		camorigin.transform.origin.z += 1
		cam_col.target_position.z += 1
	
	#Camera focus (reset of the origin to [0,0,0])
	if Input.is_action_pressed("Focus"):
		translatedRoot = Vector3.ZERO
	

func _physics_process(delta):
	if cam_col.is_colliding():
		camera.global_transform.origin = lerp(camera.global_transform.origin, cam_col.get_collision_point(), 0.2)
	else:
		camera.global_transform.origin.x = lerp(camera.global_transform.origin.x, camorigin.global_transform.origin.x, delta*lerp_smoothness)
		camera.global_transform.origin.y = lerp(camera.global_transform.origin.y, camorigin.global_transform.origin.y, delta*lerp_smoothness)
		camera.global_transform.origin.z = lerp(camera.global_transform.origin.z, camorigin.global_transform.origin.z, delta*lerp_smoothness)
	
	$h.transform.origin.x = lerp($h.transform.origin.x, translatedRoot.x, delta * lerp_smoothness)
	$h.transform.origin.y = lerp($h.transform.origin.y, translatedRoot.y, delta * lerp_smoothness)
	$h.transform.origin.z = lerp($h.transform.origin.z, translatedRoot.z, delta * lerp_smoothness)

	camera_rotation.y = clamp(camera_rotation.y, cam_vertical_min, cam_vertical_max)
	
	$h.rotation_degrees.y = lerp($h.rotation_degrees.y, camera_rotation.x, delta * lerp_smoothness)
	$h/v.rotation_degrees.x = lerp($h/v.rotation_degrees.x, camera_rotation.y, delta * lerp_smoothness)
	
	if free_look:
		
		if Input.is_action_pressed("Forward"):
			free_look_shift.z = -free_look_speed * sensitivity.x/5
		elif Input.is_action_pressed("Backward"):
			free_look_shift.z = free_look_speed * sensitivity.x/5
		elif Input.is_action_just_released("Forward") or Input.is_action_just_released("Backward"):
			free_look_shift.z = 0
		if Input.is_action_pressed("Right"):
			free_look_shift.x = free_look_speed * sensitivity.x/5
		elif Input.is_action_pressed("Left"):
			free_look_shift.x = -free_look_speed * sensitivity.x/5
		elif Input.is_action_just_released("Left") or Input.is_action_just_released("Right"):
			free_look_shift.x = 0
		freeLookTranslatedRoot = translateVector(freelookcam, $freelook_h, free_look_shift)
		
		free_look_rotation.y = clamp(free_look_rotation.y, cam_vertical_min, cam_vertical_max)
	
		$freelook_h.rotation_degrees.y = lerp($freelook_h.rotation_degrees.y, free_look_rotation.x, delta * lerp_smoothness)
		$freelook_h/freelook_v.rotation_degrees.x = lerp($freelook_h/freelook_v.rotation_degrees.x, free_look_rotation.y, delta * lerp_smoothness)
		
		$freelook_h.transform.origin.x = lerp($freelook_h.transform.origin.x, freeLookTranslatedRoot.x, delta * lerp_smoothness)
		$freelook_h.transform.origin.y = lerp($freelook_h.transform.origin.y, freeLookTranslatedRoot.y, delta * lerp_smoothness)
		$freelook_h.transform.origin.z = lerp($freelook_h.transform.origin.z, freeLookTranslatedRoot.z, delta * lerp_smoothness)
